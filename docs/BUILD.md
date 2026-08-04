# Build Guide

This guide covers the build flow for both Windows and macOS. Runtime controls and public module APIs are documented in [USE.md](USE.md). Static and dependency-linked builds are compared in [STANDALONE.md](STANDALONE.md).

## Repository Layout

The root repository is the build host. It owns SDL initialization, LVGL scheduling, project selection, and the final `main.exe`. The following paths are Git submodules:

- `lvgl/`: LVGL source dependency.
- `FreeRTOS/`: optional kernel dependency.
- `projects/*`: independently versioned application modules.

Initialize a checkout before building:

```powershell
git submodule sync --recursive
git submodule update --init --recursive
```

## Supported Projects

| Project argument | Source directory | Simulator size |
| --- | --- | --- |
| `HAIR_DRYER` | `projects/hair_dryer` | 800 x 720 |
| `SMART_SHAVER` | `projects/smart_shaver` | 320 x 640 |
| `CHEETAH` | `projects/cheetah` | 96 x 96 |
| `SLIDE_PLAYER` | `projects/slide_player` | 466 x 466 |
| `BATTERY_MONITOR` | `projects/battery_monitor` | 410 x 502 |
| `ACC_DATA` | `projects/acc_data` | 410 x 502 |

Each module declares its simulator dimensions in its public header. `src/main.c` adapts module-specific names where necessary and falls back to 320 x 480 if a module provides no dimensions. CMake does not own screen dimensions.

## Prerequisites

### Windows

- Windows 10 or later.
- CMake 3.12.4 or later in `PATH`.
- A C/C++ toolchain supported by CMake, such as Visual Studio Build Tools.
- vcpkg in the sibling directory `../vcpkg`.
- SDL2 installed for the selected vcpkg triplet.
- Python 3 and Pillow only when regenerating Hair Dryer image assets.

Expected directory layout:

```text
lvgl_projects/
`-- vcpkg/
```

Install the default SDL2 package from the repository root:

```powershell
..\vcpkg\vcpkg.exe install sdl2:x64-windows-static
```

### macOS

- macOS 12 or later.
- Xcode Command Line Tools: `xcode-select --install`
- CMake 3.12.4 or later: `brew install cmake`
- vcpkg in the sibling directory `../vcpkg`.
- SDL2 installed for the detected triplet (Apple Silicon uses `arm64-osx`; Intel uses `x64-osx`).

Expected directory layout:

```text
lvgl_projects/
`-- vcpkg/
```

Install SDL2 from the repository root (Apple Silicon):

```bash
../vcpkg/vcpkg install sdl2:arm64-osx
```

For Intel Mac:

```bash
../vcpkg/vcpkg install sdl2:x64-osx
```

## Scripted Build

### Windows

Run commands from the repository root:

```powershell
.\build.bat [PROJECT] [Debug|Release]
```

Both arguments are optional. The default is `HAIR_DRYER Debug`; arguments are case-insensitive.

```powershell
.\build.bat SMART_SHAVER Debug
.\build.bat CHEETAH Debug
.\build.bat SLIDE_PLAYER Release
.\build.bat BATTERY_MONITOR Debug
.\build.bat ACC_DATA Release
```

The default vcpkg triplet is `x64-windows-static`. Override it for the current shell with `VCPKG_TARGET_TRIPLET`. Clean that project's build directory before changing triplets because CMake toolchains are selected when a build tree is first configured.

```powershell
.\clean.bat HAIR_DRYER
$env:VCPKG_TARGET_TRIPLET = "x64-windows"
.\build.bat HAIR_DRYER Debug
Remove-Item Env:VCPKG_TARGET_TRIPLET
```

Build and executable outputs are isolated by configuration and project:

```text
build/<Debug|Release>/<project>/
bin/<Debug|Release>/<project>/main.exe
```

### macOS

Run commands from the repository root:

```bash
./build.sh [PROJECT] [Debug|Release]
```

Both arguments are optional. The default is `HAIR_DRYER Debug`; arguments are case-insensitive.

```bash
./build.sh SMART_SHAVER Debug
./build.sh CHEETAH Debug
./build.sh SLIDE_PLAYER Release
./build.sh BATTERY_MONITOR Debug
./build.sh ACC_DATA Release
```

The triplet is auto-detected (`arm64-osx` on Apple Silicon, `x64-osx` on Intel). Override with `VCPKG_TARGET_TRIPLET` if needed. Clean before switching triplets.

Build and executable outputs:

```text
build/<Debug|Release>/<project>/
bin/<Debug|Release>/<project>/main
```

## Run

Build and run the same project/configuration pair.

**Windows:**
```powershell
.\run.bat BATTERY_MONITOR Debug
```

**macOS:**
```bash
./run.sh BATTERY_MONITOR Debug
```

Both scripts start the executable with the repository root as the working directory, which is required for runtime assets that use repository-relative paths.

## Clean

**Windows:** `.\clean.bat [TARGET]`  
**macOS:** `./clean.sh [TARGET]`

```powershell
.\clean.bat [TARGET]
```

| Target | Removed paths |
| --- | --- |
| `all` or omitted | Entire `build/` and `bin/` directories |
| `build` | Entire `build/` directory |
| `bin` | Entire `bin/` directory |
| Project argument | That project's Debug and Release directories under `build/` and `bin/` |

## Manual CMake Build

Use a separate build directory for every project, configuration, and vcpkg triplet.

**Windows** (default Hair Dryer Debug):

```powershell
cmake -S . -B build/Debug/hair_dryer `
  -DCMAKE_BUILD_TYPE=Debug `
  -DSELECTED_PROJECT=HAIR_DRYER `
  -DVCPKG_TARGET_TRIPLET=x64-windows-static `
  -DCMAKE_TOOLCHAIN_FILE="../vcpkg/scripts/buildsystems/vcpkg.cmake"
cmake --build build/Debug/hair_dryer --config Debug -j
```

**macOS / Apple Silicon** (default Hair Dryer Debug):

```bash
cmake -S . -B build/Debug/hair_dryer \
  -DCMAKE_BUILD_TYPE=Debug \
  -DSELECTED_PROJECT=HAIR_DRYER \
  -DVCPKG_TARGET_TRIPLET=arm64-osx \
  -DCMAKE_TOOLCHAIN_FILE="../vcpkg/scripts/buildsystems/vcpkg.cmake"
cmake --build build/Debug/hair_dryer --config Debug -j
```

Useful optional settings:

| Setting | Default | Purpose |
| --- | --- | --- |
| `USE_FREERTOS` | `OFF` | Build the experimental FreeRTOS host path |
| `LVGL_PRO_PROJECT_DIR` | Empty | Add an LVGL Pro project containing a `CMakeLists.txt` |
| `LV_USE_DRAW_SDL` | `OFF` | Enable the SDL draw unit and SDL2_image dependency |
| `LV_USE_LIBPNG` | `OFF` | Link libpng |
| `LV_USE_LIBJPEG_TURBO` | `OFF` | Link libjpeg-turbo |
| `LV_USE_FFMPEG` | `OFF` | Link FFmpeg |
| `LV_USE_FREETYPE` | `OFF` | Link FreeType |

The normal host disables LVGL examples, demos, and internal ThorVG. `USE_FREERTOS=ON` currently builds the separate demonstration path in `src/freertos_main.c`; it does not initialize the selected application module.

## Asset Handling

- Hair Dryer Debug loads `projects/hair_dryer/assets/hair_dryer.png` at runtime.
- Hair Dryer Release compiles `hair_dryer.c`; if it is absent, `build.bat` attempts to run the Python converter.
- Cheetah compiles the asset C sources listed explicitly in `CMakeLists.txt`.
- Slide Player compiles numbered `assets/*.c` files and fails configuration when none exist.
- Smart Shaver, Battery Monitor, and the desktop ACC Data UI do not add image asset sources in the root build.
- `projects/acc_data/src/model.c` is an embedded ESP-IDF integration layer and is not part of the Windows SDL target.

## Submodule Development

Commit and push changes inside a project repository before updating the root gitlink:

```powershell
git -C projects/<name> status
git -C projects/<name> add <files>
git -C projects/<name> commit -m "..."
git -C projects/<name> push
git add projects/<name>
```

The root repository must not reference a submodule commit that is unavailable from its remote.

## Troubleshooting

### vcpkg toolchain not found

Confirm `../vcpkg/scripts/buildsystems/vcpkg.cmake` exists relative to the repository root. Do not replace it with a machine-specific absolute path.

### SDL2 not found

**Windows** — install SDL2 for the triplet shown by `build.bat`:

```powershell
..\vcpkg\vcpkg.exe install sdl2:x64-windows-static
```

**macOS** — install for the detected triplet:

```bash
../vcpkg/vcpkg install sdl2:arm64-osx   # Apple Silicon
../vcpkg/vcpkg install sdl2:x64-osx     # Intel
```

### Stale CMake configuration

Clean only the affected project, then rebuild:

```powershell
.\clean.bat SLIDE_PLAYER
.\build.bat SLIDE_PLAYER Debug
```

### Executable not found

The arguments passed to `run.bat` must match a successful build. Check `bin/<configuration>/<project>/main.exe`.

### Submodule directory is empty

```powershell
git submodule sync --recursive
git submodule update --init --recursive
```
