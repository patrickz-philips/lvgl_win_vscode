---
description: "Use when changing CMake, Windows batch scripts, workspace settings, submodules, or build documentation for the LVGL simulator."
applyTo: ["CMakeLists.txt", "*.bat", "simulator.code-workspace", ".gitmodules", "README.md", "docs/**/*.md"]
---
# Build Integration Rules

- Resolve the vcpkg toolchain only from `${CMAKE_SOURCE_DIR}/../vcpkg` or the equivalent script/workspace-relative path.
- Keep each application under `projects/<lowercase_name>` with `inc/` and `src/` directories.
- Keep the project lists synchronized across `CMakeLists.txt`, `build.bat`, `run.bat`, `clean.bat`, `src/main.c`, and build documentation.
- Preserve isolated output paths: `build/<Debug|Release>/<project>` and `bin/<Debug|Release>/<project>/main.exe`.
- Register project repositories in `.gitmodules`; do not ignore their paths in the root `.gitignore`.
- Do not inject module screen dimensions through CMake definitions.
- Treat `x64-windows-static` as the default standalone Windows build. Document dynamic triplet builds separately when supported.
- Run configuration or a focused build for every affected target before finishing.