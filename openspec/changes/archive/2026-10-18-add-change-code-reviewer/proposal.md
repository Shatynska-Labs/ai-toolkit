## Why

`agents/change-code-reviewer.md` is a placeholder. It forwards its target to the built-in `code-review` skill and relays whatever comes back, so `build`'s review gate in `rules/development-workflow.md` names an agent that answers but not one that does what that gate asks: read the diff against the change's own specification — each requirement implemented, the implementation matching what the specification describes, the derived tests covering what changed, no unrelated scope, the project's conventions followed.

It also returns no verdict. `plan`'s gate ends in exactly one of `APPROVED`, `CONDITIONALLY APPROVED`, `FIX REQUIRED` or `REJECTED`, and its binding tells the session what to do on each. `build`'s gate ends in whatever shape `code-review` happens to produce, so the session has to interpret free text to decide whether to fix, continue, or stop — and the workflow's "a review judging the implemented change unsound rather than defective exits immediately and is raised" has no token that carries it.

A worked reviewer exists in another project (`Fuperia-IT/subscribed-agent`, `.claude/skills/change-code-reviewer/SKILL.md`). Most of it is that project's: its seat and platform repository, its `projects/` layout, permission files, secrets rendering, schedules, image contents and named verification commands. What remains once those are removed is general and is what the placeholder lacks: a committed-diff target resolved against the trunk, a block on uncommitted work, the change's artifacts read as the reference, requirement and task traceability, scope as its own finding, verification reported as run or not run and never assumed, a fixed severity scale, and a single recommended action.

This is the backlog entry `add-change-code-reviewer`.

## What Changes

- Replace the placeholder body of `agents/change-code-reviewer.md` with a real reviewer, written to `agent-authoring`'s system-prompt standard: a dispatch contract, absolute-path discipline, an untrusted-input stance, a declared report, and a stopping condition.
- The reviewer traces every requirement and scenario in the change's delta specs to the diff and to a test, audits every task marked done, reports out-of-scope edits as scope, checks the project's own conventions, and runs the project's verification where it can without writing tracked files.
- Its report has a fixed structure and ends in exactly one recommended action from the same closed set `change-plan-reviewer` uses — `APPROVED`, `CONDITIONALLY APPROVED`, `FIX REQUIRED`, `REJECTED` — with the same severity-to-verdict mapping. `REJECTED` here means the defect lies in the approved plan rather than in the implementation.
- It stops delegating to the built-in `code-review` skill; it loads this library's practice skills for the languages and tools the diff touches instead.
- Revise the description so it states that the report ends in one recommended action and points at a `## When to invoke` section.
- Amend `build`'s Claude Code binding in `rules/development-workflow.md` to say what the session does on each verdict, as `plan`'s binding already does, and increment the fragment's version.
- Run the trigger check and the cold-run check `agent-authoring` requires, and rewrite `agents/change-code-reviewer.checks.yaml` to record their inputs.
- Move the two notes `docs/backlog.md` files under this entry beside the reviewer — the dangling-agent-name test extension, and re-examining `plan`'s negative binding against `/code-review` — to backlog entries of their own: neither is the reviewer, and nothing here depends on either. Add a third entry asking the next change to `session-workflow`'s publication requirement to name `change-code-review` as a third owner of the fragment.

## Capabilities

### New Capabilities

- `change-code-review`: what a review of a change's implementation must establish and how it reports — the dispatch contract and the committed target, the change's artifacts as reference, traceability of requirements, tests and tasks, scope, conventions, verification evidence, severity, the single verdict, the report structure including the blocked shape, and the boundary that keeps the reviewer from modifying what it reviews.

### Modified Capabilities

None. `change-review` governs the plan review and is unchanged; the new capability reuses its verdict vocabulary rather than amending it.

## Impact

- `agents/change-code-reviewer.md` — rewritten body, revised description.
- `agents/change-code-reviewer.checks.yaml` — rewritten fixtures.
- `rules/development-workflow.md` — `build`'s binding, version 4 → 5. Every consuming project's managed block reports itself one version behind until re-initialized. The fragment is governed by `session-workflow` and `project-bootstrap`; `change-code-review` now governs one sentence of it, the content of `build`'s binding.
- `docs/backlog.md` — two notes split out into entries of their own, and one new entry for the fragment's third owner.
- `tests/cases/` — cases derived from the new capability's scenarios.
- Not affected: `change-plan-reviewer`, `change-test-writer`, `scripts/project-init`.
