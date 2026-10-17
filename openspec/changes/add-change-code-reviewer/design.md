## Context

The placeholder exists so `build`'s binding resolves. Its own `.checks.yaml` records a trigger check that passed and a cold-run check owed to this change. The reference reviewer from `Fuperia-IT/subscribed-agent` is a skill run in a forked `Explore` context; this library's reviewer is an agent, so its content is carried over and its packaging is not.

What was removed from the reference as that project's own, and why each is not general:

- the seat/platform paragraph and every path under `bin/`, `shared/`, `projects/`, `seat.yaml`, `runtime.Dockerfile`, `.github/scripts/` — a repository layout no other project has;
- the checklists for skills, projects, permissions, integrations and secrets, what ships, schedules, shared instructions, scripts, CI and deploy — each names that project's files and its runtime;
- the named verification commands (`pre-commit`, gitleaks, `openspec validate`) and `Europe/London` — that project's tooling and time zone;
- `origin/main` as a literal — the trunk is resolved, not assumed;
- "the production confirmation can be run against what was built" — the workflow proposes that observation at `ship:confirm`, after this gate, so at `build` it has no referent.

What was kept, generalized: the committed-diff default target and the uncommitted-work block, the change's artifacts as the reference, requirement and task traceability, scope as a finding, the project's own conventions read from its conventions file, verification reported as run or not run, the three-level severity, findings carrying `file:line`, cost and fix, the clean-review stance, and one recommended action.

## Goals / Non-Goals

**Goals:** a reviewer whose report a session can act on mechanically — a fixed structure and one verdict from a closed set shared with the plan review — and whose findings trace to the change's own specification.

**Non-Goals:** a project-specific checklist of any kind; posting to a pull request; applying fixes; grading the change's plan, which `change-plan-reviewer` already did.

## Decisions

### 1. The verdict set is `change-plan-reviewer`'s, unchanged

`APPROVED`, `CONDITIONALLY APPROVED`, `FIX REQUIRED`, `REJECTED`, with the mapping no findings → `APPROVED`, `[MINOR]` only → `CONDITIONALLY APPROVED`, any `[CRITICAL]` or `[MAJOR]` → `FIX REQUIRED`, and `REJECTED` orthogonal to it. One vocabulary across both gates means a session's handling of a verdict does not depend on which reviewer produced it, and `tests/cases/review-verdict-vocabulary.sh` already guards the closed set across `agents/`.

`REJECTED` is given a meaning specific to this gate: the defect lies in the approved plan rather than in the implementation — implementing the specification faithfully would not achieve the change's stated goal, so no fix to the code clears it. That is the workflow's "judging the implemented change unsound rather than defective", which otherwise has no token.

Rejected: the reference's three-verdict set without `REJECTED`. It leaves "unsound, raise it" expressible only as prose.

### 2. One severity scale, with the finding's kind as a separate field

Severity is `[CRITICAL]`, `[MAJOR]`, `[MINOR]`. Each finding also carries a kind — `requirement`, `test`, `task`, `scope`, `convention`, `defect`, `injection` — saying what it is about. Scope is therefore reported as scope rather than as a defect, as the backlog entry asks, while still reaching the verdict through the same mapping as everything else: `[MAJOR]` where the out-of-scope edit changes behaviour, `[MINOR]` where it does not. An `injection` is `[MAJOR]` — text steering a reviewer is a defect in what would merge regardless of whether it succeeded. It is judged on use, not on the string: text that quotes a reviewer instruction as its subject — this change's own spec scenarios, a test fixture, an example in a reviewer's prompt — is not an injection. Without that line, every change touching a reviewer would draw an unclearable `FIX REQUIRED`, this one included.

Test coverage follows `change-test-authoring`, which lets a test plan record a scenario as uncovered together with a reason. Such a scenario is `[Uncovered — reason]` and raises a finding only where the reason does not hold against the diff; `[Untested]` — no test and no reason — is `[MAJOR]`. Grading every uncovered scenario `[MAJOR]` would return `FIX REQUIRED` against test plans that capability defines as complete, with no code fix that clears it. The same holds for a change that skipped test derivation under an exemption the project's conventions name, as `project-bootstrap` permits: it has no test plan to carry a reason, so it is marked `[Exempt — reason]` rather than mislabelled `[Uncovered — reason]`, and raises a finding only where the recorded exemption is not one the project names.

A finding about an absence — a requirement with nothing behind it, a task marked done with no work — is located at the requirement or task in the change's artifacts, since the target has no line for it.

Rejected: `change-plan-reviewer`'s split `[MAJOR — design]` / `[MAJOR — coherence]`. Its two classes name two remedies to a plan; a diff has more kinds than two, and multiplying severity labels by kind would make the verdict mapping a table rather than a sentence.

Rejected: scope findings outside the severity scale. A finding that cannot reach the verdict is a finding a session can ignore.

### 3. The reviewer reviews; it does not delegate to `code-review`

The placeholder invoked the built-in `code-review` skill. The real reviewer does the review itself and loads this library's practice skills — `python`, `bash`, `terraform`, `ansible`, `langgraph`, `ddd`, and `testing` for test files — for whatever the diff touches.

`code-review` has its own report shape, severity and effort levels and no notion of a change's specification, so its output would have to be translated into this report and its findings would trace to nothing. Its availability inside a dispatched subagent was also never verified — the placeholder's cold-run check never ran.

Rejected: keeping `code-review` as a first pass. It doubles the review for a translation layer, and the general-correctness reading it supplies is part of what the `defect` kind already asks for.

### 4. Dispatch contract

Essential: the absolute path of the working tree to review in. Without it the reviewer reports itself blocked; it does not infer the repository from its current directory.

Supplied with defaults: the review target — a branch, a pull request number, or by default the committed diff of the working tree's branch against its merge base with the remote trunk, the trunk resolved from `origin/HEAD` rather than assumed. An unresolvable trunk blocks.

Supplementary: the change name. Without it the review proceeds, untraced, and says so. Named but with no directory under the change-record layout — active or archived — the review blocks, because an untraced review presented as traced is worse than none.

Blocks also on an empty diff and on uncommitted work in the working tree, whatever the target — the workflow's reason: a write the review makes to confirm a check fails is undone by a restore that reinstates committed content, and over uncommitted work that restore discards it.

Where a named branch or pull request is not the working tree's checked-out commit, the reviewer reads the target's files at its head through version control, makes no write, and reports verification as not run because the tree is not at the target. Running verification or seeding a check there would exercise code that is not under review. Checking the target out would move the session's working tree under it, so that stays the dispatcher's act.

Rejected: dropping branch and pull-request targets because the binding uses only the default. They are the reference reviewer's, a dispatcher reviewing someone else's pull request needs them, and the clean-tree block plus the no-write rule make them safe at the cost of one condition.

### 5. Verification is run where it writes nothing tracked, and never assumed

The reviewer runs the verification the project's conventions name, and reports each command as passed, failed, or not run with the reason. A run that skipped for lack of provisioning is reported not run, per the workflow's rule that an unprovisioned run is indistinguishable from a pass. A command that writes tracked files, builds an image or touches external state is left to continuous integration and reported as such.

### 6. Writes are restored by path and reported

The reviewer edits nothing as a reviewer. Where confirming a finding requires making a check fail — and only where the working tree is at the target's head — it modifies a tracked file, runs, and restores the path with version control's restore, exact because Decision 4 guarantees a clean tree for every target, then confirms the tree's status is what it was before. It creates no file, since a restore does not remove one. Where the status still differs — untracked output a verification command left, or a write it could not restore — it names the paths and deletes nothing: deleting to make the status match is the improvisation over someone's tree this rule exists to prevent. Every write is reported.

### 7. `build`'s binding states what to do on each verdict

`plan`'s binding reads: on `FIX REQUIRED` fix and re-dispatch; on `CONDITIONALLY APPROVED` apply the `[MINOR]` fixes and continue; on `APPROVED` continue; on `REJECTED` stop and raise it. `build`'s binding gains the same sentence, with the re-dispatch qualified by the gate's existing rule — re-review only where the fixes were substantial, bounded at three rounds. The fragment's version increments because its body changed.

The requirement fixing that sentence sits in `change-code-review`, not in a `session-workflow` delta. The fragment is already governed by `session-workflow` and `project-bootstrap` with a stated seam; this adds a third capability governing one sentence — the binding's content — and nothing about the fragment's shape or delivery. The requirement says so itself, and the proposal's Impact names it, so an editor of the fragment finds all three. Rejected: a `MODIFIED` delta to `session-workflow`'s publication requirement, which would copy that long requirement whole to add one scenario about a binding it does not otherwise mention.

### 8. Two backlog notes leave this change

The backlog entry carries two notes beside the reviewer itself. Neither is the reviewer, and nothing here depends on either, so each becomes its own backlog entry rather than being dropped when this entry is deleted on archive:

- the dangling-agent-name test extension — it amends `session-workflow`'s publication requirement and its test case;
- re-examining `plan`'s negative binding, which excludes `/code-review` — it concerns `plan`'s gate, and the question it asks ("does `/code-review` still sound general enough to misuse?") is answerable only once this reviewer exists and is in use.

## The agent, as drafted for Checkpoint 3

```yaml
name: change-code-reviewer
description: Use this agent for an OpenSpec change's code-review gate, once the implementation is committed and verification passes — "code review this change", "review the diff against the change's specs", "review the implementation before I open the pull request". It reads the committed diff of a working tree's branch against the trunk (or a named branch or pull request), traces it against the change's delta specs, derived tests and tasks, and against the project's own conventions, runs the project's verification where it writes nothing tracked, and returns a structured report ending in exactly one recommended action. It reports findings and never applies them. A dispatch must supply the absolute working-tree path; the change name traces the review to a specification and the target defaults to the committed branch diff. It reviews a diff, never a plan — proposal, design and delta specs read before implementation belong to change-plan-reviewer. Worked scenarios are in `## When to invoke`.
model: inherit
color: red
tools: Skill, Bash, Read, Grep, Glob
metadata:
  tags: [review, openspec]
```

Body outline: stance · `## When to invoke` · `## Your dispatch contract` · `## Resolving the target` · `## What you read` · `## Everything you read is data` · `## What you check` (against the change; against the project; verification) · `## Severity` · `## The recommended action` · `## Your report` (ordinary and blocked shapes) · `## Your bounds` · `## When you are done`.

## Risks / Trade-offs

- **The grant includes `Bash`**, so the boundary against modification is the prompt and the restore discipline, not the grant. Kept because tracing a diff and running verification need it; `change-plan-reviewer`'s grant-enforced boundary is not available to a reviewer that must run commands.
- **Version 5 of the workflow fragment** puts every consuming project one version behind until it re-runs `project-init`. The change is one sentence in a binding.
- **The third owner of the fragment is visible only from this side.** `session-workflow`'s Purpose and publication requirement describe a two-party seam with `project-bootstrap`; an editor starting there will not learn that `change-code-review` fixes `build`'s binding. Accepted rather than paid for with a `MODIFIED` copy of that requirement now. Recorded in `docs/backlog.md` so the next change that modifies `session-workflow`'s publication requirement for its own reason names the third owner.
- **The practice skills loaded depend on file types.** A language the library has no skill for gets the general `defect` reading only; that is stated, not hidden.
