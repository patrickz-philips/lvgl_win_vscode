# Project Guidelines

## Communication

- Answer in Chinese unless the user requests another language.
- Write source comments, log messages, identifiers, and commit-ready text in English.
- Keep text files UTF-8 encoded.

## Repository Boundaries

- The root repository owns the Windows SDL host, CMake integration, scripts, and documentation.
- `lvgl/`, `FreeRTOS/`, and every `projects/*` directory are Git submodules. Do not edit upstream dependency submodules unless the task explicitly requires it.
- A project submodule change must be committed and pushed in that project repository before the root gitlink is updated.
- Do not edit generated files under `build/` or `bin/`.

## Build And Validation

- Run commands from the repository root.
- Keep vcpkg in the sibling directory `../vcpkg`; never add machine-specific absolute paths.
- Build the affected application with `build.bat <PROJECT> <Debug|Release>` on Windows or `./build.sh <PROJECT> <Debug|Release>` on macOS, or the equivalent CMake commands in `docs/BUILD.md`.
- Run with the same project and configuration using `run.bat <PROJECT> <Debug|Release>` on Windows or `./run.sh <PROJECT> <Debug|Release>` on macOS.
- Validate the narrowest affected target after a code or build-system change.

See `docs/BUILD.md` for supported targets and `docs/USE.md` for runtime and API contracts.