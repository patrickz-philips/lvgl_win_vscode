# Standalone And Dependent Builds

The application repositories under `projects/` are LVGL modules, not complete desktop programs. They do not contain the SDL host, LVGL scheduler, dependency discovery, or executable entry point. Build an application-specific executable from the root repository by selecting its `SELECTED_PROJECT` value.

In this documentation, **standalone** means the resulting Windows executable does not require the vcpkg SDL2 DLL at runtime. It does not mean a `projects/*` submodule can be built by itself.

## Static Standalone Build

The default script uses the `x64-windows-static` triplet:

```powershell
..\vcpkg\vcpkg.exe install sdl2:x64-windows-static
.\build.bat SMART_SHAVER Release
```

Output:

```text
bin/Release/smart_shaver/main.exe
```

SDL2 is linked statically. The executable can be launched without copying the vcpkg SDL2 DLL beside it. Normal Windows system libraries remain operating-system dependencies.

## DLL-Dependent Build

Install SDL2 for the dynamic triplet, clean the existing project cache, and override the environment variable:

```powershell
..\vcpkg\vcpkg.exe install sdl2:x64-windows
.\clean.bat SMART_SHAVER
$env:VCPKG_TARGET_TRIPLET = "x64-windows"
.\build.bat SMART_SHAVER Release
Remove-Item Env:VCPKG_TARGET_TRIPLET
```

This mode depends on the runtime DLLs supplied by the selected vcpkg triplet. CMake/vcpkg may copy runtime dependencies into the output directory; otherwise they must be discoverable through the executable directory or `PATH`.

## Cache Isolation

A CMake build tree retains its compiler and toolchain. Do not switch between `x64-windows-static` and `x64-windows` in the same cached project directory without cleaning it first:

```powershell
.\clean.bat <PROJECT>
```

For manual workflows that need both modes at once, use separate build directories, for example:

```text
build/Debug/hair_dryer-static/
build/Debug/hair_dryer-dynamic/
```

## What The Root Host Supplies

Every project-specific executable is composed from:

- the SDL display and input host under `src/hal/`;
- the LVGL loop and selected-project dispatch in `src/main.c`;
- LVGL from the `lvgl/` submodule;
- one application module from `projects/`;
- assets selected by the root `CMakeLists.txt`;
- SDL2 and any optional libraries supplied by vcpkg.

Project modules can still be reused by another host, but that host must provide LVGL initialization, display/input drivers, scheduling, include paths, assets, and the module's public API calls.

## Verification

After building, confirm the expected file exists and launch it with the matching arguments:

```powershell
Test-Path .\bin\Release\smart_shaver\main.exe
.\run.bat SMART_SHAVER Release
```

For distribution, test on a clean Windows environment that does not inherit the development vcpkg `PATH`. This distinguishes a genuinely static executable from one that only runs because development DLLs are globally discoverable.