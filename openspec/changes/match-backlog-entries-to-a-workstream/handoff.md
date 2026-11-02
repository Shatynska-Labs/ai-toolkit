# Handoff: place a backlog entry in the workstream whose goal it serves

## Why this was identified

On 2026-11-02 in commerce-ops, a session closing `move-the-launch-record-pages-to-react` (step 10 of the workstream `move-the-admin-to-react`) recorded four backlog entries found on staging after the work merged:

- `load-the-launch-record-grid-faster`
- `hide-notice-only-rows-from-the-grid`
- `give-date-columns-a-date-picker-in-the-sheet`
- `fill-taken-into-work-as-the-launch-starts`

All four ended up `workstream: none`:

- **Two of them** first took `move-the-admin-to-react`, the recording change's workstream. At the archive they were detached because that workstream rules out changing what a page does as it moves (*Not in scope*). The session wrote `none` without looking for another home.
- **The other two** were written `none` from the start.

Two open workstreams plainly fit:

| Entry | Fitting workstream | Its Goal |
|---|---|---|
| `give-date-columns-a-date-picker-in-the-sheet` | `work-the-launch-in-the-sheet` | a product manager launches from the sheet |
| `fill-taken-into-work-as-the-launch-starts` | `work-the-launch-in-the-sheet` | the same |
| `load-the-launch-record-grid-faster` | `launch-in-the-web-app` | the record is filled in the web app comfortably enough that people choose to work there |
| `hide-notice-only-rows-from-the-grid` | `launch-in-the-web-app` | the same |

The operator asked why no fitting place had been looked for. The entries were re-pointed afterwards by hand.

Two causes:

1. **The session wrote the entries by hand and never loaded the `backlog` skill.** Nothing in the workflow fragment binds recording an entry to that skill. *A second change surfacing* says to record in `docs/backlog/`, but names no tool.
2. **Where the skill and the rules speak, they make `none` the path of least resistance.**
   - `rules/backlog.md`, the `workstream` key: "An entry recorded by a change in a workstream takes that workstream unless it serves another goal." That implies looking for the other goal, but never says to read the open workstreams' Goals.
   - `skills/backlog/SKILL.md`, **record** step 6 (**Workstream**): defaults to the change's workstream, else the absent value. It writes another workstream only "where the session or the operator states the entry serves another goal". No step reads the open workstreams' Goals and matches the entry against them, so `none` is written unexamined.
   - `skills/backlog/SKILL.md`, **sweep** step 2: re-points entries naming a workstream only "where the change's archive archives its workstream". It has no case for an entry naming the change's workstream while falling outside that workstream's scope. That case occurred here and was handled by writing `none`.

## Proposals

1. **`skills/backlog/SKILL.md`, record step 6.** Before writing `workstream`:
   - read the **Goal** (and *Not in scope*) of every open workstream in `docs/workstreams/`;
   - take the change's workstream where the entry serves its Goal and falls inside its scope; otherwise take the open workstream whose Goal the entry serves;
   - write the absent value only once that read finds none;
   - report the workstream chosen for each entry, and why, in the operation's answer.

   The operator should not have to ask where an entry belongs.
2. **`skills/backlog/SKILL.md`, sweep step 2.** Add a case: an entry naming the change's workstream that falls outside that workstream's *Not in scope* is re-pointed by the same read of the open workstreams' Goals, not set to the absent value without it.
3. **`rules/backlog.md`, the `workstream` key.** Make the search explicit, so that a session never loading the skill still owes it. Suggested wording: "Where the entry serves another goal, it takes the open workstream whose Goal it serves; `none` only where no open workstream's Goal is served."
   - This text reaches projects as the managed block in `docs/backlog/AGENTS.md` (`rules/manifest`), so the block's version rises with it.
   - Check whether `rules/workstreams.md`'s "Place each such change or entry among the steps, or detach it" needs the same clarification: detaching means re-pointing to the workstream the entry serves, or `none` only when there is none.
4. **A Claude Code binding in the workflow fragment.** Add it under *A second change surfacing* in `rules/development-workflow.md` and `rules/development-workflow-direct.md`, beside the existing bindings: "_Claude Code binding:_ record an entry with the `backlog` skill's **record** operation, and re-read the backlog at **archive** with its **sweep**."
   - commerce-ops' `AGENTS.md` carries this fragment verbatim (its *A second change surfacing* paragraph is identical to `rules/development-workflow.md`'s), so the line reaches it through the managed-block update rather than a hand edit there.
   - Check whether **archive**'s re-read paragraph should name the sweep the same way.
5. **The skill's description.** Add trigger phrases for recording follow-ups found during a change: "record the follow-ups found on staging", "write these up as backlog entries", "where does this entry belong". Run `create-skill`'s trigger check after editing it.

## A second occurrence: an entry naming its workstream, never placed among its steps

On 2026-11-02 in commerce-ops, a session closing `answer-a-step-from-its-columns` (step 7 of `work-the-launch-in-the-sheet`) recorded three backlog entries during the change and correctly wrote `workstream: work-the-launch-in-the-sheet` on each:

- `drop-the-fincci-only-column-flag`
- `edit-a-columns-owning-step-in-the-admin`
- `register-a-column-launchs-sku-in-stock-base`

None became a step. The archive edited the workstream file (step 7's text, an answered open question, a decision) and swept the backlog, yet left all three outside the step list, beside five older entries naming the same workstream that earlier archives had also left: `retire-a-launch-record-column`, `fill-taken-into-work-as-the-launch-starts`, `give-date-columns-a-date-picker-in-the-sheet`, `link-a-step-result-in-the-next-task`, `file-the-seo-workbook-by-brand-and-model`. The operator noticed that the follow-ups were "only in the backlog"; the eight were placed by a separate pull request (commerce-ops #873). This is the gap after the one above: there the value was wrong; here the value was right and the entry was still not part of the plan.

Causes:

1. **Placement is deferred, so it is forgotten.** `rules/workstreams.md` lets an entry naming a workstream wait to be placed "at the next edit of the workstream, and at the latest at the archive of a change in it". Recording sets the value and moves on; nothing ties the placement to the moment the entry is written.
2. **The archive's sweep does not look for it.** `skills/backlog/SKILL.md`, **sweep** step 2, gathers the entries naming the change, waiting on it, touching what it touched, and those naming its workstream only where the archive archives that workstream. An entry naming the change's still-open workstream that no step names is in none of those groups, so the sweep that runs at exactly the deadline the rule sets passes it by. The workflow fragment's **archive** paragraph says "place the entries attached to it", which reads as the entries already placed.
3. **The check that exists is not run.** The skill's **workstreams** operation already lists entries naming a workstream that no step names, as *Unplaced* (step 3), but it is read-only and on request; neither **record** nor **sweep** calls it.
4. **"No step names it" is ambiguous.** `register-a-column-launchs-sku-in-stock-base` was named inside step 7's description, so a search for its name found it "placed" although it was no step.

## Proposals (second occurrence)

6. **`skills/backlog/SKILL.md`, sweep step 2.** Add a group: every entry whose `workstream` names the change's workstream and that no step of it names — the entries this change recorded among them — each to be placed among the steps or detached, the order asked of the operator, in the record commit. Run the **workstreams** operation's *Unplaced* read for this rather than a second definition.
7. **`skills/backlog/SKILL.md`, record step 6, and `rules/workstreams.md`.** Where an entry names an open workstream, place it among that workstream's steps in the same edit, asking the operator where in the order, or say plainly that it is left for the archive and why. State the obligation in `rules/workstreams.md` too ("placed when recorded, at the latest at the archive"), so a session that never loads the skill still owes it.
8. **Define "a step names it"** in `rules/workstreams.md` and the skill: only a step's own name, the backticked name a numbered step begins with. A mention inside a step's description, in Context or in Decisions does not place an entry.
9. **The workflow fragment's archive paragraph.** Replace "place the entries attached to it" with the concrete set: "every backlog entry whose `workstream` names it and that no step names", so the obligation is checkable by a grep of `^workstream: <name>` against the step names. Consider whether a project may add a deterministic check — a test failing on an entry naming an open workstream that no step names — as a project choice the rules mention, not one they impose.

## What bears on it

- **The workstream `complete-the-workstream-loop`**: its Goal includes a workstream being "unambiguous about which changes are its own". This change serves that Goal, and its proposal should say so or argue otherwise.
- **`review-a-workstream-against-its-goal`** (`docs/backlog/`) reviews a workstream's steps against its Goal. This change reads Goals to place entries. Both should use the same reading of a Goal; neither should define its own.
- **The assets it edits:**
  - `skills/backlog/SKILL.md`, and its trigger fixtures;
  - `rules/backlog.md`, possibly `rules/workstreams.md`;
  - `rules/development-workflow.md` and `rules/development-workflow-direct.md`;
  - `rules/changelog` for what an adopting project must do;
  - the tests under `tests/cases/` that pin the seeded backlog block (for example `backlog-dir-seeded-workstream-default.sh`).

## What it must not undo

- **The entry still states its workstream in its own frontmatter**, and a workstream file still holds no progress. The fix is in how the value is chosen, not in where it is kept.
- **An entry is still never placed in a workstream it does not serve, just to avoid `none`.** `none` stays a legitimate answer once the read finds no Goal served.
- **The skill stays a way of carrying out the rules.** Every obligation added to the skill must also be stated in the rules file, so a session that never loads the skill still owes it (`skills/backlog/SKILL.md`, opening paragraph).
