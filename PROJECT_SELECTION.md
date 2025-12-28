# 项目选择说明 / Project Selection Guide

## 概述 / Overview

本项目支持在编译时选择不同的子项目：
- **HAIR_DRYER** (吹风机项目)
- **SMART_SHAVER** (智能剃须刀项目)

This project supports selecting different sub-projects at compile time:
- **HAIR_DRYER** (Hair Dryer Project)
- **SMART_SHAVER** (Smart Shaver Project)

## 使用方法 / Usage

### 方法 1：命令行配置 / Method 1: Command Line Configuration

在配置 CMake 时使用 `-DSELECTED_PROJECT` 参数：

```bash
# 构建 Hair Dryer 项目 / Build Hair Dryer Project
cmake -B build -DSELECTED_PROJECT=HAIR_DRYER
cmake --build build

# 或者构建 Smart Shaver 项目 / Or build Smart Shaver Project
cmake -B build -DSELECTED_PROJECT=SMART_SHAVER
cmake --build build
```

### 方法 2：修改 CMakeLists.txt / Method 2: Edit CMakeLists.txt

必须先 rm build/CMakeCache.txt
直接修改 `CMakeLists.txt` 文件中的默认选项：

```cmake
# 找到这一行 / Find this line:
set(SELECTED_PROJECT "HAIR_DRYER" CACHE STRING "Select project to build: HAIR_DRYER or SMART_SHAVER")

# 修改为 / Change to:
set(SELECTED_PROJECT "SMART_SHAVER" CACHE STRING "Select project to build: HAIR_DRYER or SMART_SHAVER")
```


## 项目特性 / Project Features

### HAIR_DRYER (吹风机)
- **屏幕尺寸 / Screen Size**: 800 x 480
- **初始化函数 / Init Function**: `hair_dryer_ui_init()`
- **功能 / Features**: 简单的UI界面，显示"Hair Dryer Project"设计

### SMART_SHAVER (智能剃须刀)
- **屏幕尺寸 / Screen Size**: 320 x 640
- **初始化函数 / Init Function**: `smart_shaver_ui_init()`
- **功能 / Features**:
  - 多页面滑动界面
  - 蓝牙和电池状态显示
  - 模式、连接、自动清洁、设置按钮
  - 支持 FFmpeg 视频播放（需要启用 LV_USE_FFMPEG）

## 编译定义 / Compile Definitions

根据选择的项目，会自动定义相应的宏：

- 选择 HAIR_DRYER 时定义：`PROJECT_HAIR_DRYER`
- 选择 SMART_SHAVER 时定义：`PROJECT_SMART_SHAVER`

这些宏在 `src/main.c` 中用于条件编译，以调用正确的初始化函数。

## 项目文件结构 / Project File Structure

```
.
├── hair_dryer/
│   ├── inc/
│   │   └── hair_dryer.h
│   └── src/
│       └── hair_dryer.c
├── smart_shaver/
│   ├── inc/
│   │   └── smart_shaver.h
│   └── src/
│       └── smart_shaver.c
├── src/
│   └── main.c              # 主程序（包含条件编译）
├── CMakeLists.txt          # CMake 配置（包含项目选择）
└── PROJECT_SELECTION.md    # 本说明文档
```

## 完整构建示例 / Complete Build Example

### Windows (PowerShell)

```powershell
# 清理之前的构建 / Clean previous build
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue

# 构建 Hair Dryer 项目 / Build Hair Dryer
cmake -B build -DSELECTED_PROJECT=HAIR_DRYER
cmake --build build

# 运行 / Run
.\bin\main.exe

# 切换到 Smart Shaver 项目 / Switch to Smart Shaver
Remove-Item -Recurse -Force build
cmake -B build -DSELECTED_PROJECT=SMART_SHAVER
cmake --build build
.\bin\main.exe
```

### Linux/WSL

```bash
# 清理之前的构建 / Clean previous build
rm -rf build

# 构建 Hair Dryer 项目 / Build Hair Dryer
cmake -B build -DSELECTED_PROJECT=HAIR_DRYER
cmake --build build

# 运行 / Run
./bin/main

# 切换到 Smart Shaver 项目 / Switch to Smart Shaver
rm -rf build
cmake -B build -DSELECTED_PROJECT=SMART_SHAVER
cmake --build build
./bin/main
```

## 注意事项 / Notes

1. 切换项目时建议清理 `build` 目录，以确保所有配置正确生效
2. Smart Shaver 项目的视频播放功能需要启用 `LV_USE_FFMPEG` 选项
3. 两个项目的屏幕尺寸不同，窗口大小会自动调整
4. 如果选择了无效的项目名称，CMake 配置会失败并提示错误

---

**最后更新 / Last Updated**: 2025-12-29
