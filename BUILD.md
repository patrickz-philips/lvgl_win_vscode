# LVGL 项目构建指南

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
├── hair_dryer/                   # Hair Dryer项目源码
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
- `PROJECT`: 项目名称
  - `HAIR_DRYER` (默认)
  - `SMART_SHAVER`
- `BUILD_TYPE`: 构建类型
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
```

### 3. clean.bat - 清理脚本

**用法：**
```batch
clean.bat [TARGET]
```

**参数：**
- `all` (默认) - 清理所有构建文件和输出文件
- `build` - 仅清理构建临时文件
- `bin` - 仅清理输出文件
- `HAIR_DRYER` - 仅清理 Hair Dryer 项目
- `SMART_SHAVER` - 仅清理 Smart Shaver 项目

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
```

## 🎯 构建特性

### Debug vs Release 构建

#### Debug 模式
- **编译优化**: 关闭优化，保留调试符号
- **资源加载**: 动态从文件系统加载资源（如图片）
- **优点**: 快速编译，便于调试
- **输出**: `bin/Debug/<project>/main.exe`

#### Release 模式
- **编译优化**: 开启优化，移除调试信息
- **资源加载**: 静态编译资源到可执行文件（Hair Dryer项目）
- **优点**: 更小体积，更快运行速度
- **输出**: `bin/Release/<project>/main.exe`

### 项目特定配置

#### Hair Dryer 项目
- Debug模式：从 `hair_dryer/assets/` 加载 `hair_dryer.png`
- Release模式：使用静态编译的 `hair_dryer/assets/hair_dryer.c`
  - 如果不存在，自动运行 `convert_image.py` 转换图片
  - 需要 Python 和 Pillow 库

#### Smart Shaver 项目
- 标准构建流程
- 无特殊资源编译需求

## 🔧 编译优化

### 仅编译必要的库

本项目已优化CMake配置，**仅编译必要的LVGL组件**：

✅ **编译的组件：**
- LVGL 核心库
- SDL2 支持

❌ **不编译的组件：**
- LVGL Examples（示例代码）
- LVGL Demos（演示程序）
- ThorVG（矢量图形库）

**优势：**
- ⚡ 更快的编译速度
- 💾 更小的输出文件
- 🎯 只包含项目所需的代码

## 📦 依赖要求

### 必需依赖
- **CMake** >= 3.12.4
- **C/C++ 编译器**（MSVC、MinGW或Clang）
- **SDL2** 库（通过vcpkg安装）

### 可选依赖
- **Python 3** + **Pillow** - 用于 Hair Dryer Release 模式的图片转换

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

- [BUILD_STANDALONE.md](BUILD_STANDALONE.md) - 独立构建指南
- [PROJECT_SELECTION.md](PROJECT_SELECTION.md) - 项目选择说明
- [hair_dryer/assets/README.md](hair_dryer/assets/README.md) - Hair Dryer资源说明

## 💡 最佳实践

1. **开发阶段**: 使用 Debug 模式，获得快速编译和完整调试信息
2. **测试阶段**: 使用 Release 模式，测试最终性能
3. **定期清理**: 遇到奇怪问题时，使用 `clean.bat all` 清理后重新构建
4. **项目隔离**: 不同项目的构建文件互不干扰，可以同时保留多个项目的构建结果

## 🎓 总结

通过新的构建系统，你可以：
- ✅ 清晰分离不同项目的构建文件
- ✅ 轻松切换 Debug/Release 模式
- ✅ 快速构建（仅编译必要的库）
- ✅ 方便地清理和重建

祝编码愉快！ 🚀

