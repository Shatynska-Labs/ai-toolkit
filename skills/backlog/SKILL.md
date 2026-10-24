---
name: backlog
description: >
  This skill should be used when the user wants to work on a project's
  docs/backlog.md or its docs/workstreams/ — "add this to the backlog",
  "record this as a backlog entry", "what can I pick up from the backlog",
  "close the x backlog entry", "sweep the backlog for the change I just
  archived", "audit the backlog", "is the backlog still accurate", "where
  does the x workstream stand", "what's in flight". It performs six
  operations in the project it is invoked in: record, pick, close, sweep
  (the archive re-read, by name and by what the change's merged pull
  requests touched), audit (parallel read-only agents, applied only on the
  operator's word) and workstreams (each open workstream's steps and their
  status, read from the repository). It reads entry and workstream rules
  from the files themselves. Not for seeding either
  file (project-init), nor for opening, proposing or implementing the
  change an entry names (openspec-new-change, openspec-propose,
  openspec-apply-change).
metadata:
  tags: [project-lifecycle]
---

# backlog

Six operations over `docs/backlog.md` and `docs/workstreams/` in the project this skill is invoked in. The backlog's own preamble states how an entry is named, shaped, kept and deleted; `docs/workstreams/README.md` states how a workstream is named, shaped, kept and archived and how a step's status is read; and the project's workflow rules state when each is written and re-read. This skill states none of them. It is how to carry them out, and a session that never loads it still owes everything those documents say.

## Before any operation

Find `docs/backlog.md` at the project root. If it is absent, say so and name `project-init` as what seeds it; do not create the file with text of your own.

Read the preamble, everything before the first entry heading, and take the entry shape and the deletion grounds from it. Where it differs from what you expect, it wins: this skill checks entries against the shape the file states, never against one of its own. Where the file's shape lacks a field an operation below names (Priority, Kind, Waits on, Design with, Workstream, Re-checked), use the file's own equivalent where it has one, such as Depends on for Waits on, and otherwise skip that step and say so. Never add a field the file does not define.

Where `docs/workstreams/` holds a README, read it too, and take the workstream shape, the status lookups and their precedence, and the archive rules from it; it wins over anything here, as the backlog's preamble does. Where `docs/workstreams/README.md` is absent, say so, name `project-init` as what seeds it, and skip every workstream step below; do not create the file. The steps that read or write an entry's Workstream apply only where the backlog's shape names Workstream; the steps that check a workstream exists, and **workstreams**, need the README.

The checks and gates below bind you only while you run the operation. An entry written by hand without them is not deficient for lacking them.

## record

Write one entry in the shape the file states.

1. **Fold in.** Where you are in a change, test the work against the fold-in rule the project's workflow states, if it states one. Where the work meets it, say that it can be folded into that change and write no entry.
2. **Name.** Check the proposed name against every entry heading in the file, every directory under the project's open and archived changes (for OpenSpec, `openspec/changes/` and `openspec/changes/archive/`, where archived names carry a date prefix), and every local and remote branch. If any already uses it, do not write the entry; ask for another name.
3. **Kind.** Set it by the file's own definition and write the reason beside it: for a change, which delta it owes, which decision it needs, or that it is too large.
4. **Design with.** Search the existing entries for ones naming the same files, specifications or capabilities. Present each as a Design with candidate and say what they share. Write into Design with only the candidates the session or the operator confirms share a design, or `nothing`. A shared pointer is evidence of a shared design, not the same thing.
5. **Workstream.** Default it to the open workstream the change you are in serves, as its proposal or a workstream's steps name it, and otherwise to `nothing`; write another open workstream, or `nothing`, where the session or the operator states the entry serves another goal or none. Write only a name an open workstream carries. Where the README exists, the name check in step 2 also covers workstream names, open and archived.
6. **Waits on, Recorded by.** As the file describes them.
7. **Priority.** Where the file's shape names Priority, set it to the file's default, `normal` in the seeded file, unless the session or the operator states the evidence or the condition the file requires for another value. Propose `high` or `parked` with that evidence or condition, and write either only once the operator confirms it.
8. **Re-checked.** Today's date.

## pick

List what can be taken now. Pick is read-only: it writes nothing and opens no change.

- **Takeable** — entries whose Waits on is `nothing`, split into `fix` and `change`. Entries that name each other in Design with are listed together, as one group. Where the file's shape names Priority, `high` entries come first, and a group is placed by its highest-priority member.
- **Takeable once updated** — entries whose Waits on names something already satisfied, such as a change that is now archived, and parked entries whose condition already holds and whose wait is `nothing` or satisfied. List them apart and name what satisfied the wait or fulfilled the condition, rather than hiding them as blocked.
- **Parked** — a parked entry is not takeable. List it apart, under Parked, with its condition, where its wait is `nothing` or already satisfied, naming any satisfied wait beside it. Waits on governs first: a parked entry still waiting on something unsatisfied is blocked, and is not listed anywhere.
- **Unclassified** — entries in an older shape (see below).

Where the file's shape names Workstream, group without changing what is takeable, which Waits on alone decides. Within each of the takeable `fix` and `change` lists, list the entries naming one workstream together, as one group placed by its highest-priority member, as a Design with group is. Inside a group, `high` entries come first, then the rest in the workstream's step order, then the entries naming it that no step names, marked unplaced. A Design with group whose members name different workstreams goes in the group of its highest-priority member, then of its earliest step, at its earliest member's step position. Entries naming `nothing` are grouped as above.

Given paths, narrow every list to entries that name one of them.

## close

Delete the entry you are given. In the same edit, update every other entry that names it in Waits on or Design with: remove the name, and where it was an entry's only Waits on, that entry now waits on `nothing`. No entry may be left pointing at a name the file no longer carries. Where an open workstream's steps name the closed entry, name that workstream and step so its plan can be revised; close edits only the backlog, never the workstream file.

## sweep

Given a change, find the entries it completed, made obsolete, unblocked, unparked or made stale, and update each as the file directs.

1. **What the change touched.** Read it from the change's merged pull requests on the forge, every one of them, since a change takes at least two: `gh pr list --state merged --head <branch> --json number`, then `gh pr view <number> --json files` for each. Where the forge cannot be reached, fall back to the change's specification deltas and the files its design and tasks name, and say that the fallback was used. Do not use the branch's diff against the trunk: by the archive step the branch has been brought back to the trunk, and a squash merge leaves no ancestry, so that diff holds the record alone.
2. **Which entries.** Those naming the change; those whose Waits on it satisfies; where the file's shape names Priority, parked entries whose condition it fulfilled and `high` entries whose evidence it removed, each with its Priority proposed as the file directs; those naming a file, specification or capability it touched; and, where the change's archive archives its workstream, those naming that workstream, to be re-pointed or set to `nothing` as `docs/workstreams/README.md` directs. The group naming files, specifications or capabilities is the one a search by name misses, because a change that finishes an entry's work seldom names the entry.
3. **Present, then edit.** Show each entry with what the change did to it. Make the edits once the session or the operator agrees.
4. **Where the edit goes.** Run before the archive commit, leave the edit for that commit. Run after the change's record is already on the trunk, make the same edit and say that it is to be delivered as work too small to be a change.

## audit

A full check of every entry against the repository. It fans out to parallel read-only agents. The brief each agent receives, the verdict vocabulary and the merged report's sections are in `references/audit.md`; read it before dispatching.

1. Commit or set aside any uncommitted work first. An agent that writes by mistake then shows in `git status` and is undone with `git restore`.
2. Split the entries into ranges of about 25. Twenty-five or fewer run as one agent.
3. Dispatch one agent per range, in parallel, each with the brief and its range's entries verbatim.
4. Merge the returned verdicts into the one report `references/audit.md` describes, and present it.
5. Change nothing until the operator approves the cleanup. Then apply it as one edit to `docs/backlog.md`, delivered as work too small to be a change.

## workstreams

Report where each open workstream stands. It is read-only: it writes nothing, opens no change, and never edits or archives a workstream, even one whose every step is done.

1. **Steps and status.** For each open workstream, list its steps in order, each with its status — done, in flight, recorded or planned — derived by the step's name, with the sources and precedence the README states. Read change directories and the backlog from the freshly fetched trunk, and branches and pull requests from the local repository, the remote and the forge. Where the forge cannot be reached, say so and derive from what you can reach.
2. **Next.** Name as next the first step in list order that is planned, or recorded with an entry pick would list as takeable: its Waits on `nothing` or satisfied, and not parked. Never name a step in flight or done: list order is never a wait.
3. **Unplaced.** List the backlog entries, and the open changes whose proposals name the workstream, that name it while no step names them, as unplaced. Show each unplaced open change beside the planned steps, since it may be one of them opened under another name.
4. **Done when.** Where every step is done, say that the workstream's Done when is to be checked.

Given a name, report that workstream alone.

## Entries in an older shape

A backlog written before the shape gained its fields is never rewritten by `project-init`, so its entries may carry Depends on and no Kind, Waits on, Design with or Re-checked. Where a missing field decides an operation's outcome, report the entry as unclassified, never as a fix or a change, and never omit it. Do not invent the field's value. A field the file itself gives a default for is not missing: read the entry as that default, as the seeded file does for Priority, and do not report it as unclassified. Rewrite an entry into the current shape only when the operator asks.

## Trigger check fixtures

- **Positive** — "Add this to the backlog: the install script should verify the plugin version before writing the managed block." → expected routing: `backlog`.
- **Positive** — "Where does the test-speed workstream stand, and what's next in it?" → expected routing: `backlog`.
- **Negative** — "Open a change for the `count-a-dangling-ignore-file-link-as-present` backlog entry." → expected routing: `openspec-new-change`.
