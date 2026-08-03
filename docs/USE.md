# Usage Guide

This document covers the simulator controls and public integration APIs of the five implemented projects. Build instructions are in [BUILD.md](BUILD.md).

## Start a Project

Run commands from the repository root. The project and configuration must match an existing build:

```batch
build.bat SLIDE_PLAYER Debug
run.bat SLIDE_PLAYER Debug
```

The common SDL host registers mouse, mouse-wheel, and keyboard input. Close the SDL window to stop the application; `run.bat` then waits for a key before closing its console.

## Project Controls

### Hair Dryer

```batch
build.bat HAIR_DRYER Debug
run.bat HAIR_DRYER Debug
```

Use the mouse to operate the control panel:

- `Start`/`Stop` starts or stops the selected LED animation.
- `Ionizing` toggles the ionizing color behavior.
- `Low`, `Mid`, and `High` select animation speed.
- `Cold`, `Warm`, and `Hot` select the temperature color.
- `Style Breathe`, `Style Wave`, and `Style Pulse` select the animation pattern. Changing style stops the active run state.

Debug loads the PNG from the repository at runtime; Release normally uses the compiled C asset. The module header lays out the UI for 800 x 720.

### Cheetah

```batch
build.bat CHEETAH Debug
run.bat CHEETAH Debug
```

The value starts at 0 and is clamped to 0 through 100. Press Up/Right to increment and Down/Left to decrement. The SDL mouse-wheel encoder can also change the focused value.

### Slide Player

```batch
build.bat SLIDE_PLAYER Debug
run.bat SLIDE_PLAYER Debug
```

Hold the left mouse button and drag horizontally. A left gesture advances to the next image; a right gesture returns to the previous image. The viewer stops at the first and last image and displays the current `index/32` at the bottom.

### Battery Monitor

```batch
build.bat BATTERY_MONITOR Debug
run.bat BATTERY_MONITOR Debug
```

Hold the left mouse button and drag left or right to switch between the two pages. The simulator starts with example values. Page 1 shows temperature, battery/VBUS/system voltage, and battery percentage. Page 2 shows charging, discharge, standby, VBUS flags, and charge status.

### Accelerometer Data

```batch
build.bat ACC_DATA Debug
run.bat ACC_DATA Debug
```

The desktop entry only initializes the UI, so the chart remains at its initial values until host code pushes samples. There is no clickable record button on this simulator screen; the boot-button API is intended for an embedded host or another input adapter.

The chart keeps 125 points, representing a 2.5-second window when samples arrive every 20 ms.

## Integration APIs

Call all UI update functions from the LVGL thread. Initialize a module once before sending data.

### Battery Monitor Data

Include `projects/battery_monitor/inc/battery_monitor.h`, initialize the UI, and pass a complete structure:

```c
battery_monitor_data_t data = {
    .temperature = 26,
    .bat_voltage_mv = 3850,
    .vbus_voltage_mv = 5000,
    .system_voltage_mv = 3300,
    .bat_percent = 78,
    .is_charging = 1,
    .is_discharge = 0,
    .is_standby = 0,
    .is_vbus_in = 1,
    .is_vbus_good = 1,
    .charge_status = "Fast charge",
};

battery_monitor_ui_init();
battery_monitor_set_data(&data);
```

The structure is copied, but `charge_status` is a pointer and its string storage must remain valid while the UI uses it. Passing `NULL` to `battery_monitor_set_data` has no effect; a `NULL` status pointer is displayed as `Unknown`.

### Accelerometer Data

Include `projects/acc_data/inc/acc_data.h` and initialize the UI:

```c
acc_data_ui_init();
acc_data_set_battery_percent(82);
acc_data_push_sample(x_raw, y_raw, z_raw);
```

`acc_data_push_sample` expects signed raw 16-bit LSB values. Call it every `ACC_DATA_DISPLAY_PERIOD_MS` (20 ms) to maintain the intended window.

The boot-button state machine returns an action for the host:

```c
acc_data_record_action_t action = acc_data_handle_boot_button();
if(action == ACC_DATA_RECORD_ACTION_START) {
    /* Start recording samples. */
}
else if(action == ACC_DATA_RECORD_ACTION_STOP) {
    /* Stop and save recorded samples. */
}
```

After saving, call `acc_data_set_save_finished(true)` or `acc_data_set_save_finished(false)`. Call `acc_data_set_sdcard_missing()` when storage is unavailable. These functions only update UI state; file recording and SD-card access belong to the host application.

## Common Runtime Issues

- Hair Dryer shows `Image Not Found`: start it with `run.bat` from the repository root, or use a Release build containing `hair_dryer.c`.
- A drag does not switch pages: press and hold the left mouse button, move far enough horizontally, then release.
- ACC Data remains flat: the standalone simulator does not generate samples; connect a producer to `acc_data_push_sample`.
- The wrong executable starts: use the same project and Debug/Release arguments for both `build.bat` and `run.bat`.