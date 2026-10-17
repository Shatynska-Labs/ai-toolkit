# Handoff: fold small work in, and give the backlog a shape and a skill

## Why this was identified

In commerce-ops, `docs/backlog.md` grew from 62 entries (2026-09-27) to 95 (2026-10-15), about 1.5 a day, faster than entries were closed. An audit on 2026-10-17 checked all 92 entries against the trunk, the specs and the git history, using four agents in parallel, one per range of the file. It found:

- 4 entries done or obsolete: two finished by changes that never mentioned them, and two made obsolete by a later reshape of the same pages;
- 2 pairs that were one change recorded twice;
- 8 entries whose facts had gone stale: line numbers, file names, counts, renamed modules;
- 1 entry whose own "trigger to close" had fired without anyone noticing, and 2 entries silently unblocked by a promotion or by access granted elsewhere;
- about 17 entries that need no specification delta and no decision, so they could be closed as fixes, not changes; 6 of them clearly so;
- 8 numeric identifiers used twice. This was fixed separately: the new `project-init` preamble drops the numbers.

At least 10 entries said outright that they were "recorded rather than folded in / rather than fixed there". The cleanup is commerce-ops PR #627.

## The causes

Three rules leave no path for small adjacent work:

1. `rules/development-workflow.md`, **Scope**: "an improvement noticed along the way becomes a separate proposed change rather than being folded in". It sets no size threshold.
2. `rules/development-workflow.md`, **A second change surfacing**: "Record the second before doing anything else about it". Recording is the only outcome it offers.
3. `agents/change-code-reviewer.md:73`: an edit the change's stated scope does not cover is a `scope` finding, and its remedy is "moving it to its own change or a backlog entry". Work a session does fold in is pushed back out at review.

And nothing keeps the backlog true once it is written:

4. No step re-reads entries when the change they wait on, or the change that supersedes them, is archived.
5. Entries carry no structured status. Whether one can be taken now, is blocked, is small enough to be a fix, or belongs with others is written in the prose, when it is written at all.
6. Entries carry detail (line tables, censuses) that goes stale first and is redone by whoever takes the entry anyway.

## What to change

### 1. Fold in rather than record

Add to **Scope**, after the sentence quoted above:

> **Fold in rather than record** when the work (a) touches code or files the change already edits, or their direct tests; (b) owes no specification delta and no decision from the operator; and (c) is small — a defect, a test-tier correction, a doc or naming fix, roughly a screen of diff. Make it a separate commit inside the change (`fix:` / `refactor:` / `test:`), and name it in the PR description. Everything else — a delta, a decision, another context, or something large — still goes to the backlog.

In **A second change surfacing**, limit the rule to what Scope does not fold in: "A second change Scope does not let you fold in: record it before doing anything else about it."

In `agents/change-code-reviewer.md:73`, add: "An edit meeting Scope's fold-in conditions (a)–(c), in its own commit and named in the PR description, is not a `scope` finding. One failing any condition is, with the remedy unchanged." A folded-in commit is still reviewed for correctness, like any other code in the diff.

### 2. Structured fields in each entry

Extend the entry shape in the backlog preamble `scripts/project-init` seeds:

```
## `change-name`

What the change is and why it is needed, written for a session that has not seen the work that found it.

**Kind**: fix | change — one clause saying why: "no spec delta, test tier only" / "owes a delta to <capability>" / "needs the operator's decision on <question>".

**Waits on**: nothing | a concrete trigger — a change by name, a person's answer, an event ("production runs <change>").

**Design with**: the entries that share a design with this one, by name, or nothing.

**Recorded by**: the change that identified it, and why it was not done there.

**Re-checked**: the date the entry was last verified against the repository.
```

- **Kind** is set when the entry is recorded, using the fold-in test from section 1. An entry recorded as `fix` should say why it was not folded in: usually that it touches files the change does not edit. If there is no such reason, fold it in.
- **Waits on** replaces "Depends on" and widens it beyond changes. A blocked entry names something that can be checked; entries that can be taken now say `nothing`.
- **Design with** replaces the "worth designing with…" notes scattered through entry prose, and makes grouping readable at a glance.
- **Re-checked** formalises what entries already do ad hoc ("Re-checked 2026-09-27: still true …").

### 3. Re-read the backlog at archive

Add to the **archive** step of `rules/development-workflow.md`: before the record's PR, search the backlog for entries that name the archived change, or whose **Waits on** it satisfies. Delete each one it completed or made obsolete. Mark each one it unblocked. Correct facts it made stale, and update their **Re-checked** date. Do this in the archive commit.

In the audit, about half of the problems were exactly this: entries done, obsoleted or unblocked by a change that was archived or promoted while the entry sat unread.

### 4. Pick up fix entries along the way

When a change reaches `build:applying`, read the backlog's `Kind: fix` entries. Take any that touch files the change already edits, as folded-in work under section 1, and delete their entries in the same commit. This is the counterpart of section 1 for entries recorded earlier.

### 5. Keep entries short

An entry says what is needed and why, with pointers: names of files, specs and changes. It leaves out line numbers, census tables and step-by-step plans. Those are the parts that go stale first, and the session that takes the entry up redoes them anyway. A census worth keeping belongs in the change's own artifacts once it is opened.

### 6. A backlog skill

All of the above could live in one skill, for example `backlog`, which `development-workflow.md` points to rather than restating. Its operations:

- **record**: apply the fold-in test first. Fold in if it passes. Otherwise write an entry in the shape from section 2, check its name is unique, and fill **Design with** by searching the existing entries for overlap.
- **pick**: list entries that can be taken now (`Waits on: nothing`), split into `fix` and `change`, with groups formed from **Design with**. Optionally narrow to entries touching given files (section 4).
- **close**: delete an entry taken as a fix or archived as a change, and update the entries that name it in **Waits on** or **Design with**.
- **sweep at archive**: section 3.
- **audit**: the periodic full check. Split the file into ranges and give each range to a read-only agent in parallel. Each agent verifies every entry in its range against the code, the specs (including archived changes), the git log and the forge's PR list. It returns, per entry, a relevance verdict (`live` / `stale` / `partly-done` / `obsolete` / `waiting`, with evidence) and a Kind verdict (`fix` / `change` / `fix?`, with the reason: whether a spec delta is owed, whether a decision is needed, whether it fits one review sitting). The skill then merges the results into one report: stale entries, merges, groups, entries now unblocked, and the fix list. It applies the cleanup as a single fix PR on the operator's word. A cadence of every two to three weeks fits commerce-ops' pace; with sections 2–4 in place the audit should find much less.

The audit's own lesson: the agents had to be told to check `openspec/changes/archive/` and the forge's merged PRs, not only `src/`. Two of the four stale entries were done by changes that never named them.

## What bears on it

- Consuming projects carry `rules/development-workflow.md` as the generated `AGENTS.md` block `ai-toolkit:development-workflow` (commerce-ops is at v4). These changes reach a project only through a block-version bump and a re-run of the update. The backlog preamble reaches existing backlogs only by hand: `project-init` writes `docs/backlog.md` only when it is absent.
- commerce-ops' `AGENTS.md` still says "A `docs/backlog.md` entry's number is an identifier…" inside the generated block. That sentence should go with this change, now that headings carry no number.
- commerce-ops has a sibling exception outside the block: *Visual work* lets polish beside a substantive change ride along in it. The fold-in rule should read consistently with it.
- In commerce-ops, `docs/backlog.md` is in the inert set, so backlog-only commits skip the static checks and tiers. Any format check for the backlog belongs in ai-toolkit's skill, not in a project test: a test reading the file would make it checked documentation and end that exemption.

## What it must not undo

- Small, focused commits: folded-in work is its own commit, never mixed into the change's commits.
- A plan for anything that changes behaviour a spec describes: condition (b) keeps every spec delta out of the fold-in path, and an entry with `Kind: change` is never taken as a fix.
- One change at a time: folding in never reaches into another context or another change's files (condition (a)).
- Independent review: folded-in commits go through the same `build` review as the rest of the diff.
- The backlog living outside any one change: an entry is still not kept inside the change that recorded it, because archiving that change would lose it.
- Names as the only identifier: no numbers, no ordering that carries meaning.
