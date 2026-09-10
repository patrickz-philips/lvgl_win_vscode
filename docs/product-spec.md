# 产品规格

> 基线文档：描述产品**当前已交付**的能力，不是待办清单。由 `handoff` 阶段按需更新（新增/变更用户可见能力时）。

## 产品定位

一个跨平台（Windows / macOS）的 LVGL 应用模拟器工作区。根仓库提供统一的 SDL 显示与输入宿主、LVGL 调度、构建集成与开发脚本；`projects/` 下的每个应用模块作为独立版本管理的 Git submodule，可在 PC 上先跑通再移植到嵌入式硬件。

## 用户与场景

| 用户 | 场景 | 目标 |
| --- | --- | --- |
| UI 开发者 | 在 PC 上开发某个产品的 LVGL 界面 | 不烧录硬件就能看到界面与交互效果 |
| 嵌入式集成者 | 把某个模块接进 ESP-IDF / FreeRTOS 固件 | 通过模块公开的 `*_ui_init()` 与数据推送 API 对接真实传感器 |
| 评审 / 演示者 | 给他人展示某个产品形态 | 用 `run` 脚本一条命令启动指定项目的独立可执行文件 |

## 已交付能力

| 能力 | 说明 | 引入功能 | 状态 |
| --- | --- | --- | --- |
| 多项目选择构建 | `SELECTED_PROJECT` 选择 7 个应用模块之一，输出按项目与配置隔离 | 存量 | 可用 |
| 跨平台构建脚本 | Windows `build.bat` / `run.bat` / `clean.bat`，macOS `build.sh` / `run.sh` / `clean.sh` | 存量 | 可用 |
| SDL 模拟宿主 | `src/hal/` 提供显示、鼠标、滚轮、键盘输入设备与 tick | 存量 | 可用 |
| 静态独立构建 | Windows 默认 `x64-windows-static`，可执行文件不依赖 vcpkg SDL2 DLL | 存量 | 可用 |
| Hair Dryer 模块 | 800 x 720，LED 灯带调色/动画控制面板 | 存量 | 可用 |
| Smart Shaver 模块 | 320 x 640，四页横向滑动界面 | 存量 | 可用 |
| Cheetah 模块 | 96 x 96，编码器/方向键数值调节 | 存量 | 可用 |
| Slide Player 模块 | 466 x 466，32 张图片的手势翻页浏览 | 存量 | 可用 |
| Battery Monitor 模块 | 410 x 502，两页电池状态展示，含数据推送 API | 存量 | 可用 |
| ACC Data 模块 | 410 x 502，加速度曲线与录制状态机，含 ESP-IDF 适配层 | 存量 | 可用 |
| Algorithm Animation 模块 | 240 x 240，窗口可缩放的算法动画演示 | 存量 | 可用 |
| 可选 FreeRTOS 宿主 | `USE_FREERTOS=ON` 构建 `src/freertos_main.c` 演示路径 | 存量 | 实验性 |

## 明确不做

- **不提供 submodule 的独立可执行构建**：`projects/*` 是 LVGL 模块，不含 SDL 宿主、LVGL 调度与入口点，必须由根仓库组装。
- **不在 CMake 中定义屏幕尺寸**：尺寸只由模块公开头文件声明。
- **不把硬件驱动纳入 PC 目标**：ESP-IDF / BSP 相关代码由 `LV_SIMULATOR` 守卫排除。
- **不做资产文件的运行时热加载框架**：资源要么在 Debug 下按仓库相对路径读取，要么编译进可执行文件。
- **不在根仓库直接修改 upstream submodule**（`lvgl/`、`FreeRTOS/`），除非任务显式要求。

## 术语表

| 术语 | 含义 |
| --- | --- |
| 宿主（host） | 根仓库提供的 SDL + LVGL 运行环境，即 `src/` 下的代码 |
| 模块（module） | `projects/<name>` 下的一个 LVGL 应用，只提供界面与数据接口 |
| standalone | **仅指** Windows 可执行文件运行时不需要 vcpkg 的 SDL2 DLL；不表示 submodule 能单独构建 |
| triplet | vcpkg 目标三元组，如 `x64-windows-static`、`arm64-osx` |
| `LV_SIMULATOR` | PC 构建时定义的宏，用于隔离硬件专属代码 |
| MVP | 模块内部的 Model / View / Presenter 分层，见 [architecture.md](architecture.md) |
