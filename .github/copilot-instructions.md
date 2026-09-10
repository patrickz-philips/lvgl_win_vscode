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
- Build the affected application with `build.bat <PROJECT> <Debug|Release>` on Windows or `./build.sh <PROJECT> <Debug|Release>` on macOS, or the equivalent CMake commands in `docs/archive/knowledge/build-toolchain.md`.
- Run with the same project and configuration using `run.bat <PROJECT> <Debug|Release>` on Windows or `./run.sh <PROJECT> <Debug|Release>` on macOS.
- Validate the narrowest affected target after a code or build-system change.

## Workflow

Non-trivial work runs through the agent state machine defined by `.github/agents/*.agent.md` and `.github/prompts/pz-*.prompt.md` — those files are the machine-executable source of truth. `docs/workflow.md` is the human-readable mirror; change `.github/` first, then sync it. Entry points: `/pz-feature-workflow`, `/pz-ui-workflow`, `/pz-bugfix-workflow`, `/pz-refactor-workflow`; `/pz-continue` resumes, `/pz-quick-fix` is the only sanctioned bypass, `/pz-modify-harness` is the only way to change the workflow itself. Agents: `analyzer` (docs only), `executor` (code and git writes), `reviewer` (read-only judgement), `explorer` (dependency admission research, no execute permission).

Baseline documents are `docs/product-spec.md`, `docs/architecture.md`, `docs/ui-behavior.md`, and `docs/acceptance-criteria.md`; the `handoff` stage keeps them current. Read only the keyword table in `docs/archive/knowledge/index.md` before work, and load a knowledge file in full only on a keyword hit.