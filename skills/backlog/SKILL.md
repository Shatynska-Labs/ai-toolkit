---
name: backlog
description: >
  This skill should be used when the user wants to work on a project's
  docs/backlog.md — "add this to the backlog", "record this as a backlog
  entry", "what can I pick up from the backlog", "close the x backlog
  entry", "sweep the backlog for the change I just archived", "audit the
  backlog", "is the backlog still accurate". It performs five operations
  in the project it is invoked in: record, pick, close, sweep (the archive
  re-read, by name and by what the change's merged pull requests touched)
  and audit (parallel read-only agents, applied only on the operator's
  word). It reads entry rules from the file itself. Not for seeding the
  file (project-init), nor for opening, proposing or implementing the
  change an entry names (openspec-new-change, openspec-propose,
  openspec-apply-change).
metadata:
  tags: [project-lifecycle]
---

# backlog

Five operations over `docs/backlog.md` in the project this skill is invoked in. The file's own preamble states how an entry is named, shaped, kept and deleted, and the project's workflow rules state when the backlog is written and re-read. This skill states neither. It is how to carry them out, and a session that never loads it still owes everything those two documents say.

## Before any operation

Find `docs/backlog.md` at the project root. If it is absent, say so and name `project-init` as what seeds it; do not create the file with text of your own.

Read the preamble, everything before the first entry heading, and take the entry shape and the deletion grounds from it. Where it differs from what you expect, it wins: this skill checks entries against the shape the file states, never against one of its own.

The checks and gates below bind you only while you run the operation. An entry written by hand without them is not deficient for lacking them.

## record

Write one entry in the shape the file states.

1. **Name.** Check the proposed name against every entry heading in the file, every directory under the project's open and archived changes (for OpenSpec, `openspec/changes/` and `openspec/changes/archive/`, where archived names carry a date prefix), and every local and remote branch. If any already uses it, do not write the entry; ask for another name.
2. **Kind.** Set it by the file's own definition and write the reason beside it: for a change, which delta it owes, which decision it needs, or that it is too large.
3. **Design with.** Search the existing entries for ones naming the same files, specifications or capabilities. Present each as a Design with candidate and say what they share. Write into Design with only the candidates the session or the operator confirms share a design, or `nothing`. A shared pointer is evidence of a shared design, not the same thing.
4. **Waits on, Recorded by.** As the file describes them.
5. **Re-checked.** Today's date.

## pick

List what can be taken now. Pick is read-only: it writes nothing and opens no change.

- **Takeable** — entries whose Waits on is `nothing`, split into `fix` and `change`. Entries that name each other in Design with are listed together, as one group.
- **Takeable once updated** — entries whose Waits on names something already satisfied, such as a change that is now archived. List them apart and name what satisfied the wait, rather than hiding them as blocked.
- **Unclassified** — entries in an older shape (see below).

Given paths, narrow every list to entries that name one of them.

## close

Delete the entry you are given. In the same edit, update every other entry that names it in Waits on or Design with: remove the name, and where it was an entry's only Waits on, that entry now waits on `nothing`. No entry may be left pointing at a name the file no longer carries.

## sweep

Given a change, find the entries it completed, made obsolete, unblocked or made stale, and update each as the file directs.

1. **What the change touched.** Read it from the change's merged pull requests on the forge, every one of them, since a change takes at least two: `gh pr list --state merged --head <branch> --json number`, then `gh pr view <number> --json files` for each. Where the forge cannot be reached, fall back to the change's specification deltas and the files its design and tasks name, and say that the fallback was used. Do not use the branch's diff against the trunk: by the archive step the branch has been brought back to the trunk, and a squash merge leaves no ancestry, so that diff holds the record alone.
2. **Which entries.** Those naming the change; those whose Waits on it satisfies; those naming a file, specification or capability it touched. The last group is the one a search by name misses, because a change that finishes an entry's work seldom names the entry.
3. **Present, then edit.** Show each entry with what the change did to it. Make the edits once the session or the operator agrees.
4. **Where the edit goes.** Run before the archive commit, leave the edit for that commit. Run after the change's record is already on the trunk, make the same edit and say that it is to be delivered as work too small to be a change.

## audit

A full check of every entry against the repository. It fans out to parallel read-only agents. The brief each agent receives, the verdict vocabulary and the merged report's sections are in `references/audit.md`; read it before dispatching.

1. Commit or set aside any uncommitted work first. An agent that writes by mistake then shows in `git status` and is undone with `git restore`.
2. Split the entries into ranges of about 25. Twenty-five or fewer run as one agent.
3. Dispatch one agent per range, in parallel, each with the brief and its range's entries verbatim.
4. Merge the returned verdicts into the one report `references/audit.md` describes, and present it.
5. Change nothing until the operator approves the cleanup. Then apply it as one edit to `docs/backlog.md`, delivered as work too small to be a change.

## Entries in an older shape

A backlog written before the shape gained its fields is never rewritten by `project-init`, so its entries may carry Depends on and no Kind, Waits on, Design with or Re-checked. Where a missing field decides an operation's outcome, report the entry as unclassified, never as a fix or a change, and never omit it. Do not invent the field's value. Rewrite an entry into the current shape only when the operator asks.

## Trigger check fixtures

- **Positive** — "Add this to the backlog: the install script should verify the plugin version before writing the managed block." → expected routing: `backlog`.
- **Negative** — "Open a change for the `count-a-dangling-ignore-file-link-as-present` backlog entry." → expected routing: `openspec-new-change`.
