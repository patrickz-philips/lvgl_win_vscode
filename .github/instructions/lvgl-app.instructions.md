---
description: "Use when changing the SDL host or an LVGL application module. Covers C APIs, screen dimensions, LVGL threading, and module boundaries."
applyTo: ["src/**/*.c", "src/**/*.h", "projects/*/src/**/*.c", "projects/*/inc/**/*.h"]
---
# LVGL Application Rules

- Use C99 for C sources and preserve each module's existing formatting.
- Expose C headers to C++ with `extern "C"` guards.
- Define screen dimensions in the module's public header when it requires a specific simulator size.
- Do not set project screen dimensions in CMake. `src/main.c` adapts module-specific dimension macros and owns the generic fallback for modules without dimensions.
- Keep the public initialization entry point named `<project>_ui_init(void)`.
- Call functions that create or update LVGL objects from the LVGL thread unless the module explicitly queues data for that thread.
- Treat UI initialization as single-use when the module stores static LVGL objects or timers and has no deinitialization API.
- Keep application-specific code in its `projects/<name>` submodule; keep shared SDL/LVGL host code under `src/`.