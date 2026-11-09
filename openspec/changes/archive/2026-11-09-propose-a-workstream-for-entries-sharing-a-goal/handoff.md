# Handoff: propose a workstream where entries naming none share a goal

## Why this was identified

On 2026-11-08 and 2026-11-09 in commerce-ops, the backlog came to hold 40 entries naming `workstream: none`, out of 123. The operator asked whether that was how it should be. It was not, and it took the operator asking twice before anything was done.

**What happened.**

1. **Three workstreams were abandoned.** The operator moved product launches onto a new playbook. A session abandoned `move-the-launch-work-to-clickup`, `one-shape-for-every-step` and `finish-the-sheet-launch`, and detached their entries. It read the open workstreams' Goals, as `match-backlog-entries-to-a-workstream` made it owe, and re-pointed three entries. It wrote `none` on 18 others, each with a note to "re-check against the new playbook before it is taken". That deferred the judgement rather than making it, and nothing in the rules prevented it.
2. **The operator asked whether 40 entries without a workstream was right.** A triage deleted 4 entries as obsolete and parked 1. The operator then saw 37–38 still without a workstream and asked again.
3. **Only on that second question** did the session look for goals the entries shared *among themselves*, rather than goals of open workstreams. It found three, and the operator had them opened as workstreams, not begun:
   - `clear-out-the-sheet-launch`: 6 entries plus one new one, retiring what only the old playbook used.
   - `tune-every-prompt-in-langfuse`: 2 entries about prompts published and tuned in Langfuse.
   - `keep-a-launchs-slack-and-clickup-true`: 3 entries about what a launch shows in Slack and ClickUp.

   Eleven entries were placed. Several had been sitting under `none` for weeks before this episode. The rest were one-offs, and rightly stayed `none`.

**Why the rules let it happen.** Every rule that chooses an entry's workstream looks only at *open* workstreams. None looks across the entries naming `none` for a goal they share. None says to propose a workstream when such a goal is found.

- `skills/backlog/SKILL.md`, **record** step 7 (**Workstream**): reads the Goal and Not in scope of every open workstream, then writes a name or the absent value. With no workstream to fit, `none` is the end of the road.
- `rules/backlog.md`, the `workstream` key: the same. `none` is written "only after that read finds none".
- `rules/workstreams.md`: "Open a workstream when the operator decides a goal needs more than one change". This is right: opening stays the operator's. But nothing tells a session to put that decision in front of the operator.
- `rules/development-workflow.md`, **draft**: "Where the change is one of several a goal needs and no workstream holds them, propose opening one". This is the only place the idea exists. It fires when a change's proposal is written, not when an entry is recorded or detached, so entries waiting in the backlog never meet it.
- `skills/backlog/SKILL.md`, **sweep** step 2, and `rules/workstreams.md`'s detach and abandon paragraphs: detaching re-points by the open workstreams' Goals, else `none`. An abandonment that detaches many entries at once is exactly when they are likeliest to share a goal, and nothing looks for one.
- `skills/backlog/SKILL.md`, **audit**: splits entries into ranges of about 25, one agent each. No agent sees two `none` entries from different ranges, so the audit cannot find a shared goal either.

## Proposals

1. **record, step 7 (`skills/backlog/SKILL.md`), and the `workstream` key (`rules/backlog.md`).** Where the read of open workstreams finds none and the entry is about to be written `none`:
   - read the other entries naming `none`;
   - where the new entry shares a goal with one or more of them, and that goal needs more than one change, propose to the operator opening a workstream for it, naming the entries and a draft Goal;
   - write `none` meanwhile, and never open the workstream unasked;
   - say in the answer what was proposed, or that no shared goal was found.
2. **Detaching (sweep step 2, and `rules/workstreams.md`'s archive and abandon paragraphs).** When a workstream is archived or abandoned and its entries are detached, run the same read over the detached entries together with the existing `none` entries. Propose a workstream where they share a goal.
   - Forbid detaching with a deferral note ("re-check before it is taken") in place of the read. Each detached entry is re-pointed, set to `none` after the read, or proposed for deletion where the abandonment made it obsolete.
3. **audit (`skills/backlog/SKILL.md`, `references/audit.md`).** After the agents' verdicts are merged, add one pass over all entries naming `none` together, across ranges. The merged report gains a section: groups of `none` entries sharing a goal, each with a draft Goal, proposed as workstreams. Like the rest of the audit, it is applied only on the operator's word.
4. **Possibly the workflow fragment.** Check whether `rules/development-workflow.md`'s **draft** sentence ("propose opening one") and **archive**'s re-read should point at the same rule, so the obligation is stated once.

## What bears on it

- **`match-backlog-entries-to-a-workstream`** (opened 2026-11-02 from commerce-ops) made the open workstreams' Goals be read before `none` is written. This change is its next step: from "is there an open workstream?" to "should there be one?". Keep its wording and extend it; do not restate it.
- **The workstream holding the backlog and workstream rules**, `complete-the-workstream-loop` if still open: this change serves its Goal, and the proposal should name the workstream it serves.
- **The assets it edits:**
  - `skills/backlog/SKILL.md`, its trigger fixtures, and `references/audit.md`;
  - `rules/backlog.md` and `rules/workstreams.md`, which reach projects as managed blocks (`rules/manifest`), so their versions rise;
  - `rules/changelog`;
  - the tests under `tests/cases/` that pin the seeded blocks.
- **The evidence** is in commerce-ops' history: PR #1038 (the abandonment), #1041 (the triage) and #1050 (the three workstreams grouped).

## What it must not undo

- **Opening a workstream stays the operator's decision.** The session proposes; it never opens one unasked. The operator may delegate the decision, as happened here.
- **`none` stays a legitimate answer.** An entry is never forced into a workstream, and no one-entry workstream is proposed, just to avoid `none`. A goal earns a workstream only where it takes more than one change.
- **The proposal is cheap and bounded.** It reads entries' bodies, not the repository, and never blocks recording the entry.
- **Every obligation the skill gains is also stated in the rules files**, so a session that never loads the skill still owes it.
