## Why

The workflow fragment now directs a session to create commits, not propose them, but `session-workflow` still records the old behaviour. *A second change surfacing* directs "proposing a commit" on a handoff branch and keeps a declined-commit path, and its scenario still expects "it has proposed a commit". The operator applied that instruction to `rules/development-workflow.md` directly, without a change, so the specification was not updated. The same specification also names only `session-workflow` and `project-bootstrap` as owners of the fragment, although `change-code-review` governs one sentence of it, the content of `build`'s Claude Code binding. An editor starting from `session-workflow` cannot learn that. This change takes up two backlog entries that share a design, `reconcile-commit-rule-with-spec` and `name-the-fragments-third-owner`, because both amend the same specification. It also gives the fragment's **Markdown prose** rule a requirement, which the operator decided; that rule is the only part of the fragment that no specification owns.

**Workstream**: none. This change advances no open workstream.

## What Changes

- *A second change surfacing in a session is recorded in the backlog* directs committing the handoff branch as soon as it is opened. The declined-commit path and the appeal to a "proposed rather than made" commit rule are dropped. The scenario *A handoff is not left uncommitted on a branch the session leaves* expects a commit, not a proposed one.
- *The session obligations are published in the workflow fragment and one binding fragment* names `change-code-review` as the third owner of the fragment, the one that governs the content of `build`'s Claude Code binding, and adds a scenario for it.
- `session-workflow`'s Purpose names the same three owners. A delta cannot change a Purpose, so it is edited in the main specification directly.
- A new requirement, *Fragment prose is not hard-wrapped*, records the fragment's **Markdown prose** rule and the reason for it.
- The fragment's text already says each of these things, so its text and version do not change.
- Both backlog entries are deleted at archive.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `session-workflow`: *A second change surfacing in a session is recorded in the backlog* changes from proposing a commit to committing. *The session obligations are published in the workflow fragment and one binding fragment* names the fragment's third owner. *Fragment prose is not hard-wrapped* is added.

## Impact

- `openspec/specs/session-workflow/spec.md`: the Purpose is edited directly; the requirements change at archive.
- New cases under `tests/cases/`, and `tests/coverage.md`.
- `rules/development-workflow.md` is unchanged, and so is its version.
- `docs/backlog/reconcile-commit-rule-with-spec.md` and `docs/backlog/name-the-fragments-third-owner.md` are deleted at archive.
