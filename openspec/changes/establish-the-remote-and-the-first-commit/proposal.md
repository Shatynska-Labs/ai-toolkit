## Why

`rules/development-workflow.md` assumes a project has a remote and that every change reaches the trunk through pull requests, but nothing in the setup path connects a remote, and nothing says how the trunk's first commit — which no pull request can carry — reaches it. Initializing `shatynska/basis` hit both: the remote was added and pushed ad hoc outside any skill, and the operator asked why the first commit went straight to `main` when the rules appear to forbid it. See `handoff.md`.

## What Changes

- The `project-init` skill, after the initial commit in a new project, asks the operator for the URL of a hosted repository the operator has created, and on confirmation connects it as `origin` and pushes the trunk. It never creates a hosted repository or chooses its forge, owner, name or visibility; declining leaves the project without a remote and says what that blocks.
- The skill's initial-commit offer lists what the commit would actually contain — everything neither tracked nor ignored, not only what the tool wrote — before asking, since a directory may already hold the project's own files.
- The skill offers the direct initial commit only where the repository has no commit. In an adoption it does not commit the tool's writes onto the trunk, and says they reach it through a pull request like any other change.
- `rules/development-workflow.md` states, beside the pull-request rule, that a repository's first commit is the one commit that reaches the trunk directly, identified by there being no commit before it. Version 6 → 7.
- `scripts/project-init` is unchanged: it stays deterministic, configures no remote and pushes nothing.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `project-bootstrap`: adds what a wrapper does after a successful run — the scope of the initial-commit offer, its content shown before confirmation, and connecting an operator-supplied remote.
- `session-workflow`: adds the fragment's statement of the first-commit exception to delivery through pull requests.

## Impact

- `skills/project-init/SKILL.md` — its opening paragraph and step 4 rewritten, a remote step added after it, step 5's adoption ending revised, description revised (trigger check re-run).
- `rules/development-workflow.md` — one sentence in `ship`, version 6 → 7. Every consuming project's managed block is reported one version behind when `project-init` is re-run there; replacing the block is out of scope (`update-managed-block`).
- `tests/cases/` — cases derived from the new scenarios.
- Not affected: `scripts/project-init`, `rules/project-foundation.md`, `skills/project-foundation/SKILL.md`. Projects initialized before this change keep whatever remote they have; nothing here retrofits one.
