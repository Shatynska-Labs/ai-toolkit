## 1. The agent

- [x] 1.1 Rewrite the body of `agents/change-code-reviewer.md` to the outline in `design.md`, satisfying every requirement in `specs/change-code-review/spec.md` and `agent-authoring`'s five system-prompt elements.
- [x] 1.2 Replace the description with the one drafted in `design.md`; keep `name`, `model`, `color`, `tools` and `metadata.tags`.
- [x] 1.3 Run `create-agent`'s post-write validation and report each item.

## 2. The workflow binding

- [x] 2.1 Amend `build`'s Claude Code binding in `rules/development-workflow.md` to state the act for each verdict (`design.md` Decision 7).
- [x] 2.2 Increment the fragment's `version` from 4 to 5.

## 3. Backlog

- [x] 3.1 Move the "Extend the dangling-reference case" paragraph out of `add-change-code-reviewer` in `docs/backlog.md` into its own entry (`design.md` Decision 8).
- [x] 3.2 Move the note on re-examining `plan`'s negative binding against `/code-review` into its own entry (`design.md` Decision 8).
- [x] 3.3 Add an entry asking the next change that modifies `session-workflow`'s publication requirement to name `change-code-review` as a third owner of the fragment (`design.md` Risks).

## 4. Checks

- [x] 4.1 Run the trigger check against the evaluator composition `agent-authoring` requires, with a positive, a negative (`change-plan-reviewer`'s territory) and the recorded displacement probe; re-run `change-plan-reviewer`'s and `change-test-writer`'s fixtures, which the description edit can affect.
- [x] 4.2 Run the cold-run check per `skills/create-agent/references/cold-run-check.md` and `agent-authoring`'s isolation requirement for a shell-granted agent:
  - Build a fixture repository, outside this one, as the isolation root. It holds a committed `AGENTS.md` naming a test command, a committed change directory (proposal, tasks, a delta spec with at least two scenarios, a test plan) and, on a branch, a committed implementation with one planted spec violation, one correct behaviour-preserving out-of-scope edit and one task marked done with nothing behind it. Give it a remote whose recorded default branch resolves.
  - Populate the drafted plugin into a path inside the fixture that the fixture's committed ignore file excludes, so it is neither tracked nor reported as uncommitted, and register the plugin from there rather than from the authoring checkout.
  - Launch from the fixture root, with every writable payload path inside it; abort if any is not. Review the payload and the permission mode before launching, since the grant includes `Bash`.
  - The run counts only if it returns the ordinary report shape; a blocked report fails the check.
- [x] 4.3 Rewrite `agents/change-code-reviewer.checks.yaml` with the inputs of both checks and no outcomes.

## 5. Verification

- [x] 5.1 Run `bash tests/run.sh`; every case, including the derived ones, passes.
- [x] 5.2 Run `openspec validate add-change-code-reviewer --strict`.
- [x] 5.3 Map the derived cases in `tests/coverage.md`.
