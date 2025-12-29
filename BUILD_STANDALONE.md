# 编译独立的 main.exe（无依赖版本）

本文档说明如何编译生成一个不需要任何外部 DLL 依赖的独立 main.exe 文件到 bin/Release 目录。

## 前提条件

1. 已安装 Visual Studio（推荐 2019 或更高版本）
2. 已安装 CMake（3.12.4 或更高版本）
3. 已安装 vcpkg 并配置好路径（D:/vcpkg/）

## 步骤 1：安装静态版本的 SDL2

在 PowerShell 或命令提示符中运行：

```powershell
cd D:\vcpkg
.\vcpkg install sdl2:x64-windows-static
```

如果项目使用了其他库（如 libpng、libjpeg 等），也需要安装静态版本：

```powershell
.\vcpkg install libpng:x64-windows-static
.\vcpkg install libjpeg-turbo:x64-windows-static
.\vcpkg install freetype:x64-windows-static
```

## 步骤 2：清理旧的构建文件

删除或重命名 `build` 文件夹以确保重新生成配置：

```powershell
cd D:\lvgl_project\lv_port_pc_vscode
Remove-Item -Recurse -Force build
```

## 步骤 3：重新配置 CMake

使用静态链接配置重新生成项目：

```powershell
mkdir build
cd build
cmake .. -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Release -DVCPKG_TARGET_TRIPLET=x64-windows-static
```

**注意**：
- 如果使用 Visual Studio 2019，替换为 `"Visual Studio 16 2019"`
- 如果使用 Visual Studio 2015，替换为 `"Visual Studio 14 2015"`

## 步骤 4：编译 Release 版本

### 方法 A：使用 CMake 命令行编译

```powershell
cmake --build . --config Release
```

### 方法 B：使用 Visual Studio IDE 编译

1. 打开 `build\lvgl.sln`
2. 在顶部工具栏选择 "Release" 配置
3. 右键点击 `main` 项目，选择 "生成"

## 步骤 5：验证结果

编译完成后，检查生成的文件：

```powershell
cd ..\bin\Release
dir
```

你应该只看到 `main.exe` 和相关的 `.lib`、`.exp` 文件，**不应该有任何 .dll 文件**。

## 测试独立性

将 `main.exe` 复制到另一个目录并运行，确保它不需要任何额外的 DLL：

```powershell
mkdir D:\test
copy main.exe D:\test\
cd D:\test
.\main.exe
```

如果程序能正常运行，说明已成功创建独立的可执行文件！

## 故障排除

### 问题 1：仍然依赖 SDL2.dll

**原因**：vcpkg 使用了动态库版本

**解决方法**：
1. 确保已安装 `sdl2:x64-windows-static`
2. 完全删除 build 目录并重新运行 cmake
3. 检查 CMake 配置输出是否使用了正确的 triplet

### 问题 2：链接错误（LNK2038 或 LNK2005）

**原因**：运行时库不匹配

**解决方法**：
已在 CMakeLists.txt 中配置为使用 `/MT`（Release）和 `/MTd`（Debug）静态运行时库。
如果仍有问题，清理并重新编译：

```powershell
cd build
cmake --build . --config Release --clean-first
```

### 问题 3：exe 文件过大

**原因**：静态链接会将所有库代码嵌入到 exe 中

**说明**：这是正常的。独立 exe 通常会比需要 DLL 的版本大 2-10MB。这是为了实现完全独立所付出的代价。

### 问题 4：找不到 vcpkg

**解决方法**：
确保 vcpkg 已正确安装在 `D:\vcpkg\`，或修改 `CMakeLists.txt` 第 5 行的路径：

```cmake
if(EXISTS "你的vcpkg路径/scripts/buildsystems/vcpkg.cmake")
```

## 文件大小对比

- **动态链接版本**：main.exe (~500KB) + SDL2.dll (~1MB) = 约 1.5MB
- **静态链接版本**：main.exe (~3-5MB) = 约 3-5MB

静态链接版本的优势：
✅ 单文件分发，无需携带 DLL
✅ 避免 DLL 版本冲突
✅ 更易于部署和分发

## CMakeLists.txt 关键配置

已添加以下配置到 CMakeLists.txt：

1. **vcpkg 静态 triplet**（第 12-15 行）：
```cmake
if(NOT DEFINED VCPKG_TARGET_TRIPLET)
    set(VCPKG_TARGET_TRIPLET "x64-windows-static" CACHE STRING "")
endif()
```

2. **MSVC 静态运行时库**（第 71-78 行）：
```cmake
if(MSVC)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
    add_compile_options(
        $<$<CONFIG:Release>:/MT>
        $<$<CONFIG:Debug>:/MTd>
    )
endif()
```

这些配置确保了所有依赖都使用静态链接。

