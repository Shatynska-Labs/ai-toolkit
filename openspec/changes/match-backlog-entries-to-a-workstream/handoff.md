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
