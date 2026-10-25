# `complete-the-workstream-loop`

**Goal**: a workstream is checked when it is opened, finished by an effect someone can observe, unambiguous about which changes are its own, and closed by a retrospective whose lessons reach the rules, so planning above a single change carries the same guarantees a change does. It answers the gaps a comparison with BMAD-METHOD's epics found: its readiness check, its retrospective, and one epic per story.

**Done when**: every step is archived, and `change-plan-reviewer`, dispatched on a workstream whose steps leave part of its Goal uncovered or whose Done when only restates its steps, returns `FIX REQUIRED` naming that gap.

**Steps**:

1. `count-a-fix-step-as-done` — a step taken as a fix stops reading as planned.
2. `name-a-shared-step-once` — a change named by two open workstreams has one rule for its status row and its placement.
3. `observe-what-finishes-a-workstream` — the seeded README asks Done when for an observable effect, not "every step is archived".
4. `review-a-workstream-against-its-goal` — a workstream is reviewed when opened and when its steps change: the steps cover the Goal and the document Decisions names.
5. `run-a-workstream-retrospective` — archiving a workstream compares its plan with what happened and routes each lesson to a rule, a skill, a backlog entry, or nowhere.

The status lookups first, then the review, then the retrospective. The order is intended, not a wait.

**Not in scope**: planning before a goal is known — briefs, product requirements, UX — which BMAD covers and this library does not; storing a workstream's progress; building a workstream's steps unattended.

**Open questions**: whether a workstream is reviewed by `change-plan-reviewer` or by an agent of its own; whether a retrospective also runs at a change's archive; whether a retrospective leaves a line in the archived workstream file or only its routed lessons.

**Decisions**: `openspec/changes/archive/2026-10-24-add-workstreams/design.md`, for the workstream model these steps extend.

**Opened**: 2026-10-25, by the operator.
