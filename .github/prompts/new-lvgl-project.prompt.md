---
mode: agent
description: Scaffold a new LVGL MVP project module and register it across all build files.
---

Scaffold a new LVGL project module. Before writing any file, ask the user for:

1. **Project name** — lowercase with underscores, e.g. `my_widget`
2. **Screen width** — integer pixels, e.g. `320`
3. **Screen height** — integer pixels, e.g. `480`

Then perform every step below. Follow all rules in
`.github/instructions/build.instructions.md` and
`.github/instructions/lvgl-app.instructions.md`.

---

## Files to create

### `projects/<name>/inc/<name>.h`
Public header — only the init entry point and any hardware-facing data-push API:
```c
#ifndef <NAME>_H
#define <NAME>_H

#ifdef __cplusplus
extern "C" {
#endif

#define WIDGET_SCREEN_WIDTH  <width>
#define WIDGET_SCREEN_HEIGHT <height>

void <name>_ui_init(void);

#ifdef __cplusplus
}
#endif

#endif /* <NAME>_H */
```

### `projects/<name>/inc/<name>_model.h`
Model types and interface — no LVGL types:
```c
#ifndef <NAME>_MODEL_H
#define <NAME>_MODEL_H

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    /* add data fields here */
} <name>_data_t;

void <name>_model_init(void);

#ifdef __cplusplus
}
#endif

#endif /* <NAME>_MODEL_H */
```

### `projects/<name>/src/<name>_model.c`
Model layer — hardware calls wrapped in `#ifndef LV_SIMULATOR`:
```c
#include "<name>_model.h"

void <name>_model_init(void)
{
#ifndef LV_SIMULATOR
    /* initialize hardware peripherals here */
#endif
}
```

### `projects/<name>/inc/<name>_view.h`
View interface — widget creation and update functions only:
```c
#ifndef <NAME>_VIEW_H
#define <NAME>_VIEW_H

#include "lvgl.h"

#ifdef __cplusplus
extern "C" {
#endif

void <name>_view_create(lv_obj_t *parent);
/* void <name>_view_set_<field>(<type> value); */

#ifdef __cplusplus
}
#endif

#endif /* <NAME>_VIEW_H */
```

### `projects/<name>/src/<name>_view.c`
View layer — all lv_obj_create calls; no application state:
```c
#include "<name>_view.h"

typedef struct {
    /* lv_obj_t *<widget>; */
} <name>_ctx_t;

static <name>_ctx_t g_ctx;

void <name>_view_create(lv_obj_t *parent)
{
    /* create widgets and store in g_ctx */
    (void)parent;
}
```

### `projects/<name>/src/<name>.c`
Presenter / entry point — bridges Model and View:
```c
#include "<name>.h"
#include "<name>_model.h"
#include "<name>_view.h"

/* static void on_<event>(lv_event_t *e) { ... } */

void <name>_ui_init(void)
{
    <name>_model_init();
    <name>_view_create(lv_scr_act());
}
```

---

## Files to modify

### `CMakeLists.txt`
1. In `set_property(CACHE SELECTED_PROJECT PROPERTY STRINGS ...)`, append `"<NAME>"`.
2. Add a new `elseif` block before the closing `else` / `endif`:
```cmake
elseif(SELECTED_PROJECT STREQUAL "<NAME>")
    message(STATUS "Building <Name> Project")
    add_compile_definitions(PROJECT_<NAME>)
    list(APPEND MAIN_SOURCES
        ${PROJECTS_DIR}/<name>/src/<name>.c
        ${PROJECTS_DIR}/<name>/src/<name>_model.c
        ${PROJECTS_DIR}/<name>/src/<name>_view.c
    )
    include_directories(${PROJECTS_DIR}/<name>/inc)
```

### `src/main.c`
Add an `#elif` branch in both the include block and the init dispatch block:
```c
#elif defined(PROJECT_<NAME>)
#include "<name>.h"
```
```c
#elif defined(PROJECT_<NAME>)
    <name>_ui_init();
```

### `build.bat` and `build.sh`
Add `<NAME>` to the valid-project case list and the error message listing valid projects.

### `run.bat` and `run.sh`
Add `<NAME>` to the valid-project case list.

### `clean.bat` and `clean.sh`
Add `<NAME>` to the valid-project case list if they enumerate projects explicitly.

### `docs/BUILD.md`
Add a row to the Supported Projects table:
```
| `<NAME>` | `projects/<name>` | <width> x <height> |
```
