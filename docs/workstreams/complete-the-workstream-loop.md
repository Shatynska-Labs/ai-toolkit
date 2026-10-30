# `complete-the-workstream-loop`

**Goal**: a workstream is checked when it is opened, finished by an effect someone can observe, unambiguous about which changes are its own, and closed by a retrospective whose lessons reach the rules, so planning above a single change carries the same guarantees a change does. It answers the gaps a comparison with BMAD-METHOD's epics found: its readiness check, its retrospective, and one epic per story.

**Done when**: every step is done, and the agent that reviews a workstream, dispatched on one whose steps leave part of its Goal uncovered or whose Done when only restates its steps, returns `FIX REQUIRED` naming that gap.

**Steps**:

1. `define-what-a-step-is` — a step taken as a fix stops reading as planned, and a change is a step of one workstream only, so its status row and its placement have one answer.
2. `observe-what-finishes-a-workstream` — `rules/workstreams.md` asks Done when for an observable effect, not "every step is archived".
3. `review-a-workstream-against-its-goal` — a workstream is reviewed when opened and when its steps change: the steps cover the Goal and agree with its Decisions.
4. `run-a-workstream-retrospective` — archiving a workstream compares its plan with what happened and routes each lesson to a rule, a skill, a backlog entry, or nowhere.

The status lookups first, then the review, then the retrospective. The order is intended, not a wait.

- **Not in scope**: planning before a goal is known — briefs, product requirements, UX — which BMAD covers and this library does not; storing a workstream's progress; building a workstream's steps unattended.
- **Open questions**: none.
- **Opened**: 2026-10-25, by the operator.

## Decisions

**1. The workstream model these steps extend** is recorded in `openspec/changes/archive/2026-10-24-add-workstreams/design.md`.

**2. A workstream is reviewed by an agent of its own, not by a mode of `change-plan-reviewer`.** The operator, 2026-10-28. A workstream review reads other inputs — the workstream file, its steps' backlog entries and proposals, `rules/workstreams.md` — and asks other questions: whether the steps cover the Goal, whether Done when is observable, whether the steps agree with the Decisions, whether Context and Decisions record progress. A mode would fork `change-plan-reviewer`'s dispatch contract and checklist inside one prompt and blur its trigger. The new agent shares its severity scale and verdict mapping. `change-plan-reviewer` takes a change's workstream file as supplementary evidence, so a change is checked against the Decisions of the workstream it serves.

**3. A retrospective runs at a workstream's archive only, not at a change's.** The operator, 2026-10-28. A change's archive already sweeps the backlog, and most changes would teach nothing, so a retrospective there would become a ritual; a lesson one change teaches is recorded when it is learned.

**4. The archived workstream file keeps one line recording its retrospective**, `- **Retrospective**: <date>, lessons routed to <where>`. The operator, 2026-10-28. An archived file is no longer a plan, so the line records no progress against one, and without it nothing shows the retrospective ran.
