# 验收标准

> 基线文档：**累积**所有已交付功能的验收标准，是回归测试的清单来源。由 `handoff` 阶段追加本次功能的验收标准（从 `docs/work/<work-id>/spec.md` 迁移过来）。

## 格式

每条为 Given / When / Then，且必须有可执行的验证方式（自动命令或手动步骤）。本仓库当前**没有自动化测试框架**，验证方式以「构建成功」+「记录了具体操作步骤与观察点的手动验证」为准，禁止把「看起来正常」当作证据。

| ID | 来源功能 | Given | When | Then | 验证方式 | 状态 |
| --- | --- | --- | --- | --- | --- | --- |
| AC-1 | 存量 | 已初始化 submodule 且 vcpkg 在 `../vcpkg` | 运行 `./build.sh <PROJECT> Debug` | 构建成功，产物出现在 `bin/Debug/<project>/main` | `./build.sh <PROJECT> Debug` | 通过 |
| AC-2 | 存量 | 已成功构建某项目 | 运行 `./run.sh <PROJECT> Debug` | SDL 窗口按模块声明的尺寸打开，无控制台报错 | 手动：启动后确认窗口尺寸与标题 | 通过 |
| AC-3 | 存量 | Hair Dryer Debug 已构建 | 从仓库根目录启动并点击 `Start` | 灯带按当前样式与速度播放，无 `Image Not Found` | 手动：见 [ui-behavior.md](ui-behavior.md#hair-dryer800-x-720) | 通过 |
| AC-4 | 存量 | Slide Player Debug 已构建 | 按住左键向左拖拽 | 切到下一张，底部索引 +1，末张不再前进 | 手动：见 ui-behavior 对应小节 | 通过 |
| AC-5 | 存量 | Battery Monitor Debug 已构建 | 调用 `battery_monitor_set_data(NULL)` | UI 不变化、不崩溃 | 手动/临时插桩 | 通过 |
| AC-6 | 存量 | 任一模块新增了硬件相关代码 | 运行 PC 构建 | 不出现 ESP-IDF / FreeRTOS 头文件缺失错误（硬件代码被 `LV_SIMULATOR` 守卫排除） | `./build.sh <PROJECT> Debug` | 通过 |

## 回归集

每次 `feature-review` 必须重跑。**受影响的项目必跑**；改动涉及 `src/`、`CMakeLists.txt` 或构建脚本时，7 个项目全跑。

```bash
# macOS：受影响项目的 Debug 构建（把 <PROJECT> 换成实际项目）
./build.sh <PROJECT> Debug

# 改动了宿主 / CMake / 构建脚本时，全项目冒烟构建
for p in HAIR_DRYER SMART_SHAVER CHEETAH SLIDE_PLAYER BATTERY_MONITOR ACC_DATA ALGORITHM_ANIMATION; do
  ./build.sh "$p" Debug || echo "FAILED: $p"
done

# Release 路径（资源编译进可执行文件的分支）至少验证一个受影响项目
./build.sh <PROJECT> Release
```

```powershell
# Windows 等价命令
.\build.bat <PROJECT> Debug
.\build.bat <PROJECT> Release
```

手动回归步骤（无法自动化的部分）：

1. `run` 对应项目，确认窗口尺寸与 [ui-behavior.md](ui-behavior.md) 记录一致。
2. 走一遍该项目「页面 / 组件行为」小节里的主流程与边界行为。
3. 记录真实观察结果，不写「正常」。

# 待建立：自动化测试
# 当前没有单元测试或 headless 渲染校验，非平凡逻辑的「一个可运行的检查」暂以最小自检程序或构建期断言实现。
