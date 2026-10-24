## Context

The rules already have two records outside a change. One is the change's own artifacts, which are archived with it. The other is `docs/backlog.md`, the changes identified and not yet opened. Neither holds a goal that takes several changes. An archived change's record says what it did, not what comes after it. A backlog entry says what it is, and through **Waits on** and **Design with** what it relates to, but the backlog holds only what is not yet opened. A goal's done and in-flight steps are in neither.

The ownership seam that the backlog follows applies here unchanged:

- `project-bootstrap` seeds a file and owns the rules stated in it;
- `session-workflow` owns when the fragment sends a session to the file, and defers to the file for its rules;
- `backlog-maintenance` performs operations over the files and restates neither.

This change adds one seeded file, `docs/workstreams/README.md`, which owns the workstream rules. It also adds one entry field, which `project-bootstrap` owns in the seeded backlog.

Consumers matter here. commerce-ops (the motivating case) carries a v10 block and an old-shape backlog. Neither is rewritten by `project-init`. It adopts this in a change of its own.

## Goals / Non-Goals

**Goals:**
- A goal that takes more than one change has one place that names it, says when it is finished, and lists its steps in order.
- A change, and an entry a change records, can be traced to the goal it serves.
- Where a goal stands can be read at any moment without that place having been updated.
- A finished goal leaves the working set and stays readable.

**Non-Goals:**
- Status written into the workstream file. See decision 3.
- A workstream for every change. A change that serves no larger goal states that it advances none.
- Migrating any project's existing documents. commerce-ops's roadmap and phase plans are its own adoption change.
- Nesting: a workstream holds changes, not other workstreams.

## Decisions

**1. The name is *workstream*** (operator, 2026-10-24). The alternatives clashed with vocabulary already in use:
- *stage* is the workflow's;
- *phase*, *campaign* and *track* are commerce-ops domain words;
- *thread* is Slack's;
- *epic* carries Jira's apparatus;
- *initiative* the operator declined.

"Workstream" names what the operator does: several parallel lines of work, each advanced by a sequence of changes.

**2. One file per workstream, archived rather than deleted** (operator, 2026-10-24). A workstream lives at `docs/workstreams/<name>.md`, and a finished one moves to `docs/workstreams/archive/<YYYY-MM-DD>-<name>.md`, dated the day it is archived, as OpenSpec dates an archived change. One file per workstream means parallel sessions in different workstreams never edit one file. Archiving keeps a finished goal's plan and decisions readable after the goal is done.

The alternatives considered:
- one `docs/workstreams.md`: every archive in every session would edit it;
- sections inside the backlog: they contradict "the order of entries carries no meaning", and the backlog holds only unopened work.

**3. The file holds the plan, never the status.** A step's status is derived, and the first of these that matches wins:
- `done`: an archived change directory of that name on the freshly fetched trunk;
- `in flight`: an open change directory of that name on the freshly fetched trunk, a local or remote branch of that name, or an open pull request from one;
- `recorded`: a `docs/backlog.md` heading of that name on the freshly fetched trunk;
- `planned`: none of these.

The order matters because the sources overlap in the normal lifecycle. An entry survives until its change is archived, so it coexists with the open change. A branch survives until the record's pull request merges, so it coexists with the archived directory. Reading from the trunk, not from the session's own working tree, means every session derives the same answer. A worktree cut before a step was archived would otherwise misreport it.

`docs/roadmap.md`'s *In flight now* table in commerce-ops is the failure this avoids. It was correct when written and wrong two weeks later, because progress happens in every session while the table is edited by none. Status derived from the repository is current whenever it is read. The cost is that reading it takes the skill's **workstreams** operation, or a session doing the same lookups by hand. The seeded README states the lookups, so the skill is not required.

So the file is edited only when the **plan** changes: a step added, removed, reordered or renamed, the Done when revised, or the workstream archived. Edits are therefore rare, which is the other half of decision 2's conflict argument.

**4. A step is named by the change it is expected to be.** A step's name is a kebab-case change name. It is the name the step's backlog entry, branch and change directory take, so the step's status can be derived by name. A session that opens or renames a step's change under a different name updates the step in the same commit.

**List order is the intended order of work, and it gates nothing.** Precedence has one authority: a step that cannot start before another says so in its backlog entry's **Waits on**, which **pick** and the archive re-read already read. A second precedence statement in the workstream file would be the two-sided constraint `project-bootstrap` dropped from the backlog because the two sides drift. So **next** (decision 11) reads list order only to choose among steps that Waits on leaves takeable, and a step has no "comes after" clause.

**5. Membership is stated from both sides, and the file side is authoritative.** A change belongs to a workstream when a step names it. A backlog entry, or a proposal, may also name the workstream it serves. This is how derived work is attached without editing the workstream file at the moment it is found. An entry that names a workstream no step names is **attached but unplaced**. The next edit of the workstream places it, as a step, or detaches it, setting the entry's Workstream to `nothing`. That edit comes at the latest at the archive of a change in that workstream. The same holds for an open change whose proposal names the workstream when no step names it, which is the trace of a step opened under another name. **workstreams** reports both as unplaced, and **pick** reports unplaced entries, so neither is lost.

**6. Opening a workstream is the operator's decision; a session proposes it.** A session that sees that a goal needs more than one change, and that no workstream holds it, proposes opening one. It does not open one alone. A workstream reorganises how the operator's work is seen, and that is the operator's judgement. The file is committed with the plan of the first change that advances it, or delivered as work too small to be a change.

**7. Archiving a workstream.** At the archive of a change in a workstream, the session re-reads the workstream, as the fragment directs. Once its Done when holds, the file moves to `archive/`, in the commit that carries the record. Before the move:
- the change whose record this commit carries counts as done, though the trunk shows it archived only once the commit merges;
- every other step not done is removed from the steps. A `recorded` or `planned` step still wanted is first kept as a backlog entry whose Workstream is `nothing`. An `in flight` step continues as its own change, with no entry, since it already has a branch. Removing a step is a plan change, so the file still records no progress, and an archived workstream lists the steps that were done;
- every backlog entry still naming the workstream is re-pointed or set to `nothing`.

No live entry names an archived workstream.

**A workstream the operator abandons is archived the same way** (operator, 2026-10-24, after the research in decision 14). An **Abandoned** line is added, giving the date and the reason. The archive's dating, step removal and entry re-pointing apply unchanged. Abandoning isn't tied to a change's archive, so it is delivered as work too small to be a change. Without this, a goal that will not be met could only stay open forever or be deleted, losing the plan.

**8. The seeded README** (`docs/workstreams/README.md`):

> # Workstreams
>
> A workstream is a goal that takes more than one change. Each open workstream is one file in this directory, named for the workstream in kebab-case: `<name>.md`. A name is unique among workstreams, open and archived, and is not also a change's name. Refer to a workstream only by that name.
>
> A workstream file holds the plan and never its progress. It does not say which steps are done or in flight. That is read from the repository by a step's name, and the first of these that holds wins: a step is done when the freshly fetched trunk holds an archived change of that name; in flight when it holds an open change of that name, or a local or remote branch or an open pull request of that name exists; recorded when its `docs/backlog.md` has an entry of that name; and planned otherwise. Edit the file only when the plan changes: a step added, removed, reordered or renamed, the Done when or what is out of scope revised, an open question added or answered, or the workstream archived.
>
> The order of the steps is the intended order of work, and it gates nothing. A step that cannot start before another says so in its backlog entry's Waits on.
>
> Open a workstream when the operator decides a goal needs more than one change. Commit it with the plan of the first change that advances it, or as work too small to be a change.
>
> A change or a backlog entry may name the workstream it serves before any step names it. Place each such change or entry among the steps, or detach it, at the next edit of the workstream, and at the latest at the archive of a change in it.
>
> When a workstream's Done when holds, move its file to `archive/<YYYY-MM-DD>-<name>.md`, dated the day it is archived, in the commit that carries the record of the change that completed it. Before moving it, remove from the steps each step not done, other than the change whose record that commit carries. Where a removed step is still wanted, it is first recorded as a backlog entry naming no workstream if it is not yet in flight, and it continues as its own change if it is. Then re-point or clear every backlog entry still naming it.
>
> The operator may abandon a workstream whose goal will not be met. Add an **Abandoned** line with the date and the reason, deal with its steps and entries as above, and move it to `archive/` the same way, as work too small to be a change.
>
> Keep a workstream short: its goal, what finishes it and its steps. Lasting decisions belong in a document or a change's design that the file points to. Keep this file when there is no workstream.
>
> A workstream takes this shape:
>
> ```
> # `workstream-name`
>
> **Goal**: what is true when the workstream is finished, and why it is wanted.
>
> **Done when**: a condition that can be checked against the repository, the forge or production.
>
> **Steps**:
>
> 1. `change-name` — what the step does.
>
> **Not in scope**: what the workstream deliberately leaves out, or leaves to another workstream by name, or `nothing`.
>
> **Open questions**: questions whose answers shape the steps, each deleted once answered, the answer recorded where Decisions points, or `nothing`.
>
> **Decisions**: where the workstream's lasting decisions are recorded, or `nothing`.
>
> **Opened**: the date, and the change or the operator that opened it.
> ```

**9. The backlog's field.** The seeded entry shape gains, after **Design with**:

> **Workstream**: the workstream this entry is a step of or serves, by name, or `nothing`. An entry recorded by a change in a workstream takes that workstream unless it serves another goal. An entry without this field is `nothing`.

Design with stays separate. It groups entries that share a **design**, and that is a property of the work. Workstream places an entry in a **goal's sequence**, and that is a property of the plan. Two entries may share either without the other.

**10. The fragment, version 11.** Two insertions and the status row (decision 13). None of them names an entry field or restates a workstream rule. Each defers to the file, per `session-workflow`'s seam.

- In **draft**, after the existing paragraph:

  > Where a workstream in `docs/workstreams/` names this change among its steps, or the change serves one's goal, the proposal names that workstream; otherwise it states that the change advances none. Where the change is one of several a goal needs and no workstream holds them, propose opening one, as that directory's README directs.

Recording a second change gets no insertion. That an entry takes the recording change's workstream is an entry rule. It lives in the backlog file (decision 9), and the fragment already directs recording "as the file directs". A sentence in the fragment would restate it.

- In **archive**, after the backlog re-read:

  > Where the change advanced a workstream, re-read it the same way: place the entries attached to it, revise the steps the change made obsolete, and archive it once what finishes it holds, as `docs/workstreams/README.md` directs, in the same commit.

The fragment names the directory, as it names `docs/backlog.md`, so the path is fixed where it cannot be archived away. It does not direct creating the README where it is absent. `project-init` creates it, as `session-workflow` already holds for the backlog.

**11. The skill.**
- **record** sets Workstream: by default the workstream of the change the session is in, and the session or operator confirms another or `nothing`. Where the register exists, the name check also covers workstream names, open and archived.
- **pick**: takeability is unchanged and is Waits on's alone. Within each of the Takeable `fix` and `change` lists, entries naming one workstream are listed together as a group. A group is placed by its highest-priority member, as a Design with group is. Inside the group, `high` entries come first, then the rest in step order, then unplaced entries. A Design with group whose members name different workstreams sits in the group of its highest-priority member, then of its earliest step. Within that group it takes the position of its earliest member's step. Entries naming `nothing` are grouped as today.
- **close** reports any workstream whose steps name the closed entry, so its step can be revised. close edits only the backlog.
- **sweep** also finds entries naming a workstream that the change's archive archives.
- **audit** reports an entry whose Workstream names no open workstream under *Stale facts*.
- **workstreams** is new and read-only. For each open workstream it lists the steps with their derived status, by decision 3's precedence and sources. It names as **next** the first step in list order that is `planned`, or `recorded` with an entry that **pick** would list as takeable (its wait `nothing` or satisfied, and not parked). It lists as unplaced the backlog entries and the open changes, by their proposals, that name the workstream without being a step. It says where every step is done that the Done when should be checked. Given a name, it reports that workstream alone.

The operation sits in `backlog` rather than in a skill of its own. The two files refer to each other by name, record and pick already read Workstream, and a second skill would duplicate the *Before any operation* reading of both files. The description gains the workstream phrasings: "where does the x workstream stand", "what's in flight".

Each step applies by what it reads. **record**, **pick**, **close**, **sweep** and **audit** read or write the field only where the backlog's shape names Workstream. The name check, **workstreams**, and the checks against open workstreams need `docs/workstreams/README.md`. A project lacking either skips those steps and is told so, as *Before any operation* already directs. The skill also reads the workstream rules from the README and restates none of them, the same seam it keeps with the backlog's preamble.

**12. `project-init`** seeds `docs/workstreams/README.md` as a separate concern, reported `workstreams: created` or `workstreams: already present`. It follows the backlog's presence rule: a path of any type, a symbolic link included, counts as present. It creates no `archive/` directory, since Git keeps no empty directory; the first archive creates it.

**13. The status row names the workstream first** (operator, 2026-10-24). The row becomes `| <workstream> | <change> | <stage> | <task progress> | <commits> |`. The first cell is `none` for a change that advances none. The cell is filled from the most authoritative source available: the open workstream whose steps name the change; else the workstream the proposal names; else the workstream its backlog entry names; else `none`. The sentence names the workstream an entry names, not a field label, so it keeps the fragment's rule of naming no entry field. The fragment states that order in one sentence beside the row. With five sessions open, the row is what the operator reads to tell which line of work each session belongs to, and a change's name does not say which goal it serves. It comes first because it is the coarser grouping. It changes the line every project's sessions print, so every project's v10 block is now stale in a way its sessions show. That is accepted as the cost of the version bump this change already makes. The fragment's example row becomes `| none | some-change | plan:explore | 0/0 | 1 |`.

The row's requirement already asks for an entering-only verification cell that the v10 fragment's row does not carry. That drift predates this change, which keeps it as it is rather than widening the row twice. It is recorded in this repository's backlog as `reconcile-the-status-row-verification-cell`.

**14. What exists elsewhere, and what was borrowed** (research, 2026-10-24).
- **OpenSpec** (1.15.0) has no grouping above a change. Its beta initiative model was deleted in favour of stores (Fission-AI/OpenSpec#1190, 1.5.0). Stores coordinate several repositories and neither group nor order changes. Change dependencies are an open, deprioritised idea (#889, #1915), and so are namespace folders (#1917). `.openspec.yaml`'s free-text `goal` is not validated, and unknown keys are silently ignored. So the workstream is not written into `.openspec.yaml`: nothing would read or check it there. If #1915 or #1917 ships, a later change maps onto it rather than duplicating it.
- **Spec Kit** (a `roadmap.md` convention), **cc-sdd**, **Agent OS** and **Taskmaster** all *store* step status by hand. **BMAD** has a full initiative > epic > story tree, and adopting it means adopting BMAD. None of them derives status from the repository. Deriving it (decision 3) is kept as this design's distinguishing choice.
- Borrowed, on the operator's choice:
  - abandonment as a closing path, from Linear's Canceled (decision 7);
  - a **Not in scope** section, from Shape Up's no-gos and Spec Kit's scope boundaries;
  - an **Open questions** section, from Rust's tracking issues.
- Not borrowed: dependency edges on steps (decision 4 keeps Waits on as the one authority), and a separate "merged, not yet archived" status (the change's own status row shows its stage).

## Risks / Trade-offs

- **A step renamed without its file.** A change opened under a different name from its step reads as `planned` forever. Mitigation: decision 4's same-commit rule, and **workstreams** listing an open change whose proposal names the workstream that no step names as unplaced, beside the `planned` step it probably is.
- **Unplaced entries accumulate.** Mitigation: the archive re-read places them, and **pick** shows them under their workstream rather than hiding them.
- **Derived status needs lookups.** A session without the skill does them by hand. The README states them, so the plan stays readable either way.
- **Two sessions archiving changes in one workstream at once** both edit its file. Edits are plan changes only (decision 3), so a conflict is rare and local to one file.

## Migration Plan

New projects get both seeded files. Adopting projects add the README and the backlog field by hand, or through a later managed update (`update-managed-block`). The fragment's version moves to 11, so `project-init` reports the skew in every project carrying v10. commerce-ops's adoption is its own change.

## Open Questions

None.
