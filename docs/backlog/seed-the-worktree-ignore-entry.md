---
kind: change
waits_on: []
design_with: [count-a-dangling-ignore-file-link-as-present]
recorded_by: consolidate-development-workflow
re_checked: 2026-10-18
---

`rules/development-workflow.md` puts a change's working tree at `.worktrees/<name>`, and the ignore file `scripts/project-init` writes names no worktree root, because `project-bootstrap`'s "The minimal ignore file is enumerated, not described" fixes its entries. In a new project, sibling worktrees fill `git status`, and `git add -A` commits one as an embedded repository. The change adds the worktree roots to the enumerated set, amends `tests/cases/gitignore-enumerated-entries.sh`, and states that recursive tools which do not read the ignore file (test collection, linters, container build context) are scoped away from the roots.

- **Kind**: It owes a `project-bootstrap` delta to the enumerated-ignore-file requirement.
- **Design with**: `count-a-dangling-ignore-file-link-as-present`, which changes the same ignore-file step.
- **Recorded by**: `consolidate-development-workflow`'s implementation review, round 2. The obligation lived in `rules/worktree-isolation.md`, which `project-init` never inlined, and that change folded the fragment away.
