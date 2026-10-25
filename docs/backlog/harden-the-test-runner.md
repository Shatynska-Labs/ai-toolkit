---
kind: fix
waits_on: []
design_with: [describe-the-suite-as-it-is]
recorded_by: consolidate-development-workflow
re_checked: 2026-10-18
---

`tests/run.sh` has no single-case selector, so running one case means exporting `TOOLKIT_ROOT`, `TESTLIB`, `PROJECT_INIT` and `TESTDIR` by hand. And it sets only `set -u`, where the `bash` skill's floor requires `set -euo pipefail`.

- **Kind**: Runner-only, no delta and no decision.
- **Recorded by**: `consolidate-development-workflow`'s `test-plan.md`, *Unresolved project questions*.
