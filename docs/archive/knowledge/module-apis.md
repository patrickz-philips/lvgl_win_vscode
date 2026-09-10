# Knowledge: 模块集成 API

命中关键词：集成、API、`*_ui_init`、推送数据、hair_dryer、battery_monitor、acc_data、led_strips、model.c、ESP-IDF、宿主对接。

## 通用契约

- 所有创建或更新 LVGL 对象的函数都必须在 **LVGL 线程**调用，除非该模块明确说明会把数据排队给 LVGL 线程。
- 模块持有静态 LVGL 对象与定时器且**没有反初始化 API**，因此每个 LVGL 生命周期内只能初始化一次。
- 公开头文件只暴露 `<project>_ui_init(void)` 与硬件应用层需要的数据推送 API，不暴露 LVGL 对象指针。
- 收指针的公开入口一律先 `if(ptr == NULL) return;`；数据入参用 `const <type> *` 并在内部拷贝，不留存外部指针。

| 模块 | 公开入口 |
| --- | --- |
| Hair Dryer | `hair_dryer_ui_init()` |
| Smart Shaver | `smart_shaver_ui_init()` |
| Cheetah | `cheetah_ui_init()` |
| Slide Player | `slide_player_ui_init()` |
| Battery Monitor | `battery_monitor_ui_init()` |
| ACC Data | `acc_data_ui_init()` |
| Algorithm Animation | `algorithm_animation_ui_init()` |

## Hair Dryer LED 动画

`projects/hair_dryer/inc/led_strips_discolor.h` 提供纯色、呼吸、跑马、波浪、脉冲控制。

- 启动任何动画前先调 `led_strips_discolor_init()`。
- 传给 `led_strips_discolor_init()` 与 `led_strips_set_segmented_mode()` 的数组，在动画定时器使用期间**必须保持有效**。
- 删除相关 LVGL 对象前，先调用对应的 stop API。
- 速度、颜色、动画类型分别用同一头文件里的 `LED_SPEED_*`、`LED_COLOR_*`、`LED_TYPE_*` 常量。

## Battery Monitor 数据推送

```c
#include "battery_monitor.h"

battery_monitor_data_t data = {
    .temperature = 26,
    .bat_voltage_mv = 3850,
    .vbus_voltage_mv = 5000,
    .system_voltage_mv = 3300,
    .bat_percent = 78,
    .is_charging = 1,
    .is_discharge = 0,
    .is_standby = 0,
    .is_vbus_in = 1,
    .is_vbus_good = 1,
    .charge_status = "Fast charge",
};

battery_monitor_ui_init();
battery_monitor_set_data(&data);
```

结构体本身会被拷贝，但 `charge_status` 是**指针**，其字符串存储必须在 UI 使用期间保持有效。传 `NULL` 给 `battery_monitor_set_data` 无效果；`charge_status` 为 `NULL` 时显示 `Unknown`。

## ACC Data

```c
#include "acc_data.h"

acc_data_ui_init();
acc_data_set_battery_percent(82);
acc_data_push_sample(x_raw, y_raw, z_raw);
```

- `acc_data_push_sample` 收有符号的 16 位原始 LSB 值。
- 每 `ACC_DATA_DISPLAY_PERIOD_MS`（20 ms）推一次才能维持设计的 125 点 / 2.5 秒窗口。

录制按键状态机把动作交回宿主：

```c
acc_data_record_action_t action = acc_data_handle_boot_button();
if(action == ACC_DATA_RECORD_ACTION_START) {
    /* Start recording samples. */
}
else if(action == ACC_DATA_RECORD_ACTION_STOP) {
    /* Stop and save recorded samples. */
}
```

保存完成后调 `acc_data_set_save_finished(true/false)`；存储不可用时调 `acc_data_set_sdcard_missing()`。这些函数**只更新 UI 状态**，文件录制与 SD 卡访问属于宿主应用。

## ACC Data 嵌入式 Model

`projects/acc_data/inc/model.h` 与 `src/model.c` 是 ESP-IDF / FreeRTOS 适配层，处理传感器、PMU、按键与存储事件。它依赖 ESP-IDF 类型与硬件服务，**被有意排除在 PC SDL 目标之外**。`model_post_*()` 入队的是任务上下文事件，**不是** ISR 安全 API。

模拟器侧必须为每个 `model_post_*()` 提供 `#ifdef LV_SIMULATOR` 下的空实现，否则 Presenter 无法在没有 FreeRTOS 的情况下编译。
