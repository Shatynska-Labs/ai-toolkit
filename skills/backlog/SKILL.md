---
name: backlog
description: >
  This skill should be used when the user wants to work on a project's
  backlog in docs/backlog/ or its docs/workstreams/ — "add this to the
  backlog", "record this as a backlog entry", "what can I pick up from the
  backlog", "close the x backlog entry", "sweep the backlog for the change I
  just archived", "audit the backlog", "is the backlog still accurate",
  "where does the x workstream stand", "what's in flight". It performs six
  operations in the project it is invoked in: record, pick, close, sweep
  (the archive re-read, by name and by what the change's merged pull
  requests touched), audit (parallel read-only agents, applied only on the
  operator's word) and workstreams (each open workstream's steps and their
  status, read from the repository). It reads entry and workstream rules
  from each directory's AGENTS.md. Not for writing them (project-init),
  nor for converting a single-file docs/backlog.md (scripts/backlog-migrate),
  nor for opening, proposing or implementing the change an entry names
  (openspec-new-change, openspec-propose, openspec-apply-change).
metadata:
  tags: [project-lifecycle]
---

# backlog

Six operations over `docs/backlog/` and `docs/workstreams/` in the project this skill is invoked in. `docs/backlog/AGENTS.md` states how an entry is named, shaped, kept and deleted; `docs/workstreams/AGENTS.md` states how a workstream is named, shaped, kept and archived and how a step's status is read; and the project's workflow rules state when each is written and re-read. This skill states none of them. It is how to carry them out, and a session that never loads it still owes everything those documents say.

## Before any operation

A directory's **rules file** is its `AGENTS.md` where that file holds the managed block of the directory's rules (`<!-- ai-toolkit:backlog ` or `<!-- ai-toolkit:workstreams `), and its `README.md` where it holds no block: the shape before `1.0.0`, which a project keeps until an update converts it. Read whichever it has; never write a rules file or convert one into the other. Below, a directory's README means its rules file.

Find the rules file of `docs/backlog/` at the project root.

- Where it is absent and `docs/backlog.md` exists, the backlog is still in the single-file shape. Say so, name `scripts/backlog-migrate` as what converts it, and stop: perform no operation, and neither convert the file yourself nor read or write it as if it were the directory.
- Where `docs/backlog/` holds no rules file — `docs/backlog/AGENTS.md` absent or without its block, and no README — and there is no `docs/backlog.md`, say so and name `project-init` as what writes the backlog's rules; create nothing with text of your own.

Read the README and take the entry shape, the frontmatter's form, the meaning of an absent key and the deletion grounds from it. Where it differs from what you expect, it wins: this skill checks entries against the shape the README states, never against one of its own. Where the README's shape lacks a key an operation below names (`priority`, `kind`, `waits_on`, `waits_for`, `design_with`, `workstream`, `re_checked`), skip that step and say so. Never write a key the README does not define.

The entries are the other files in `docs/backlog/`, one per entry, each named `<name>.md` for the entry's name; `AGENTS.md`, `CLAUDE.md` and `README.md` are never entries.

Where `docs/workstreams/` holds a rules file, read it too, and take the workstream shape, the status lookups and their precedence, and the archive rules from it; it wins over anything here, as the backlog's README does. Where `docs/workstreams/AGENTS.md` is absent or holds no block, and the directory has no README either, say so, name `project-init` as what writes it, and skip every workstream step below; do not create the file. The steps that read or write an entry's `workstream` apply only where the backlog's README names it; the steps that check a workstream exists, and **workstreams**, need the workstreams README.

Two terms the operations share:

- An entry is **unwaited** where its `waits_on` is empty and it carries no `waits_for`.
- Its wait is **satisfied** where every name in `waits_on` is an archived change and, where it carries `waits_for`, the condition is shown to hold. A `waits_for` you cannot show holds is a wait.

The checks and gates below bind you only while you run the operation. An entry written by hand without them is not deficient for lacking them.

## record

Write one entry as its own file, `docs/backlog/<name>.md`: its values as frontmatter in the form the README states, its prose and reasons as the body. Create exactly that one file, and change no other entry file and not the README.

1. **Fold in.** Where you are in a change, test the work against the fold-in rule the project's workflow states, if it states one. Where the work meets it, say that it can be folded into that change and write no entry.
2. **Name.** Check the proposed name against the entry files in `docs/backlog/`, every directory under the project's open and archived changes (for OpenSpec, `openspec/changes/` and `openspec/changes/archive/`, where archived names carry a date prefix), and every local and remote branch. If any already uses it, do not write the entry; ask for another name. Refuse `readme`, `agents` and `claude` in any case too: their files would collide with `README.md`, `AGENTS.md` and `CLAUDE.md` where the filesystem ignores case.
3. **Kind.** Set `kind` by the README's own definition and write the reason in the body: for a change, which delta it owes, which decision it needs, or that it is too large.
4. **Waits.** Write into `waits_on` only names, of entries or changes. Write a wait on anything else, such as an answer, an access grant or an event, as a condition in `waits_for`.
5. **Design with.** Search the existing entries for ones naming the same files, specifications or capabilities. Present each as a Design with candidate and say what they share. Write into `design_with` only the candidates the session or the operator confirms share a design, or the README's empty value, `[]` in the seeded README. A shared pointer is evidence of a shared design, not the same thing.
6. **Workstream.** Default `workstream` to the open workstream the change you are in serves, as its proposal or a workstream's steps name it, and otherwise to the README's absent value, `none` in the seeded README; write another open workstream, or that absent value, where the session or the operator states the entry serves another goal or none. Write only a name an open workstream carries. Where the workstreams README exists, the name check in step 2 also covers workstream names, open and archived.
7. **Recorded by.** As the README describes it, with the reason in the body.
8. **Priority.** Where the README names `priority`, set it to the README's default, `normal` in the seeded README, unless the session or the operator states the evidence or the condition the README requires for another value. Propose `high` with its evidence, or `parked` with its `parked_until`, and write either only once the operator confirms it.
9. **Re-checked.** Set `re_checked` to today's date.

## pick

List what can be taken now. Pick is read-only: it writes nothing and opens no change.

- **Takeable** — unwaited entries, whose `waits_on` is empty and which carry no `waits_for`, split into `fix` and `change`. Entries that name each other in `design_with` are listed together, as one group. Where the README names `priority`, `high` entries come first, and a group is placed by its highest-priority member.
- **Takeable once updated** — entries whose wait is satisfied but which were never updated: a `waits_on` naming a change that is now archived, or a `waits_for` shown to hold; and parked entries whose condition, their `parked_until`, already holds and which are unwaited or satisfied. List them apart and name the archived change, the evidence, or what fulfilled the condition, rather than hiding them as blocked.
- **Parked** — a parked entry is not takeable. List it apart, under Parked, with its condition, its `parked_until`, where it is unwaited or its wait is satisfied, naming any satisfied wait beside it. The wait governs first: a parked entry still waiting on something unsatisfied is blocked, and is not listed anywhere.
- **Unclassified** — entries missing a key that decides the outcome (see below).

Where the README names `workstream`, group without changing what is takeable, which the wait alone decides. Within each of the takeable `fix` and `change` lists, list the entries naming one workstream together, as one group placed by its highest-priority member, as a Design with group is. Inside a group, `high` entries come first, then the rest in the workstream's step order, then the entries naming it that no step names, marked unplaced. A Design with group whose members name different workstreams goes in the group of its highest-priority member, then of its earliest step, at its earliest member's step position. Entries naming no workstream, by the README's absent value (`none` in the seeded README) or an earlier `nothing`, are grouped as above.

Given paths, narrow every list to entries that name one of them.

## close

Delete the file of the entry you are given. In the same edit, remove its name from the `waits_on` and `design_with` of every other entry naming it; where it was an entry's only `waits_on`, that entry's `waits_on` is now `[]`. No entry may be left pointing at a name the backlog no longer carries. Where an open workstream's steps name the closed entry, name that workstream and step so its plan can be revised; close edits only the backlog's entry files, never the workstream file.

## sweep

Given a change, find the entries it completed, made obsolete, unblocked, unparked or made stale, and update each entry's file as the README directs.

1. **What the change touched.** Read it from the change's merged pull requests on the forge, every one of them, since a change takes at least two: `gh pr list --state merged --head <branch> --json number`, then `gh pr view <number> --json files` for each. Where the forge cannot be reached, fall back to the change's specification deltas and the files its design and tasks name, and say that the fallback was used. Do not use the branch's diff against the trunk: by the archive step the branch has been brought back to the trunk, and a squash merge leaves no ancestry, so that diff holds the record alone.
2. **Which entries.** Those naming the change; those whose `waits_on` names it, with the name proposed removed; those whose `waits_for` it fulfils; parked entries whose condition, their `parked_until`, it fulfils, and `high` entries whose evidence it removed, each with its `priority` proposed as the README directs; those naming a file, specification or capability it touched; and, where the change's archive archives its workstream, those naming that workstream, to be re-pointed or set to the README's absent value as `docs/workstreams/AGENTS.md` directs. The group naming files, specifications or capabilities is the one a search by name misses, because a change that finishes an entry's work seldom names the entry.
3. **Present, then edit.** Show each entry with what the change did to it. Make the edits once the session or the operator agrees.
4. **Where the edit goes.** Run before the archive commit, leave the edit for that commit. Run after the change's record is already on the trunk, make the same edit and say that it is to be delivered as work too small to be a change.

## audit

A full check of every entry against the repository. It fans out to parallel read-only agents. The brief each agent receives, the verdict vocabulary and the merged report's sections are in `references/audit.md`; read it before dispatching.

1. Commit or set aside any uncommitted work first. An agent that writes by mistake then shows in `git status` and is undone with `git restore`.
2. Split the entry files into ranges of about 25. Twenty-five or fewer run as one agent.
3. Dispatch one agent per range, in parallel, each with the brief and its range's entry files verbatim.
4. Merge the returned verdicts into the one report `references/audit.md` describes, and present it.
5. Change nothing until the operator approves the cleanup. Then apply it as one edit across the entry files, delivered as work too small to be a change.

## workstreams

Report where each open workstream stands. It is read-only: it writes nothing, opens no change, and never edits or archives a workstream, even one whose every step is done.

1. **Steps and status.** For each open workstream, list its steps in order, each with its status — done, in flight, recorded or planned — derived by the step's name, with the sources and precedence the README states. Read change directories and the backlog's entry files from the freshly fetched trunk, and branches and pull requests from the local repository, the remote and the forge. Where the forge cannot be reached, say so and derive from what you can reach.
2. **Next.** Name as next the first step in list order that is planned, or recorded with an entry pick would list as takeable: unwaited or its wait satisfied, and not parked. Never name a step in flight or done: list order is never a wait.
3. **Unplaced.** List the entries, and the open changes whose proposals name the workstream, that name it while no step names them, as unplaced. Show each unplaced open change beside the planned steps, since it may be one of them opened under another name.
4. **Done when.** Where every step is done, say that the workstream's Done when is to be checked.

Given a name, report that workstream alone.

## Entries missing a key

`scripts/backlog-migrate` writes no key an older entry never had, so an entry may lack `kind`, `priority` or `workstream`. Where a missing key decides an operation's outcome, report the entry as unclassified, never as a fix or a change, and never omit it. Do not invent the key's value. A key the README itself gives a default for is not missing: read the entry as that default, as the seeded README does for `priority`, and do not report it as unclassified. An earlier `nothing` written by hand in `design_with` or `workstream` is read as the README's absent value: the entry names no entry to design with, or no workstream, and is not reported as unplaced, unclassified or as a name. Rewrite an entry into the current shape only when the operator asks.

## Trigger check fixtures

- **Positive** — "Add this to the backlog: the install script should verify the plugin version before writing the managed block." → expected routing: `backlog`.
- **Positive** — "Where does the test-speed workstream stand, and what's next in it?" → expected routing: `backlog`.
- **Negative** — "Open a change for the `seed-the-worktree-ignore-entry` backlog entry." → expected routing: `openspec-new-change`.
