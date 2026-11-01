---
priority: normal
kind: change
waits_on: []
design_with: []
workstream: see-a-projects-tasks
recorded_by: "the operator"
re_checked: 2026-11-01
---

Running `scripts/task-board` means knowing its installed path and opening the page by hand. Add a `task-board` skill that runs the tool for the project it is invoked in and opens the page, so "show the board" is enough, and an `--open` flag on the tool that finds the system's opener (`explorer.exe` under WSL, `open`, `xdg-open`) and, where it cannot start one, prints the page's path and says so rather than failing the run, so no caller carries its own opening code. A WSL whose interop is not registered cannot start `explorer.exe` at all, as `task-board`'s confirmation found. The skill reaches other projects only when the plugin's version rises, which `raise-the-plugin-version-on-release` covers. A long-running local server was weighed and rejected: it needs a background process for a page that takes seconds to rebuild.

- **Kind**: It owes a `task-board` delta for the flag and a new capability for the skill.
- **Recorded by**: the operator, 2026-11-01, after running the merged tool by its full path.
