## Why

`rules/development-workflow.md` puts each change's working tree at `.worktrees/<name>`, and its Claude Code binding puts it under `.claude/worktrees/`. The ignore file `scripts/project-init` writes into a new project names neither root, because `project-bootstrap`'s *The minimal ignore file is enumerated, not described* fixes its entries and lists no working-tree category. So in a project initialized by this toolkit, the first change's working tree shows up in the main tree's `git status`, and `git add -A` there commits it as an embedded repository.

The obligation was recorded in `rules/worktree-isolation.md`, which `project-init` never inlined. `consolidate-development-workflow` folded that fragment away, and the obligation survived only as the backlog entry `seed-the-worktree-ignore-entry`.

**Workstream**: none — this change advances no workstream.

## What Changes

- The enumerated ignore file gains a fourth category, `# Working trees`, with `.worktrees/` and `.claude/worktrees/`.
- The requirement states that the ignore file reaches only tools that read it. Recursive tools that do not read it, such as test collection, linters and a container build context, must be kept out of those roots by the project's own tooling configuration. The tool writes none of that configuration.
- Foundation discovery's *Provisioning* concern takes ownership of keeping those tools out of the working-tree roots, so the obligation has an actor.
- `scripts/project-init` writes the new category. The derived cases assert it, superseding `tests/cases/gitignore-enumerated-entries.sh`.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `project-bootstrap`: *The minimal ignore file is enumerated, not described* adds the working-tree category and the boundary statement. Its existing scenario now reads four categories, and a new scenario, *Created ignore file ignores the working-tree roots*, asserts both roots.
- `project-foundation`: *The foundation covers a fixed set of decisions including non-goals* extends the provisioning concern to keeping recursive tools out of the working-tree roots, with a new scenario.

## Impact

- `scripts/project-init` (the ignore-file heredoc), `tests/coverage.md`; `tests/cases/gitignore-enumerated-entries.sh` is retired in favour of the derived cases.
- `rules/project-foundation.md` (the *Provisioning* concern's line). Its checklist items and `design.md` sections are unchanged.
- Existing projects are untouched: the tool never rewrites an ignore file that already exists. A project initialized earlier adds the two lines by hand.
- The workflow fragment is unchanged, so the managed block's version does not move.
- The backlog entry `seed-the-worktree-ignore-entry` is deleted at archive.
