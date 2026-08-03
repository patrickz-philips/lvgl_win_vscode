# Build Guide

This document describes the Windows build flow implemented by the root CMake project and batch scripts. For application controls and module APIs, see [USE.md](USE.md).

## Supported Projects

| Project argument | Module | Default window |
| --- | --- | --- |
| `HAIR_DRYER` | Hair dryer controls and LED animation | 800 x 720 |
| `CHEETAH` | Compact numeric widget | 96 x 96 |
| `SLIDE_PLAYER` | 32-image slide viewer | 466 x 466 |
| `BATTERY_MONITOR` | Two-page battery status viewer | 410 x 502 |
| `ACC_DATA` | Three-axis accelerometer chart | 410 x 502 |

`SMART_SHAVER` is still accepted by the legacy script and CMake selection lists, but its source directory is not present. It is not a buildable project in this checkout.

## Prerequisites

- Windows 10 or later.
- CMake 3.12.4 or later available in `PATH`.
- A C/C++ toolchain supported by CMake, such as Visual Studio Build Tools.
- vcpkg in the sibling directory `..\vcpkg`.
- SDL2 installed for the `x64-windows-static` triplet.
- Python 3 and Pillow only when regenerating the Hair Dryer C asset.

The build script always passes `..\vcpkg\scripts\buildsystems\vcpkg.cmake`; installing vcpkg elsewhere requires changing `VCPKG_TOOLCHAIN` in `build.bat` or configuring CMake manually.

One possible vcpkg setup from the repository root is:

```batch
cd ..
git clone https://github.com/microsoft/vcpkg.git
vcpkg\bootstrap-vcpkg.bat
vcpkg\vcpkg.exe install sdl2:x64-windows-static
cd lvgl_win_vscode
```

Verify the required tools:

```batch
cmake --version
..\vcpkg\vcpkg.exe list
```

## Build

Run commands from the repository root:

```batch
build.bat [PROJECT] [Debug|Release]
```

Both arguments are optional. The default is `HAIR_DRYER Debug`. Arguments are case-insensitive.

Examples:

```batch
build.bat
build.bat CHEETAH Debug
build.bat SLIDE_PLAYER Release
build.bat BATTERY_MONITOR Debug
build.bat ACC_DATA Release
```

The script configures an isolated CMake tree, then builds the `main` executable. Generated files are separated by configuration and project:

```text
build/<Debug|Release>/<project>/
bin/<Debug|Release>/<project>/main.exe
```

For example, `build.bat ACC_DATA Debug` creates `bin\Debug\acc_data\main.exe`.

### Hair Dryer Assets

Debug builds load `projects/hair_dryer/assets/hair_dryer.png` at runtime. Run them through `run.bat` so the process starts in the repository root.

Release builds compile `projects/hair_dryer/assets/hair_dryer.c` into the executable. If that file is missing, `build.bat` runs the converter before CMake configuration:

```batch
python -m pip install pillow
python projects\hair_dryer\assets\convert_image.py
```

The current checkout already contains the generated C file. `CHEETAH` and `SLIDE_PLAYER` compile their image C files into the executable in both configurations. Slide Player configuration fails when no numbered C assets exist under `projects/slide_player/assets`.

## Run

Build and run the same project/configuration pair:

```batch
run.bat BATTERY_MONITOR Debug
```

`run.bat` checks for `bin\<configuration>\<project>\main.exe` and starts it with the repository root as the working directory. See [USE.md](USE.md) for controls and data APIs.

## Clean

```batch
clean.bat [TARGET]
```

Targets are case-insensitive:

| Target | Removed paths |
| --- | --- |
| `all` or no argument | Entire `build` and `bin` directories |
| `build` | Entire `build` directory |
| `bin` | Entire `bin` directory |
| A project argument | That project's Debug and Release directories under both `build` and `bin` |

Examples:

```batch
clean.bat ACC_DATA
clean.bat build
clean.bat all
```

## Manual CMake Build

Use a separate build directory for each project and configuration. The following is equivalent to the scripted Hair Dryer Debug build:

```batch
cmake -B build\Debug\hair_dryer ^
  -DCMAKE_BUILD_TYPE=Debug ^
  -DSELECTED_PROJECT=HAIR_DRYER ^
  -DVCPKG_TARGET_TRIPLET=x64-windows-static ^
  -DCMAKE_TOOLCHAIN_FILE="..\vcpkg\scripts\buildsystems\vcpkg.cmake"
cmake --build build\Debug\hair_dryer --config Debug -j
```

Useful optional CMake settings include:

| Setting | Default | Purpose |
| --- | --- | --- |
| `USE_FREERTOS` | `OFF` | Build the experimental FreeRTOS host path |
| `LVGL_PRO_PROJECT_DIR` | Empty | Add an LVGL Pro project containing a `CMakeLists.txt` |
| `LV_USE_LIBPNG` | `OFF` | Link libpng from the toolchain |
| `LV_USE_LIBJPEG_TURBO` | `OFF` | Link libjpeg-turbo from the toolchain |
| `LV_USE_FREETYPE` | `OFF` | Link FreeType from the toolchain |

The normal project builds disable LVGL examples, demos, and internal ThorVG. Window sizes are defined by the selected module headers; changing them requires keeping the module layout and CMake definitions consistent.

## Troubleshooting

### CMake is not found

Install CMake, reopen the terminal, and verify `cmake --version`. `build.bat` stops before configuration when CMake is absent from `PATH`.

### The vcpkg toolchain file is missing

Confirm `..\vcpkg\scripts\buildsystems\vcpkg.cmake` exists relative to the repository root.

### SDL2 is not found

Install the exact triplet used by the scripts:

```batch
..\vcpkg\vcpkg.exe install sdl2:x64-windows-static
```

### CMake reuses stale project settings

Each project has its own cache. Remove only the affected project and rebuild:

```batch
clean.bat SLIDE_PLAYER
build.bat SLIDE_PLAYER Debug
```

### Hair Dryer image conversion fails

Install Pillow with the same Python interpreter used by the script, then rerun the build. A conversion failure does not stop the build, but Release falls back to filesystem loading when the generated C asset is unavailable.

### The executable is missing

The project and configuration passed to `run.bat` must match the successful build. Check the expected path under `bin`, or rebuild that exact pair.# LVGL 项目构建指南

## 📁 目录结构

本项目采用清晰的目录结构，将构建文件和输出文件分离：

```
lv_port_pc_vscode/
├── bin/                          # 可执行文件输出目录
│   ├── Debug/                    # Debug版本输出
│   │   ├── hair_dryer/          # Hair Dryer项目Debug版本
│   │   │   ├── main.exe
│   │   │   ├── SDL2d.dll
│   │   │   └── lib/             # 静态库
│   │   └── smart_shaver/        # Smart Shaver项目Debug版本
│   │       └── main.exe
│   └── Release/                  # Release版本输出
│       ├── hair_dryer/          # Hair Dryer项目Release版本
│       └── smart_shaver/        # Smart Shaver项目Release版本
├── build/                        # CMake构建临时文件
│   ├── Debug/
│   │   ├── hair_dryer/          # Hair Dryer项目Debug构建文件
│   │   └── smart_shaver/        # Smart Shaver项目Debug构建文件
│   └── Release/
│       ├── hair_dryer/          # Hair Dryer项目Release构建文件
│       └── smart_shaver/        # Smart Shaver项目Release构建文件
├── projects/                     # 工程源码
│   ├── acc_data/
│   ├── battery_monitor/
│   ├── cheetah/
│   ├── hair_dryer/
│   └── slide_player/
├── smart_shaver/                 # Smart Shaver项目源码
├── lvgl/                         # LVGL库
└── src/                          # 公共源码
```

## 🛠️ 构建脚本

### 1. build.bat - 统一构建脚本

**用法：**
```batch
build.bat [PROJECT] [BUILD_TYPE]
```

**参数：**
  - `HAIR_DRYER` (默认)
  - `SMART_SHAVER`
  - `CHEETAH`
  - `SLIDE_PLAYER`
  - `BATTERY_MONITOR`
  - `Debug` (默认)
  - `Release`

**示例：**
```batch
# 构建 Hair Dryer 项目 - Debug 模式（默认）
build.bat

# 构建 Hair Dryer 项目 - Debug 模式
build.bat HAIR_DRYER Debug

# 构建 Hair Dryer 项目 - Release 模式
build.bat HAIR_DRYER Release

# 构建 Smart Shaver 项目 - Debug 模式
build.bat SMART_SHAVER Debug

# 构建 Smart Shaver 项目 - Release 模式
build.bat SMART_SHAVER Release

# 构建 Battery Monitor 项目 - Debug 模式
build.bat BATTERY_MONITOR Debug
```

### 2. run.bat - 运行脚本

**用法：**
```batch
run.bat [PROJECT] [BUILD_TYPE]
```

**参数：**同 build.bat

**示例：**
```batch
# 运行 Hair Dryer 项目 - Debug 版本
run.bat

# 运行 Hair Dryer 项目 - Release 版本
run.bat HAIR_DRYER Release

# 运行 Smart Shaver 项目 - Debug 版本
run.bat SMART_SHAVER Debug

# 运行 Battery Monitor 项目 - Debug 版本
run.bat BATTERY_MONITOR Debug
```

### 3. clean.bat - 清理脚本

**用法：**
```batch
clean.bat [TARGET]
```

**参数：**

**示例：**
```batch
# 清理所有
clean.bat
clean.bat all

# 仅清理构建文件
clean.bat build

# 仅清理输出文件
clean.bat bin

# 仅清理 Hair Dryer 项目
clean.bat HAIR_DRYER

# 仅清理 Smart Shaver 项目
clean.bat SMART_SHAVER

# 仅清理 Battery Monitor 项目
clean.bat BATTERY_MONITOR
```

## 🎯 构建特性

### Debug vs Release 构建

#### Debug 模式

#### Release 模式

### 项目特定配置

#### Hair Dryer 项目
  - 如果不存在，自动运行 `convert_image.py` 转换图片
  - 需要 Python 和 Pillow 库

#### Smart Shaver 项目

#### Battery Monitor 项目

## 🔧 编译优化

### 仅编译必要的库

本项目已优化CMake配置，**仅编译必要的LVGL组件**：

✅ **编译的组件：**

❌ **不编译的组件：**

**优势：**

## 📦 依赖要求

### 必需依赖

### 可选依赖

### 安装SDL2（使用vcpkg）
```batch
# 如果还没有安装 vcpkg，请先安装
git clone https://github.com/Microsoft/vcpkg.git D:\vcpkg
cd D:\vcpkg
bootstrap-vcpkg.bat

# 安装 SDL2
vcpkg install sdl2:x64-windows
vcpkg integrate install
```

### 安装Python依赖（可选）
```batch
pip install pillow
```

## 🚀 快速开始

### 第一次构建
```batch
# 1. 克隆或下载项目
cd lv_port_pc_vscode

# 2. 构建 Debug 版本（默认）
build.bat

# 3. 运行
run.bat
```

### 开发工作流

#### Debug 开发流程
```batch
# 修改代码后
build.bat HAIR_DRYER Debug
run.bat HAIR_DRYER Debug
```

#### Release 发布流程
```batch
# 准备发布版本
build.bat HAIR_DRYER Release
run.bat HAIR_DRYER Release
```

## 🐛 故障排除

### 问题：CMake找不到SDL2
**解决方案：**
1. 确保安装了vcpkg
2. 检查 `CMakeLists.txt` 中的vcpkg路径
3. 运行 `vcpkg integrate install`

### 问题：Hair Dryer Release模式图片转换失败
**解决方案：**
1. 安装Python: `pip install pillow`
2. 或手动转换图片：访问 https://lvgl.io/tools/imageconverter
3. 或使用Debug模式（使用动态加载）

### 问题：构建文件混乱
**解决方案：**
```batch
# 清理所有构建文件
clean.bat all

# 重新构建
build.bat [PROJECT] [BUILD_TYPE]
```

## 📝 旧脚本迁移

如果你之前使用旧的构建脚本：

| 旧脚本 | 新脚本 |
|--------|--------|
| `build_debug.bat` | `build.bat HAIR_DRYER Debug` |
| `build_release.bat` | `build.bat HAIR_DRYER Release` |

**注意：** 旧脚本仍然可用，但建议使用新的统一脚本。

## 🔍 高级用法

### 直接使用CMake
```batch
# 配置
cmake -B build/Debug/hair_dryer ^
    -DCMAKE_BUILD_TYPE=Debug ^
    -DSELECTED_PROJECT=HAIR_DRYER

# 构建
cmake --build build/Debug/hair_dryer --config Debug -j

# 运行
bin\Debug\hair_dryer\main.exe
```

### 启用FreeRTOS（实验性）
```batch
cmake -B build/Debug/hair_dryer ^
    -DCMAKE_BUILD_TYPE=Debug ^
    -DSELECTED_PROJECT=HAIR_DRYER ^
    -DUSE_FREERTOS=ON
```

## 📚 相关文档


## 💡 最佳实践

1. **开发阶段**: 使用 Debug 模式，获得快速编译和完整调试信息
2. **测试阶段**: 使用 Release 模式，测试最终性能
3. **定期清理**: 遇到奇怪问题时，使用 `clean.bat all` 清理后重新构建
4. **项目隔离**: 不同项目的构建文件互不干扰，可以同时保留多个项目的构建结果

## 🎓 总结

通过新的构建系统，你可以：

祝编码愉快！ 🚀

