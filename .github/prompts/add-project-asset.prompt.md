---
mode: agent
description: Add an image asset to an existing LVGL project with Debug runtime loading and Release static compilation.
---

Add an image asset to an existing project module. Before writing any file, ask the user for:

1. **Project name** — must already exist under `projects/`, e.g. `battery_monitor`
2. **Asset file name** — the PNG source file that will be placed in `projects/<name>/assets/`, e.g. `gauge.png`
3. **C variable name** — the identifier used in the C array and `LV_IMAGE_DECLARE`, e.g. `gauge_img`

Then perform every step below. Follow all rules in
`.github/instructions/build.instructions.md` and
`.github/instructions/lvgl-app.instructions.md`.

---

## Asset strategy

| Build type | How the image is loaded | Controlled by |
|------------|------------------------|---------------|
| Debug | `lv_image_set_src(obj, "projects/<name>/assets/<file>.png")` at runtime | No define needed |
| Release | Compiled C array declared with `LV_IMAGE_DECLARE(<var>)` | `USE_STATIC_ASSETS` defined by CMakeLists |

---

## Conversion script to create

### `projects/<name>/assets/convert_<var>.py`

```python
#!/usr/bin/env python3
"""Convert <file>.png to a C array for static compilation. Requires: pip install pillow"""

import sys
from pathlib import Path

def main():
    try:
        from PIL import Image
    except ImportError:
        print("Error: Pillow not found. Install with: pip install pillow")
        sys.exit(1)

    script_dir = Path(__file__).parent
    png_path = script_dir / "<file>.png"
    out_path = script_dir / "<var>.c"

    img = Image.open(png_path).convert("RGBA")
    w, h = img.size
    pixels = list(img.getdata())

    lines = [
        '#include "lvgl.h"',
        "",
        f"static const uint8_t <var>_map[] = {{",
    ]
    for i, (r, g, b, a) in enumerate(pixels):
        sep = "," if i < len(pixels) - 1 else ""
        lines.append(f"    0x{b:02x}, 0x{g:02x}, 0x{r:02x}, 0x{a:02x}{sep}")
    lines += [
        "};",
        "",
        f"const lv_image_dsc_t <var> = {{",
        "    .header = {",
        "        .cf = LV_COLOR_FORMAT_ARGB8888,",
        f"        .w  = {w},",
        f"        .h  = {h},",
        "    },",
        f"    .data_size = {w * h * 4},",
        "    .data      = <var>_map,",
        "};",
        "",
    ]
    out_path.write_text("\n".join(lines))
    print(f"Generated {out_path}")

if __name__ == "__main__":
    main()
```

---

## CMakeLists.txt changes

Inside the existing `if(SELECTED_PROJECT STREQUAL "<NAME>")` block, add after the existing
`list(APPEND MAIN_SOURCES ...)` call:

```cmake
    # Release uses compiled asset; Debug loads PNG at runtime
    if(CMAKE_BUILD_TYPE STREQUAL "Release")
        if(EXISTS "${PROJECTS_DIR}/<name>/assets/<var>.c")
            list(APPEND MAIN_SOURCES ${PROJECTS_DIR}/<name>/assets/<var>.c)
            add_compile_definitions(USE_STATIC_ASSETS)
            message(STATUS "Release: using static asset <var>.c")
        else()
            message(WARNING "Release: static asset <var>.c not found — run convert_<var>.py first")
        endif()
    endif()
```

---

## Source file changes

### In `projects/<name>/inc/<name>.h` or the View header

Add the extern declaration inside the `extern "C"` block:

```c
#ifdef USE_STATIC_ASSETS
LV_IMAGE_DECLARE(<var>);
#endif
```

### In the View source where the image widget is set

```c
#ifdef USE_STATIC_ASSETS
    lv_image_set_src(img_obj, &<var>);
#else
    lv_image_set_src(img_obj, "projects/<name>/assets/<file>.png");
#endif
```

---

## Build script changes (`build.bat` and `build.sh`)

For `build.bat`, add a pre-build block inside the `if /i "%PROJECT%"=="<NAME>" if /i "%BUILD_TYPE%"=="Release"` branch (mirror the existing Hair Dryer pattern):

```batch
if not exist "projects\<name>\assets\<var>.c" (
    echo [Pre-build] Converting <file>.png to C array...
    python projects\<name>\assets\convert_<var>.py
    if errorlevel 1 (
        echo WARNING: Image conversion failed. Continuing with runtime load.
    )
)
```

For `build.sh`, add inside a `if [[ "$PROJECT" == "<NAME>" && "$BUILD_TYPE" == "Release" ]]` block:

```bash
if [[ ! -f "$SCRIPT_DIR/projects/<name>/assets/<var>.c" ]]; then
    echo "[Pre-build] Converting <file>.png to C array..."
    python3 "$SCRIPT_DIR/projects/<name>/assets/convert_<var>.py" || \
        echo "WARNING: Image conversion failed. Continuing with runtime load."
fi
```

---

## docs/BUILD.md — Asset Handling section

Add a line to the Asset Handling table:

```
- <Name> Debug loads `projects/<name>/assets/<file>.png` at runtime.
- <Name> Release compiles `<var>.c`; if absent, the build script runs `convert_<var>.py`.
```
