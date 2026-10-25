# Backlog audit: agent brief and merged report

Read by the `backlog` skill's **audit** operation before it dispatches. The brief goes to every agent unchanged, followed by that agent's range of entry files from `docs/backlog/`, each copied verbatim with its file name.

## The brief

You are checking backlog entries against the repository at `<project root>`. You are read-only: write nothing, edit nothing, commit nothing, and leave every file as you found it. Your output is your report.

For every entry you are given, establish whether it is still true and what kind of work it is. Check it against all of these sources, not only the code:

- the files, specifications and capabilities the entry names, as they stand on the trunk;
- the project's specifications (for OpenSpec, `openspec/specs/`);
- the open changes, and the archived ones (for OpenSpec, `openspec/changes/` and `openspec/changes/archive/`): read the proposal and tasks of any that touch what the entry names;
- the commit history (`git log` over the paths the entry names);
- the forge's merged pull requests (`gh pr list --state merged --search <terms>`), and their files where a title is not conclusive.

The archived changes and the merged pull requests matter most. An entry is most often completed by a change that never mentions it, and a check of the code alone reads such an entry as live.

Return, for each entry, by its file's name:

- **Relevance** — one of:
  - `live`: still needed, and its facts still hold;
  - `stale`: still needed, but a fact in it is wrong (a file renamed, a count changed, a premise moved). Name the fact and its correction;
  - `partly-done`: some of its work is on the trunk. Name what is done and by which change or pull request, and what remains;
  - `obsolete`: done, or no longer needed. Name the change or pull request that did it, or what made it unnecessary;
  - `waiting`: blocked, and its trigger has not fired. Name the trigger and how you checked it. If the trigger *has* fired, say so: that entry is takeable, not waiting.
- **Priority** — where the README names `priority`: for a `high` entry, whether the evidence it names still holds; for a `parked` one, whether its `parked_until` now holds, with the evidence either way. A parked entry whose condition holds is unparked; a `high` one whose evidence no longer holds is stale.
- **Waits for** — for an entry carrying `waits_for`, whether the condition now holds, with the evidence. One that holds makes the entry takeable once updated.
- **Names** — whether every name in the entry's `waits_on` and `design_with` is an entry or a change, open or archived. An unknown name, neither an entry nor a change, is a stale fact.
- **Workstream** — where the README names `workstream`: whether the workstream the entry names is open, a file in `docs/workstreams/` and not under its `archive/`. An entry naming a workstream that is archived or absent is stale.
- **Kind** — one of `fix`, `change` or `fix?`, with the reason: whether it owes a specification delta, whether it needs a decision from the operator, and whether it fits one review sitting. `fix?` is for an entry that owes no delta and no decision but whose size you cannot settle; say what makes it uncertain.
- **Evidence** — the paths, commits, changes or pull requests each verdict rests on.
- **Overlap** — any other entry in your range that describes the same change, or shares a design with this one.

Report a source you could not reach (the forge, say) at the top of your report, and mark every verdict that depended on it as unverified.

## The merged report

The skill merges every agent's return into one report, in these sections, each listing entries by name with the evidence carried over:

1. **Done or obsolete**: proposed for deletion.
2. **Recorded twice**: pairs (or more) that are one change, as duplicates proposed to merge into one entry under one name. An agent sees only its own range, so the skill compares across ranges for this.
3. **Stale facts**: each with its correction, among them each `high` entry whose evidence no longer holds, its `priority` corrected as the README directs, each entry naming a workstream that is archived or absent, proposed re-pointed to an open workstream or set to the README's absent value (`none` in the seeded README), and each entry naming an unknown name in `waits_on` or `design_with`.
4. **Partly done**: each with what remains, proposed as a rewrite of the entry.
5. **Now unblocked or unparked**: entries whose wait is satisfied, proposed with the archived names removed from `waits_on` and a `waits_for` that holds removed, and parked entries whose `parked_until` now holds, with the evidence that it holds and their `priority` proposed as the README directs.
6. **Groups**: entries that share a design, proposed for `design_with`.
7. **Fixes**: entries that can be taken as fixes, with the `fix?` ones listed apart with their reason.
8. **Unverified**: verdicts that rest on a source an agent could not reach.

Where the README names `re_checked`, every entry file the audit touches gets today's date in it when the cleanup is applied, as one edit across the entry files; approving the cleanup is not approving keys the README does not define. Nothing in this report is applied until the operator approves it.
