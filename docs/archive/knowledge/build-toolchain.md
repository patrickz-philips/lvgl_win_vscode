# Knowledge: 构建工具链（CMake + vcpkg + SDL2）

命中关键词：构建、build、cmake、vcpkg、triplet、SDL2、clean、standalone、DLL、资源、submodule、构建失败。

## 环境要求

### Windows

- Windows 10 或更高版本
- CMake ≥ 3.12.4 且在 `PATH` 中
- CMake 支持的 C/C++ 工具链（例如 Visual Studio Build Tools）
- vcpkg 位于**同级目录** `../vcpkg`
- 已为所选 triplet 安装 SDL2：`..\vcpkg\vcpkg.exe install sdl2:x64-windows-static`
- 仅重新生成 Hair Dryer 图片资源时需要 Python 3 + Pillow

### macOS

- macOS 12 或更高版本
- Xcode Command Line Tools：`xcode-select --install`
- CMake：`brew install cmake`
- vcpkg 位于 `../vcpkg`
- SDL2：Apple Silicon 用 `../vcpkg/vcpkg install sdl2:arm64-osx`，Intel 用 `sdl2:x64-osx`

期望目录布局（`../vcpkg` 是硬约束，构建文件里不得出现机器相关绝对路径）：

```text
lvgl_projects/
`-- vcpkg/
```

首次检出后初始化依赖：

```bash
git submodule sync --recursive
git submodule update --init --recursive
```

## 项目参数

| 项目参数 | 源码目录 | 模拟器尺寸 |
| --- | --- | --- |
| `HAIR_DRYER` | `projects/hair_dryer` | 800 x 720 |
| `SMART_SHAVER` | `projects/smart_shaver` | 320 x 640 |
| `CHEETAH` | `projects/cheetah` | 96 x 96 |
| `SLIDE_PLAYER` | `projects/slide_player` | 466 x 466 |
| `BATTERY_MONITOR` | `projects/battery_monitor` | 410 x 502 |
| `ACC_DATA` | `projects/acc_data` | 410 x 502 |
| `ALGORITHM_ANIMATION` | `projects/algorithm_animation` | 240 x 240 |

新增项目时这份清单要在 8 处同步：`CMakeLists.txt`、`build.bat`、`build.sh`、`run.bat`、`run.sh`、`clean.bat`、`clean.sh`、`src/main.c`（外加文档）。漏改任意一处的表现是「脚本报 invalid project」或「构建通过但跑的是默认项目」。

## 脚本构建

```powershell
.\build.bat [PROJECT] [Debug|Release]
.\run.bat   [PROJECT] [Debug|Release]
.\clean.bat [TARGET]
```

```bash
./build.sh [PROJECT] [Debug|Release]
./run.sh   [PROJECT] [Debug|Release]
./clean.sh [TARGET]
```

- 两个参数都可省略，默认 `HAIR_DRYER Debug`，参数大小写不敏感。
- 全部命令从**仓库根目录**执行；`run` 脚本以仓库根为工作目录启动可执行文件，运行时资源依赖这一点。
- 产物路径：`build/<Debug|Release>/<project>/`、`bin/<Debug|Release>/<project>/main`（macOS）或 `main.exe`（Windows）。

`clean` 的 `TARGET`：

| Target | 删除 |
| --- | --- |
| `all` 或省略 | 整个 `build/` 与 `bin/` |
| `build` | 整个 `build/` |
| `bin` | 整个 `bin/` |
| 项目参数 | 该项目在 `build/` 与 `bin/` 下的 Debug 与 Release 目录 |

## Triplet 与 standalone

**standalone 在本仓库只表示**：Windows 可执行文件运行时不需要 vcpkg 的 SDL2 DLL。它**不**表示 `projects/*` 能单独构建。

默认静态构建：

```powershell
..\vcpkg\vcpkg.exe install sdl2:x64-windows-static
.\build.bat SMART_SHAVER Release   # -> bin/Release/smart_shaver/main.exe
```

DLL 依赖构建（必须先 clean，CMake 构建树会锁定首次配置时的工具链）：

```powershell
..\vcpkg\vcpkg.exe install sdl2:x64-windows
.\clean.bat SMART_SHAVER
$env:VCPKG_TARGET_TRIPLET = "x64-windows"
.\build.bat SMART_SHAVER Release
Remove-Item Env:VCPKG_TARGET_TRIPLET
```

macOS 的 triplet 由 `CMakeLists.txt` 按架构自动选择（`arm64-osx` / `x64-osx`），需要覆盖时同样先 clean 再设 `VCPKG_TARGET_TRIPLET`。

要同时保留两种模式，用不同的构建目录，例如 `build/Debug/hair_dryer-static/` 与 `build/Debug/hair_dryer-dynamic/`。

分发前请在**没有开发机 vcpkg `PATH`** 的干净环境里试跑，否则区分不出「真的静态」和「只是全局能找到 DLL」。

## 手动 CMake

每个「项目 × 配置 × triplet」组合用独立构建目录：

```bash
cmake -S . -B build/Debug/hair_dryer \
  -DCMAKE_BUILD_TYPE=Debug \
  -DSELECTED_PROJECT=HAIR_DRYER \
  -DVCPKG_TARGET_TRIPLET=arm64-osx \
  -DCMAKE_TOOLCHAIN_FILE="../vcpkg/scripts/buildsystems/vcpkg.cmake"
cmake --build build/Debug/hair_dryer --config Debug -j
```

Windows 把续行符换成反引号、triplet 换成 `x64-windows-static` 即可。

可选开关：

| 设置 | 默认 | 用途 |
| --- | --- | --- |
| `USE_FREERTOS` | `OFF` | 构建实验性的 FreeRTOS 宿主路径（`src/freertos_main.c`，**不**初始化被选中的模块） |
| `LVGL_PRO_PROJECT_DIR` | 空 | 追加一个含 `CMakeLists.txt` 的 LVGL Pro 工程 |
| `LV_USE_DRAW_SDL` | `OFF` | 启用 SDL 绘制单元，引入 SDL2_image 依赖 |
| `LV_USE_LIBPNG` / `LV_USE_LIBJPEG_TURBO` / `LV_USE_FFMPEG` / `LV_USE_FREETYPE` | `OFF` | 链接对应第三方库 |

普通宿主构建会关闭 LVGL 的 examples、demos 与内置 ThorVG。

## 资源处理（构建期行为）

- Hair Dryer Debug：运行时读取 `projects/hair_dryer/assets/hair_dryer.png`。
- Hair Dryer Release：编译 `hair_dryer.c`；文件缺失时 `build.bat` 会尝试调用 Python 转换脚本。
- Cheetah：编译 `CMakeLists.txt` 中显式列出的资源 C 源文件。
- Slide Player：编译带编号的 `assets/*.c`，**一个都没有时配置阶段直接失败**。
- Smart Shaver、Battery Monitor、桌面版 ACC Data：不加入图片资源源文件。
- `projects/acc_data/src/model.c` 是 ESP-IDF 集成层，不属于 PC SDL 目标。

## Submodule 开发顺序

先在项目仓库提交并推送，再更新根仓库的 gitlink；根仓库不得引用远端没有的 submodule commit。

```bash
git -C projects/<name> status
git -C projects/<name> add <files>
git -C projects/<name> commit -m "..."
git -C projects/<name> push
git add projects/<name>
```

## 踩过的坑

| 现象 | 根因 | 处理 |
| --- | --- | --- |
| 找不到 vcpkg toolchain | `../vcpkg/scripts/buildsystems/vcpkg.cmake` 不存在 | 把 vcpkg 放到仓库同级目录，**不要**改成绝对路径 |
| 找不到 SDL2 | 没为当前 triplet 装 SDL2 | 按 `build` 脚本打印的 triplet 安装对应包 |
| 改了 triplet 但没生效 / 链接错乱 | CMake 构建树缓存了首次配置的工具链 | `clean` 该项目后重新构建 |
| 可执行文件不存在 | `run` 的参数与实际构建的项目/配置不一致 | 检查 `bin/<配置>/<项目>/` |
| submodule 目录为空 | 未初始化 | `git submodule sync --recursive && git submodule update --init --recursive` |
| Hair Dryer 显示 `Image Not Found` | 不是从仓库根目录启动 | 用 `run` 脚本，或改用含 `hair_dryer.c` 的 Release 构建 |
