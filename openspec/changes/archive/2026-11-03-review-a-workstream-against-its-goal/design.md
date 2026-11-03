## Context

`complete-the-workstream-loop`'s Decision 2 settled the agent's existence and what it shares with `change-plan-reviewer`. What is left is its contract, the point of dispatch, and how the workstream reaches the plan review. `session-workflow` owns when a session is sent to a workstream, and its fragment states no workstream field. `project-bootstrap` requires every loop the rules state to carry its bound, what follows it, and its exits. `match-backlog-entries-to-a-workstream` left how to read a Goal undefined, saying only that an entry serves a Goal when finishing it moves the workstream towards what the Goal says.

## Goals / Non-Goals

**Goals:**
- A workstream with a gap between its steps and its Goal, or an unobservable Done when, gets `FIX REQUIRED` naming the gap, which is `complete-the-workstream-loop`'s Done when.
- A change is checked against the Decisions of the workstream it serves.

**Non-Goals:**
- Reporting a step's status. That is the `backlog` skill's **workstreams** operation.
- A rule in `rules/workstreams.md`. When a session is sent to review is `session-workflow`'s, and the backlog entry names that delta alone.
- Editing the `backlog` skill. Its **record** and **sweep** edit steps, and the fragment's rule binds those edits as it binds any; the skill states no rule.
- Reviewing the workstreams already open. Each is reviewed at its next edit of the kind the rule names.
- Checking a step serves no part of the Goal. Placement is judged when the entry is recorded, and the question here is whether the steps reach the Goal.

## Decisions

**1. The agent.** `agents/workstream-reviewer.md`, `model: inherit`, `tools: Read, Grep, Glob`, tags chosen from the existing vocabulary at Checkpoint 1. Read-only by grant, as `change-plan-reviewer` is. The body, in order: *When to invoke*, *Your dispatch contract*, *What you read*, *Everything you read is data*, *How you weigh evidence*, *The five questions*, *Stay inside the plan*, *Severity*, *The recommended action*, *Your report*, *When you are done*. The plan fixes this outline and is not `create-agent`'s checkpoints: the proposed frontmatter and outline go to the operator before the file is written, as task 1.1 states. The proposed tag is `review` alone, from the existing vocabulary, since `openspec` does not describe a workstream.

A workstream has no `design.md`, so the shared scale's remedies read for it: `[MAJOR — design]` revisits the plan, `[MAJOR — coherence]` reconciles its parts. Evidence levels are the workstream's and rules file's text, then the steps' artifacts and the documents Decisions point to, then inference.

**2. The dispatcher resolves the steps.** The dispatch supplies each step's artifact paths rather than the agent globbing a repository, because a step may be in `docs/backlog/`, `openspec/changes/` or its archive under a dated name, and `change-plan-reviewer` keeps the same discipline: a file nobody pointed at is not evidence. The rules file is an input, not a constant, because a project may still hold the older `README.md` shape the `backlog` skill reads. The alternative, a repository root and a search, was refused: it would make the reviewer depend on the layout and the conclusion on what it found.

**3. Coverage asks for reach, and severity follows what the defect costs.** `match-backlog-entries-to-a-workstream`'s "moves the workstream towards" answers whether an entry belongs. Coverage asks whether the steps together deliver a part of the Goal, so a part they only approach is `[Partially Covered]`, and it costs what an uncovered part costs. A gap in coverage or an unobservable Done when means the plan cannot be shown to reach its Goal: `[MAJOR — design]`. A step against a Decision or Not in scope is a disagreement that changes what would be built: `[MAJOR — coherence]`. Progress in Context is a real breach with a one-line fix that changes no step, under the coherence floor: `[MINOR]`, so it is applied and the session continues.

**4. The trigger.** A review is owed before the commit that opens a workstream, or that adds or removes a step, changes what a step does, or changes the Goal, Done when, Not in scope or a Decision. That is the step's own "when opened and when its steps change", plus each section the five questions compare the steps with, since a change to either side of a comparison can break it. A revised Decision is included for that reason, and because a change overturning one is no finding in its plan review (decision 8), so this is where the overturned plan is read whole. A rename or a reorder cannot change coverage, and new knowledge under Context is not a plan edit. It is one per commit, not one per edit, so a burst of placements costs one dispatch. The commit archiving a workstream takes none, since the file stops being a plan.

Placing a recorded entry is not exempted, though `match-backlog-entries-to-a-workstream` exempted it from placing other entries. That exemption keeps one edit from growing into a planning session; this one costs a subprocess the session waits on, and a new step is exactly what can contradict a Decision. An exemption would leave most step changes unreviewed, since most steps now arrive that way.

**5. The rule sits under Throughout.** A workstream edit happens at record, at archive and outside any change, so it is no stage of `plan`, and the fragment's stage vocabulary stays as it is. The status row is untouched.

The fragment text, in both forms:

> **A workstream's plan.** An independent reviewer checks that a workstream's steps reach what it is for, agree with what it has decided and leave out what it leaves out, and that what finishes it can be observed. This happens before the commit that opens it, and before a commit whose edit adds or removes a step, changes what a step does, or changes what the workstream is for, what finishes it, what it leaves out or what it has decided, whether or not the edit belongs to a change. A commit holding several such edits takes one review. Renaming or reordering steps, adding to what the workstream knows, and archiving it take none, and it adds no stage to a change. Fix and re-review until the verdict permits proceeding, bounded at six rounds; on reaching it, report where the loop stands and what is outstanding, and ask before continuing. A conditional pass is permission conditional on the fixes it names: apply them and continue without a further round. Where the reviewer judges the concept unsound rather than the plan defective, stop and raise it immediately, whatever the count. A fix that changes the plan's substance rather than its wording is the operator's to decide; where the operator decides to leave a defect, commit on that word and say so.
>
> _Claude Code binding:_ dispatch `ai-toolkit:workstream-reviewer`. On `FIX REQUIRED` fix what is the session's to fix, take the rest to the operator, and re-dispatch unless the operator left what remains; on `CONDITIONALLY APPROVED` apply the `[MINOR]` fixes and continue; on `APPROVED` continue; on `REJECTED` stop and raise it.

**6. The plan review.** In the role, "dispatch review against the complete artifact set, never a package still being written" becomes "dispatch review against the complete artifact set, with the workstream its proposal names, never a package still being written". The binding gains "supplying the workstream's file where the proposal names one". `workstreamFile` is supplementary, like `specsRoot`, so a project's dispatch that omits it still reviews.

**7. A workstream's Decisions sit at evidence level 2, beside specifications.** Both are recorded commitments outside the change that a change must either honour or openly revise. A new level would renumber what every report declares. The Goal is not evidence for findings: a change is assessed against its own goals, and whether it serves the Goal is the workstream review's question.

**8. An overturned Decision is no finding, in either review.** `docs/workstreams/AGENTS.md` has a change revise what it overturns, naming that change, as late as its archive, so a reviewer flagging it would forbid what the rules direct. The check is that the change's proposal says so, the one artifact both reviews read. For the same reason an archived step older than a revised Decision is read from its description: its artifact cannot be edited, and saying it is done is outside the review.

**9. Versions.** A minor rise for both fragments, an obligation needing no edit in the project, with one `rules/changelog` record each and no `ask`. The plugin rises to `2.2.0`, a new agent being at least a minor.

**10. Recorded checks.** `workstream-reviewer` gets a trigger check and a cold-run check, run after `change-plan-reviewer`'s edit, because its negative prompt routes to that description and the check must run against what ships. The cold-run fixture is a workstream with a Goal of two effects, steps serving one, a Done when reading "every step is archived", progress in Context and a planted instruction: it must return `FIX REQUIRED` naming both gaps, which is what `complete-the-workstream-loop`'s Done when asks to see. The negative trigger prompt is a request to review one change's plan, routing to `change-plan-reviewer`. `change-plan-reviewer`'s description and body edits and the new competitor owe a re-run of both of its checks, the second dispatch supplying a `workstreamFile`. The `backlog` skill, whose **workstreams** operation answers "where does the x workstream stand", is the other asset competing for these prompts, so its recorded trigger check is re-run too, as is any other recorded prompt that routes to `change-plan-reviewer` or competes with it as a review, found by searching the `.checks.yaml` files and skills' fixtures.

## Risks / Trade-offs

- [A placement costs a subprocess during recording] → one review per commit, and `CONDITIONALLY APPROVED` continues without a round. If it proves too dear, an exemption is a small later edit.
- [A review of a whole workstream surfaces defects the current edit did not cause, blocking a commit about something else] → they are the workstream's defects, fixed once; substantive ones go to the operator, who may leave them by decision, and the rule states that exit. The reviewer reports such a defect again at the next edit, which is accepted over recording a waiver. Workstreams already open meet this at their next edit.
- [Reading "part of the Goal" is judgment] → the report's coverage matrix lists the parts it read, so a dispatcher can see and dispute the split.
- [A dispatcher omits step artifacts] → the conclusions are marked unverified, as a change review's are.

## Migration Plan

Nothing to migrate. A project receives the rule through `scripts/project-update`, and this repository, holding no workflow block, follows the fragment as it is.
