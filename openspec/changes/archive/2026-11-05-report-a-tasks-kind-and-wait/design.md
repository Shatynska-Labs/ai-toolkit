## Context

`project-bootstrap` owns the entry rules, written from `rules/backlog.md` as a managed block. `backlog-maintenance` owns the skill that carries them out, and `task-board` owns the tool that reads entries for a board. `dev-task-board` carries a pinned copy of the tool and draws its `--json`, and its README rules out restating the workflow's rules in its own code, so anything derived from the rules, readiness included, has to come from the tool.

The evidence is commerce-ops' backlog on 2026-11-05: 131 entries, 24 `waits_for`, no `high`. A prototype of the board showing kind, need and the typed wait, built on that data, is kept on `dev-task-board`'s branch `show-a-tasks-kind-and-wait`.

## Goals / Non-Goals

**Goals:**
- An entry states whether it is required for its goal, in a value a program reads.
- A condition an entry waits for states, in a value, whose move it is.
- The tool reports, per task, its kind, need, wait and whether it can be taken now, by the same lookups it already uses for status.

**Non-Goals:**
- Rewriting `waits_for` into another shape. A free-text condition stays valid; the type is added beside it.
- A third kind between `fix` and `change`. In commerce-ops the 18 fixes meet the definition cleanly, and the middle case, a change held only by a decision, is a wait, which `waits_for_type: [decision]` now says.
- A size or an area for an entry. `change` already covers "too large for one sitting", and workstreams group by area.
- Drawing the board's columns. That is `dev-task-board`'s `show-a-tasks-kind-and-wait`.
- Filling `need` or types in consuming projects. Each does it in a pull request of its own, by **audit** or by hand.

## Decisions

**1. `need`: `must`, `should` or `could`.** The key follows `kind` in the key order, and reads:

> - `need`: `must`, `should` or `could`. Measured against the Goal of the workstream the entry names: `must` where the Goal does not hold without it, `could` where the Goal holds without it and the operator would not keep it among the steps, `should` otherwise. Being a step does not make an entry `must`, even where the Done when requires every step to be done. An entry naming no workstream is measured against the project: `must` where its absence does harm, `could` where it is an improvement only, `should` otherwise. An entry without `need` is `should`. `must` and `could` are the operator's judgement.

MoSCoW without "won't", which is already a deletion ground. It is apart from `priority` because urgency and necessity vary independently: a `could` may be urgent while an opportunity lasts, and a `must` may be parked until its precondition exists. Against the Goal rather than the Done when, because a Done when may require every step to be done, which would make every step `must`; the Goal states what the workstream is for, and a `could` step is exactly one the operator may remove from the steps and return to the backlog without failing it. The Goal is not observable as a Done when is, which is why `must` and `could` are the operator's statement with a reason, not a session's reading. The body's reasons list gains **Need**, on a `must` or `could` entry only, why, as **Priority** is given only off its default.

**2. `waits_for_type`: a list beside `waits_for`.** The key follows `waits_for`, and reads:

> - `waits_for_type`: present only beside `waits_for`, the kinds of wait it states, from `decision`, the operator's decision; `answer`, an answer from someone other than the operator; `access`, an access grant, a credential or a setting someone must enable; `release`, a release reaching an environment; and `event`, any other condition that can be checked. A `waits_for` without it is untyped.

`waits_for` gains: "Keep it short, what is awaited and from whom; the reasons go in the body."

A list because a condition may hold two waits; commerce-ops has one waiting on another system honouring a field and on the operator's word. A separate key rather than a typed `waits_for` because the free text is in every consuming project, `scripts/backlog-migrate` writes it, and the dashboard needs both the type and the words. The five types are the kinds commerce-ops' conditions fall into; `event` is the remainder so that no condition is left without a type. "Who acts" is the point: `decision` is the operator's move, `answer` and `access` someone else's, `release` and `event` nobody's yet.

**3. The rules' version is `1.2.0`, with no ask.** Both keys are added and every existing entry stays valid, so a project needs no edit. The changelog's `changed` line names the keys and that **audit** proposes types for existing conditions.

**4. Record.** Step 3, **Kind**, is followed by a new step:

> 4. **Need.** Where the README names `need`, set it to the README's default, `should` in the seeded README, unless the session or the operator states why the entry is `must` or `could`. Propose either with that reason, read from the Goal of the entry's workstream or, for an entry naming none, from the harm its absence does to the project, and write it only once the operator confirms it.

Step 4, **Waits**, now 5, gains: "Where the README names `waits_for_type`, write beside each `waits_for` the types it states." The steps after it renumber. Record sets the type itself, unlike need: the type is a fact of the condition's wording, which the operator already gave.

**5. Pick orders by need within a priority.** Inside each takeable list and each workstream group, entries of one priority are listed `must`, then `should`, then `could`; a Design with group is placed by its highest-need member after its highest-priority one. A workstream group keeps its step order within one need. Need never makes an entry takeable or not; the wait alone decides that.

**6. Audit checks the type.** The brief's **Waits for** item gains: "and whether its `waits_for_type` states the kinds the condition holds; where it has none, propose them". The merged report lists a wrong or missing type under **Stale facts**, and a `waits_for_type` with no `waits_for` beside it, which the README forbids. Audit proposes no `need`: it is the operator's judgement, not a fact an agent can verify.

**7. Older shapes.** An entry without `need` is `should` by the README; one with `waits_for` and no `waits_for_type` is untyped, a wait as before. Neither is reported as unclassified, since neither key decides whether an entry is takeable.

**8. The tool's fields.** Each task in `--json` gains, after `waits_on`:

- `kind`: string or `null`, the entry's value, `null` where there is no entry or no key;
- `need`: string or `null`, the entry's value, `should` where the entry has no key, `null` where there is no entry;
- `waits_for`: string or `null`;
- `waits_for_type`: a list of strings, empty where the entry has none;
- `parked_until`: string or `null`;
- `waits_on_done`: a list of the names in `waits_on` whose status, by the tool's own lookups, is `done`;
- `readiness`: `null` for a task `done` or `in_flight`; otherwise `blocked` where a name in `waits_on` is not done, else `waiting` where the entry has `waits_for`, else `parked` where `priority` is `parked`, else `ready`.

A name is counted done exactly where its status lookup says done, so the page and the document agree. Where it is not done, `forge` is not `full` and the name has no change, open or archived, it may be a merged fix the forge read did not reach, so the task's `warnings`, and the page beside it, name that wait as not checked, and a board shows the block as unverified rather than as fact.

`need` defaults while `priority` gives `null` for its default, because a board drawing need has to tell "no entry" from "the default", and `priority`'s shape is not changed by this change. A value is given as written; the tool does not check it against the sets, as it does not check `priority`. Readiness follows the skill's order — the wait governs first, then parking — and treats every `waits_for` as unmet, since the tool cannot check a condition. A name in `waits_on` counts as done by the same status lookup a step uses, so a fix merged under that name clears the wait, which the skill's "archived change" alone would miss; **pick** is unchanged by this, being the skill's reading, and the tool's reading is what a board shows. All are additions, so `schema_version` stays `1`.

**9. The page.** A task row shows `kind`, and `need` where it is not `should`, as tags beside its priority; its waits line names each `waits_on` name with `(done)` after the done ones and the warning for a named wait not checked beside the one it concerns, and a second line reads `Waits for` followed by the types, comma-separated, where it has them, and the condition. `readiness` is not drawn on this page: the page is a snapshot for one reader, and the board draws it.

**10. Workstream.** `see-a-projects-tasks` gains step 7, `report-a-tasks-kind-and-wait`, in this plan's commit, after a workstream review. Its Done when already holds every step to be done, and its Not in scope already leaves consumers' migration out.

## Risks / Trade-offs

- **Two waits keys drift.** A type can stop matching its condition when the condition is edited. Audit checks the pair.
- **`need` mostly stays `should`.** As `priority` stayed `normal`. The difference is that its two other values are each the operator's statement against a stated measure, which a review of a workstream can ask for; a project that never fills it loses nothing it had.
- **Readiness disagrees with pick on a merged fix.** The tool reads a wait on a merged fix as cleared and pick does not. The tool's reading is the workstreams rule's own status lookup, so the disagreement is pick lagging, which `sweep` and audit already correct.
