---
description: "Use when changing CMake, build scripts (batch or shell), workspace settings, submodules, or build documentation for the LVGL simulator."
applyTo: ["CMakeLists.txt", "*.bat", "*.sh", "simulator.code-workspace", ".gitmodules", "README.md", "docs/**/*.md"]
---
# Build Integration Rules

- Resolve the vcpkg toolchain only from `${CMAKE_SOURCE_DIR}/../vcpkg` or the equivalent script/workspace-relative path.
- Keep each application under `projects/<lowercase_name>` with `inc/` and `src/` directories.
- Keep the project lists synchronized across `CMakeLists.txt`, `build.bat`, `build.sh`, `run.bat`, `run.sh`, `clean.bat`, `clean.sh`, `src/main.c`, and build documentation.
- Preserve isolated output paths: `build/<Debug|Release>/<project>` and `bin/<Debug|Release>/<project>/main` (macOS) or `main.exe` (Windows).
- Register project repositories in `.gitmodules`; do not ignore their paths in the root `.gitignore`.
- Do not inject module screen dimensions through CMake definitions.
- Default to standalone static builds: `x64-windows-static` on Windows, `arm64-osx` on Apple Silicon, `x64-osx` on Intel macOS. CMakeLists.txt auto-selects the triplet by platform when `VCPKG_TARGET_TRIPLET` is not set. Document dynamic triplet builds separately when supported.
- Run configuration or a focused build for every affected target before finishing.