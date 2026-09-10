# UI 行为

> 基线文档：描述界面**当前**的交互契约。由 `handoff` 阶段按需更新（新增页面、改变交互、改变状态展示时）。无 UI 的功能在 handoff 中标注「无需更新」。

## 全局约定

| 项 | 约定 |
| --- | --- |
| 运行方式 | 从仓库根目录用 `run.bat` / `run.sh` 启动，参数必须与已成功的构建一致；运行时资源使用仓库相对路径 |
| 输入设备 | SDL 宿主统一注册鼠标、鼠标滚轮（编码器）、键盘三种输入设备，所有模块共用 |
| 退出方式 | 关闭 SDL 窗口即结束；`run.bat` 之后等待按键再关闭控制台 |
| 窗口尺寸 | 由模块公开头文件的 `<PROJECT>_SCREEN_WIDTH/HEIGHT` 决定；未声明的模块用 320 x 480 |
| 小屏缩放 | 显示区域小于 320 × 320 的项目在 `src/main.c` 中开启 `lv_sdl_window_set_resizeable`，靠拖拽窗口角缩放，**不**硬编码缩放倍数 |
| 物理按键模拟 | 声明了物理按键的项目在显示区**下方**同窗口内加虚拟按键条，宽度对齐显示区、每行高度 ≥ 48 px，全部包在 `#ifdef LV_SIMULATOR` 内 |
| 虚拟按键类型 | 只允许四种：slide（拖拽滑轨）、option（分段点选）、state（点击翻转状态）、click（按下弹起）；每种映射到真实硬件按键会产生的同一个 LVGL 输入事件 |
| 加载态 / 空状态 | 各模块自行定义，尚无统一约定（`TBD`，新增模块时在此补全） |
| 错误提示 | 资源缺失由 LVGL 直接显示占位（例：Hair Dryer 的 `Image Not Found`） |
| 键盘可达性 | 仅 Cheetah 显式使用方向键；其余模块以鼠标为主输入（`TBD`） |

## 页面 / 组件行为

### Hair Dryer（800 x 720）

- 入口：`run.bat HAIR_DRYER Debug` / `./run.sh HAIR_DRYER Debug`
- 主流程：鼠标操作控制面板，实时驱动 LED 灯带动画

| 状态 | 触发 | 展示 | 可用操作 |
| --- | --- | --- | --- |
| 停止 | 初始 / 点 `Stop` / 切换 Style | 灯带静止 | Start、切换速度/温度/样式 |
| 运行 | 点 `Start` | 按当前样式与速度播放 | Stop、Ionizing、切换速度/温度 |

- 控件：`Start`/`Stop`、`Ionizing`（离子色开关）、`Low`/`Mid`/`High`（速度）、`Cold`/`Warm`/`Hot`（温度色）、`Style Breathe`/`Wave`/`Pulse`（样式，切换时会停止运行）
- 边界与异常：Debug 运行时读取 `projects/hair_dryer/assets/hair_dryer.png`；不从仓库根目录启动会显示 `Image Not Found`。Release 编译 `hair_dryer.c` 资源

### Smart Shaver（320 x 640）

- 入口：`run.bat SMART_SHAVER Debug`
- 主流程：横向拖拽在 4 页之间切换

| 页 | 内容 |
| --- | --- |
| 1 | clean / replace / ready 控件 |
| 2 | status / settings 控件 |
| 3-4 | 占位页 |

- 边界与异常：拖拽必须按住左键并横向移动足够距离后再释放，否则不翻页

### Cheetah（96 x 96）

- 入口：`run.bat CHEETAH Debug`
- 主流程：调节单个数值

| 状态 | 触发 | 展示 | 可用操作 |
| --- | --- | --- | --- |
| 数值 0-100 | 初始为 0 | 当前值 | Up/Right 加、Down/Left 减、滚轮改变聚焦值 |

- 边界与异常：数值钳制在 0-100，越界不再变化

### Slide Player（466 x 466）

- 入口：`run.bat SLIDE_PLAYER Debug`
- 主流程：按住左键横向拖拽翻页，底部显示 `index/32`
- 边界与异常：向左手势下一张、向右手势上一张；停在第一张和最后一张不循环。构建期若 `assets/*.c` 一个都不存在，CMake 配置直接失败

### Battery Monitor（410 x 502）

- 入口：`run.bat BATTERY_MONITOR Debug`
- 主流程：按住左键左右拖拽在两页之间切换，模拟器以示例值启动

| 页 | 展示 |
| --- | --- |
| 1 | 温度、电池/VBUS/系统电压、电量百分比 |
| 2 | 充电、放电、待机、VBUS 标志位、充电状态文本 |

- 边界与异常：`battery_monitor_set_data(NULL)` 无效果；`charge_status` 为 `NULL` 时显示 `Unknown`

### ACC Data（410 x 502）

- 入口：`run.bat ACC_DATA Debug`
- 主流程：展示三轴加速度曲线与电量，曲线保留 125 个点（20 ms 采样时约 2.5 秒窗口）
- 边界与异常：桌面入口只初始化 UI、**不产生样本**，曲线保持初值直到宿主调用 `acc_data_push_sample`；本屏无可点击的录制按钮，录制按键 API 面向嵌入式宿主或其他输入适配器

### Algorithm Animation（240 x 240）

- 入口：`run.bat ALGORITHM_ANIMATION Debug`
- 主流程：自动播放算法动画，无需输入
- 边界与异常：窗口开启了可缩放，拖拽窗口角即可放大观察
