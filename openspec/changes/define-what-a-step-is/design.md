## Context

`project-bootstrap` owns the workstream rules. `scripts/project-init` writes them, read from the fragment `rules/workstreams.md`, as a managed block into a project's `docs/workstreams/AGENTS.md`, and `scripts/project-update` replaces an unedited older block. The workflow fragment's status row and archive re-read, and the `backlog` skill's **workstreams** operation, take the status lookups and a workstream's membership from that block, so only the fragment's text changes. This repository's own `docs/workstreams/AGENTS.md` holds the block at `1.0.0`.

Both entries this change takes left the choice between their options to the operator. The operator chose on 2026-10-28, from a comparison of the options in the session that opened this change: a fix's merged pull request counts as done, and a change is a step of one workstream only. This design records those choices for this step alone. The workstream's own Decisions hold what shapes more than one step.

## Goals / Non-Goals

**Goals:**
- A step taken as a fix reads as done once its pull request has merged, so it is never named as next and a workstream holding it can finish.
- A change is a step of one workstream, so every place that asks which workstream a change advances gets one answer.

**Non-Goals:**
- Reading a fix's status without the forge, for example from a merge commit's message on the trunk. A squash merge leaves no such commit, so it would hold in some projects only.
- Changing the workflow fragment, or the `backlog` skill beyond one sentence of **close**. Decision 5 says why.
- Editing a consumer's workstreams. commerce-ops adopts the rule itself.

## Decisions

**1. The status paragraph.** In `rules/workstreams.md`, the paragraph opening "A workstream file holds the plan and never its progress" changes its done clause and gains one sentence after the lookups. Its first sentences become:

> A workstream file holds the plan and never its progress. It does not say which steps are done or in flight. That is read from the repository by a step's name, and the first of these that holds wins: a step is done when the freshly fetched trunk holds an archived change of that name, or when it holds no change of that name, open or archived, and a pull request from a branch of that name has merged, which is how a step taken as a fix is done; in flight when it holds an open change of that name, or a local or remote branch or an open pull request of that name exists; recorded when its `docs/backlog/` holds an entry of that name; and planned otherwise. Where the forge cannot be reached, say so rather than reading as planned a step that a merged pull request could make done.

The rest of the paragraph, from "Edit the file only when", is unchanged. The fix clause sits inside the done clause, so the four statuses keep their order on the line, as `workstreams-seeded-precedence.sh` asserts.

**2. Why "no change of that name".** A change's work pull request merges from the change's branch while the change is still open on the trunk, and its record pull request merges from the same branch. Without the condition, a change would read as done from its work merge until its archive. With it, an open change reads as in flight. An archived change is done by the first clause anyway, so the pull request decides only where no change exists, which is a fix.

**3. The one-workstream paragraph.** A new paragraph follows the one stating that order gates nothing, because it uses the same `waits_on` route:

> A change is a step of one workstream only. Where another workstream's goal also needs it, that workstream does not list it among its steps: its step that cannot start before the change names the change in its backlog entry's `waits_on`, and where that step has no entry yet, one is recorded for it.

A planned step has no entry, and without one the dependency would have nowhere to live; recording the entry is the one route the rules already give a wait.

The rule names no choice of which workstream keeps the change. That depends on the goals, and the operator decides when the second workstream is planned.

**4. "Done" in place of "archived".** In the Done when paragraph, `"Every step is archived" shows only` becomes `"Every step is done" shows only`. In the shape, `add "every step is archived" beside it` becomes `add "every step is done" beside it`. A workstream holding a fix would otherwise keep a Done when that its fix step can never meet. "Done" is the status the lookups give, so the clause and the status read the same word.

**5. No workflow-fragment or skill change.** The status row reads "the open one whose steps name the change". Once a change is a step of one workstream, that phrase is no longer ambiguous. The archive re-read reads "where the change advanced a workstream", which is singular for the same reason. A fix runs no archive step, so nothing there needs a fix clause. The skill's **workstreams** operation takes its lookups from the rules file (`backlog-maintenance`, *A project's workstream README differs from the seeded one*) and already reads pull requests from the forge, saying so where it cannot reach it. A merged pull request is one more thing it reads there. Its **close** operation is the exception: where a closed entry is a workstream's step, it names the workstream and step "so its plan can be revised", which, for an entry closed because it was taken as a fix, invites the step removal decision 1 replaces. Task 1.4 rewords that sentence so a step taken as a fix is said to stay in the plan and read as done once its pull request merges; the requirement's scenario, that close names the workstream and step and leaves the file unchanged, holds as it stands, so it owes no delta.

**6. Version `2.0.0`.** A project whose workstreams list one change in two of them must remove it from one by hand, and the version rule raises MAJOR wherever a project must do something by hand (`project-bootstrap`, *Which part rises is decided by what the project must do*). Most projects hold no such change. The version cannot be conditional. `scripts/project-update` replaces an older, untouched block whatever part rose (its help: "replaced — older and untouched"), so the MAJOR stops nothing; it is the signal, in the block's marker and in this change's pull request, that a project may owe an edit, and the Migration Plan names that edit.

**7. This repository.**
- Its `docs/workstreams/AGENTS.md` block is brought to `2.0.0` by running `scripts/project-update` against the repository, not edited by hand, so the marker's version and hash are the tool's. The block is untouched at `1.0.0`, so the tool reports it replaced.
- `complete-the-workstream-loop` merges its steps `count-a-fix-step-as-done` and `name-a-shared-step-once` into one step, `define-what-a-step-is`, in the plan commit. A step's status is found by its name, and one change cannot carry two names. In the same commit, its Done when reads "every step is done".
- Both backlog entries stay until the archive, where the sweep closes them.

**8. Tests.** The new done clause, the forge sentence and the one-workstream paragraph each get a phrase assertion in a derived case, in the style of `workstreams-seeded-statements.sh`. `workstreams-seeded-done-when-statement.sh` and `workstreams-seeded-done-when-shape.sh` assert the "every step is archived" wording, and are obsolete for decision 4's clause only.

## Risks / Trade-offs

- **The forge becomes a source of `done`.** Offline, a fix step reads as planned unless the session says it could not check. Mitigation: the rules require saying so. The skill already reports an unreachable forge.
- **A fix branch named differently from its step** never matches. The lookups already key every source by the step's name, so a change opened under another name has the same problem. **workstreams** shows unplaced changes beside planned steps, but it cannot show a fix. Mitigation: the rule speaks of "a branch of that name", which tells whoever takes the fix to name the branch for the step.
- **MAJOR for a rare case.** Every project sees a major version for an edit few owe. Accepted, as decision 6 says.

## Migration Plan

Merge, then run `scripts/project-update` in each consuming project. commerce-ops lists `serve-a-subject-other-than-a-launch` in one workstream and adds a `waits_on` naming it to the other's dependent step. It may restore the fix step it removed from `speed-up-the-test-suite`.
