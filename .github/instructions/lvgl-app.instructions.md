---
description: "Use when changing the SDL host or an LVGL application module. Covers C APIs, screen dimensions, LVGL threading, module boundaries, MVP architecture, and simulator vs hardware guards."
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

## Simulator / Hardware Guard

- The SDL host defines `LV_SIMULATOR=1` for every PC build. Hardware (ESP-IDF) builds do not define it.
- Wrap all hardware-specific includes, calls, and types in `#ifndef LV_SIMULATOR` / `#endif`. Never include ESP-IDF headers (`esp_*.h`, FreeRTOS headers, BSP headers) outside this guard.
- Provide a no-op stub or omit the hardware path entirely for the simulator build so the module compiles and links without ESP-IDF.

## Model-View-Presenter Architecture

Every project module must follow MVP. Responsibilities per layer:

| Layer | File(s) | Owns |
|-------|---------|------|
| **Model** | `<project>_model.c` / `<project>_model.h` | Data, state, hardware I/O. Hardware calls wrapped in `#ifndef LV_SIMULATOR`. Exposes a push API or registers a callback set by the Presenter. |
| **View** | `<project>_view.c` / `<project>_view.h` | All `lv_obj_create` calls, layout, and styling. Exposes `<project>_view_set_*()` update functions. Holds no application state. |
| **Presenter** | `<project>.c` (entry point) | Registers LVGL event callbacks; calls Model push functions and View update functions. Owns no LVGL objects directly. |

- The public header `inc/<project>.h` exposes only `<project>_ui_init(void)` and any data-push API needed by the hardware application layer.
- Model data types shared between layers belong in `<project>_model.h`; keep them free of LVGL types.
- Do not let the View read from the Model directly; all data flow goes through the Presenter.

## Naming Conventions

- Name LVGL event callbacks with an `on_<event>` prefix: `static void on_gesture(lv_event_t *e)`.
- Name LVGL timer callbacks with a `_timer_cb` suffix: `static void stopwatch_timer_cb(lv_timer_t *timer)`. Suppress unused-parameter warnings with `(void)timer` when the handle is not used.
- Name the module context struct type `<project>_ctx_t` and its single static instance `g_ctx`.
- Prefix static module-scope handles (queues, timers, task handles) with `s_`: `s_event_queue`, `s_model_timer`.
- Define timer and update period constants as `#define <FEATURE>_PERIOD_MS <value>` at the top of the file.
- Name internal widget-creation helpers `create_<widget>(lv_obj_t *parent)`.

## Public API Contracts

- Data-input functions take a `const <type> *` parameter and copy the value internally (`g_ctx.data = *data`); never store an external pointer beyond the call.
- All public entry points that receive pointer arguments must guard with `if(ptr == NULL) return;` before any use.
- Do not expose LVGL object pointers or internal widget handles through the public header.

## Cross-Thread Data Transfer (FreeRTOS)

When a hardware Model task needs to deliver data to the LVGL thread:

- Declare the queue as `static QueueHandle_t s_<name>_queue` inside `#ifndef LV_SIMULATOR`.
- Define queue depth with a named constant at file scope: `static const UBaseType_t <NAME>_QUEUE_LEN = <n>U;`.
- Send value-type structs only (`xQueueSend` with a local copy); never send a pointer to a stack variable.
- Consume the queue exclusively in an `lv_timer_t` callback on the LVGL thread; never call `lv_obj_*` directly from a FreeRTOS task.
- Name the consumption timer `s_model_timer`; create it in the Model init with `lv_timer_create(<feature>_timer_cb, MODEL_TIMER_PERIOD_MS, NULL)`.
- Under `#ifdef LV_SIMULATOR`, provide a no-op stub for every `model_post_*()` function so the Presenter compiles without FreeRTOS.