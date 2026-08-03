# LVGL Windows Simulator Workspace

This repository is the Windows SDL host for a set of LVGL application modules. The root project owns the common simulator, build integration, and developer scripts. LVGL, FreeRTOS, and every application under `projects/` are Git submodules.

## Components

| Path | Responsibility |
| --- | --- |
| `src/` | SDL display/input host, LVGL loop, and selected-project dispatch |
| `projects/` | Independently versioned application modules |
| `lvgl/` | LVGL upstream dependency |
| `FreeRTOS/` | Optional FreeRTOS kernel dependency |
| `CMakeLists.txt` | Host and application integration |
| `build.bat`, `run.bat`, `clean.bat` | Windows build, run, and cleanup entry points |
| `docs/` | Build modes, runtime controls, and integration APIs |

Generated files are kept under `build/` and `bin/` and are not source-controlled.

## Checkout

Clone the root repository and all dependencies:

```powershell
git clone --recursive https://github.com/patrickz-philips/lvgl_win_vscode.git
cd lvgl_win_vscode
```

For an existing checkout:

```powershell
git submodule sync --recursive
git submodule update --init --recursive
```

Keep vcpkg beside this repository:

```text
lvgl_projects/
|-- lvgl_win_vscode/
`-- vcpkg/
```

No build file should contain a machine-specific absolute vcpkg path.

## Prerequisites

- Windows 10 or later
- CMake 3.12.4 or later
- Visual Studio Build Tools or another CMake-supported C/C++ toolchain
- vcpkg at `../vcpkg`
- SDL2 installed for the selected vcpkg triplet

Install the default static dependency:

```powershell
..\vcpkg\vcpkg.exe install sdl2:x64-windows-static
```

## Build From The Root

The default build uses `x64-windows-static`, producing an executable that does not require the vcpkg SDL2 DLL at runtime:

```powershell
.\build.bat HAIR_DRYER Debug
.\run.bat HAIR_DRYER Debug
```

The default arguments are `HAIR_DRYER Debug`. Output is isolated by configuration and application:

```text
build/<Debug|Release>/<project>/
bin/<Debug|Release>/<project>/main.exe
```

For a DLL-dependent build, install `sdl2:x64-windows`, clean the project's existing CMake cache, and override the triplet:

```powershell
..\vcpkg\vcpkg.exe install sdl2:x64-windows
.\clean.bat HAIR_DRYER
$env:VCPKG_TARGET_TRIPLET = "x64-windows"
.\build.bat HAIR_DRYER Debug
Remove-Item Env:VCPKG_TARGET_TRIPLET
```

Static and dynamic triplets must not reuse the same CMake cache. See [docs/STANDALONE.md](docs/STANDALONE.md) for the runtime distinction and [docs/BUILD.md](docs/BUILD.md) for all targets and manual CMake commands.

## Submodule Development

Changes under `projects/*`, `lvgl/`, or `FreeRTOS/` belong to their respective repositories. Commit and push a submodule change first, then update the root repository's gitlink. Do not record a submodule commit that is unavailable from its remote.

## Documentation

- [Build guide](docs/BUILD.md)
- [Standalone and dependent builds](docs/STANDALONE.md)
- [Runtime controls and integration APIs](docs/USE.md)
- [中文构建说明](docs/%E6%9E%84%E5%BB%BA%E8%AF%B4%E6%98%8E.md)
- [中文使用说明](docs/%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E.md)
