## MODIFIED Requirements

### Requirement: A workstream register is seeded where none exists

*Modified by `propose-a-workstream-for-entries-sharing-a-goal`: a session that finds a goal no open workstream holds, shared by changes it proposes or by entries naming `none`, proposes a workstream to the operator, and detaching reads the entries it clears with those already naming `none` and ends in a value or a deletion, never a deferral. Every scenario keeps its title; two are added.*

*Modified by `match-backlog-entries-to-a-workstream`: an entry is placed when it is recorded, or left for the archive with the reason said; detaching re-points before it clears, a workstream's archive included; and only a step's own name places anything. Every scenario keeps its title; one is added.*

*Modified by `list-what-a-project-receives`: the rules are a managed block in `docs/workstreams/AGENTS.md`, read from the fragment `rules/workstreams.md`, beside a `CLAUDE.md` importing it, and a register holding them in a README is reported, not converted. Every scenario keeps its title.*

*Modified by `one-file-per-backlog-entry`: a step is recorded where `docs/backlog/` holds an entry of its name, and a step's ordering wait is its entry's `waits_on`.*

*Modified by `observe-what-finishes-a-workstream`: a workstream's Done when names an observable effect of its Goal, and every step being archived may stand beside it but never in its place.*

*Modified by `hold-shared-research-in-a-workstream`: a workstream holds, besides its plan, the context and decisions its steps share, which are never progress and are revised in place when overturned.*

*Modified by `define-what-a-step-is`: a step taken as a fix is done once its pull request has merged, every step being done replaces every step being archived beside the Done when's effect, and a change is a step of one workstream only. Every scenario keeps its title.*

Where `docs/workstreams/` holds neither a block of that name in `AGENTS.md` nor a `README.md`, the tool SHALL write the workstreams' rules as a managed block into `docs/workstreams/AGENTS.md`, in both the new-project and the adoption mode, creating `docs/workstreams/` if absent, appending the block to an `AGENTS.md` the directory already holds and creating that file otherwise, and SHALL give the directory a `CLAUDE.md` as *A directory's rules block is imported by a `CLAUDE.md` beside it* states. Where the block is present, the tool SHALL leave every file in the directory byte-for-byte unchanged and report the register present, with the versions *Workflow rules reach a project as a versioned managed block* requires of a block already present. Where the directory holds `README.md` and no such block, the tool SHALL act as *A directory holding its rules in a README is reported, not converted* states. The tool SHALL NOT create `docs/workstreams/archive/`.

The tool SHALL read the block's text from the fragment `rules/workstreams.md`, which the manifest lists under the name `workstreams` with `docs/workstreams/AGENTS.md` as its target, and SHALL write the fragment's body without its frontmatter.

A workstream is a goal that takes more than one change. The workflow fragment sends a session to this directory at a change's proposal and at its archive, and defers to the directory's `AGENTS.md` for how a workstream is written, as it defers to the backlog's for an entry. Unseeded, each project's first session would invent those rules, and the fragment's references would mean something different in every project.

The block SHALL state, as prose a session has loaded once it reads or writes a file in the directory, before opening, editing or archiving a workstream:

- that a workstream is a goal that takes more than one change, each open one a file in this directory named `<name>.md` for its kebab-case name, unique among workstreams open and archived and not also a change's name, and referred to only by that name;
- that `readme`, `agents` and `claude`, in any case, are not workstream names, for the same collision;
- that a workstream file holds the plan and never its progress, and that a step's status is read from the repository by the step's name, the first that holds winning: done where the freshly fetched trunk holds an archived change of that name, or where it holds no change of that name, open or archived, and a pull request from a branch of that name has merged — a step taken as a fix; in flight where it holds an open change of that name, or a local or remote branch or an open pull request of that name exists; recorded where its `docs/backlog/` holds an entry of that name; and planned otherwise; and that a session that cannot reach the forge says so rather than reading as planned a step a merged pull request could make done;
- that the order of the steps is the intended order of work and gates nothing, a step that cannot start before another saying so in its backlog entry's `waits_on`;
- that a change is a step of one workstream only: another workstream whose goal also needs it does not list it among its steps, and a step of that workstream that cannot start before the change names it in its backlog entry's `waits_on`, an entry being recorded for that step where it has none;
- that the file is edited only when the plan or what it holds changes — a step added, removed, reordered or renamed, what finishes it or what is out of scope revised, an open question added or answered, context or a decision added or revised, or the workstream archived;
- that a workstream is opened when the operator decides a goal needs more than one change; that a session finding such a goal that no open workstream holds, shared by changes it proposes or by backlog entries naming `none`, proposes opening one to the operator, naming those changes and entries and a draft Goal, opens none unasked, and proposes none for a goal one change meets; and that it is committed with the plan of the first change that advances it or as work too small to be a change;
- that a change or a backlog entry may name the workstream it serves before any step names it, that an entry is placed among the steps when it is recorded, or left for the archive with the reason said, and that each such change or entry is placed among the steps or detached at the next edit of the workstream other than one placing a recorded entry, and at the latest at the archive of a change in it;
- that detaching re-points a change or an entry to another open workstream whose Goal it serves and whose Not in scope does not leave it out, and clears it to `none` only where there is none, after reading it with the entries already naming `none` and the others detached in the same edit for a goal they share and proposing a workstream for it as above; and that each detached entry is re-pointed, cleared after that read, or deleted on a ground the backlog's rules give, a note deferring the read not detaching it;
- that a step names a change or an entry only by its own name, the backticked name a numbered step begins with, and that a mention in a step's description, in Context or in Decisions places nothing;
- that what finishes a workstream, its Done when, is an observable effect of its Goal — what to look at in the repository, the forge or production, what provokes it where something must, and the result that means the Goal holds — and that every step being done may stand beside that effect where it is wanted but never in its place, since it shows only that the step list was worked through, which a list missing a step satisfies as well;
- that when what finishes a workstream holds, its file moves to `archive/<YYYY-MM-DD>-<name>.md`, dated the day it is archived, in the commit that carries the record of the change that completed it, after each step not done, other than the change whose record that commit carries, is removed from the steps, first recorded as a backlog entry detached from it where it is still wanted and not yet in flight, an in-flight one continuing as its own change, and every backlog entry still naming it is re-pointed or cleared by detaching it;
- that the operator may abandon a workstream whose goal will not be met, which gains an **Abandoned** item after Opened, with the date and the reason, has its steps and entries dealt with as on completion, and is moved to `archive/` the same way, as work too small to be a change;
- that besides its plan a workstream holds what its steps share: under `## Context`, the research, findings and options considered that the goal was planned from, with why one option was chosen; and under `## Decisions`, the decisions that shape more than one step or were taken before any step's proposal existed, each with who took it, when and why, a decision already recorded in a change's design pointed to rather than copied;
- that a decision shaping one step only belongs in that step's design, which points to the workstream for what it shares rather than copying it;
- that Context and Decisions say what is known and decided about the goal and never how far the work has come: a finding states what is true of the problem, not that a step found or did it, and neither names a step as done, in flight or merged;
- that Context and Decisions state what is held now: where a change in the workstream overturns something they hold, it is revised in place, naming that change, in its plan commit or at the latest at its archive;
- that this file is kept when there is no workstream;
- the shape of a workstream: its heading, the name; its **Goal**; its **Done when**, an observable effect of the Goal that can be checked against the repository, the forge or production, with every step being done beside it where that is wanted; its **Steps**, an ordered list each naming a change in kebab-case with what it does; what is **Not in scope**, or `none`; its **Open questions**, each deleted once answered with the answer recorded under Decisions, or `none`; and when and by what it was **Opened** — Goal and Done when as paragraphs, and the fields after the steps as one list, one item per field, with no blank line between them; then an optional `## Context` section and an optional `## Decisions` section, in that order, each omitted where it would be empty.

**The file holds no status because status written by hand goes stale.** Progress happens in every session, and a status field is edited by none of them at the moment it changes; a status read from the repository by name is current whenever it is read. That is why a step is named by the change it is expected to be: the name is the key the lookups use. **The precedence and the trunk are stated because the sources overlap**: a backlog entry survives until its change is archived, and a branch until the record's pull request merges, so a step matches more than one source in the ordinary course of its life; and a session's own working tree may predate a step's archive, so reading it would give each session a different answer.

**Done when names an effect of the Goal because the steps are the plan's guess at reaching it.** "Every step is done" is checked against the repository, so it meets the old wording, yet it holds for a step list that missed a step as surely as for one that did not: it confirms the plan was carried out, not that the Goal was reached. A change's `confirm` already asks for its effect to be observed rather than inferred from a merge; a workstream's Done when asks the same of its Goal. Every step being done stays available beside the effect, for a workstream whose steps are each wanted whatever the effect shows.

**A workstream holds what its steps share because nowhere else ties it to the goal.** A change's design belongs to one step and is archived with it, so research shared by several steps is copied into each or leaves with the first to finish; a separate document under `docs/` is tied to no goal and retired by nothing. The workstream file is the one place every step points to, and it is archived whole. The two reasons the file was once kept short still hold, and are answered rather than dropped. Status written by hand goes stale because progress happens in every session; what Context and Decisions hold changes only when understanding of the goal changes, and never records progress. Edits were kept rare so parallel sessions seldom meet in one file; they stay tied to events — research done, a decision taken or overturned — not to sessions. **Overturned content is revised in place** (operator, 2026-10-27) because a record a reader must reconcile entry by entry is the stale table in another form; the file's history keeps what was held before.

**A fix's merged pull request is its record.** A fix skips `plan`, so it leaves no change to archive, and its backlog entry is deleted when it is taken; a step taken as a fix would otherwise fall back to `planned` once finished, be named as next, and keep a Done when of every step being done from ever holding. Its merged pull request is the one durable trace it leaves, as the archived record is a change's, and its branch is named for the step as a change's is. The pull request counts only where the trunk holds no change of that name, because a change's work pull request merges from a branch of the same name before the change is archived, while the change itself is still open. Removing a fix step from the steps once taken, the alternative a project used, records progress by editing the plan and erases the step from the plan a retrospective compares with what happened; allowing only changes as steps would leave out of the plan work that serves the goal. **The forge is a source, so its absence is said** rather than read as `planned`: a fix step with no other source reads exactly as an unstarted one.

**A change is a step of one workstream only** (operator, 2026-10-28). The status row's workstream cell, the archive re-read that places entries and revises steps, and a workstream's retrospective each take one workstream for a change; a change listed in two gives each of them two answers, or a rule for choosing between them stated in each. The dependency the second workstream has on the change is a wait, and a wait is already stated in one place, the dependent step's `waits_on`. Naming every workstream in the row, the alternative, would have each of those places handle a list for a case that has arisen once.

**Order gates nothing because precedence already has one authority.** `waits_on` is the side the pick and the archive re-read read, and the backlog dropped a second side because two statements of one constraint drift; a step's "comes after" in the workstream file would reintroduce it.

**A finished or abandoned workstream is archived, not deleted** (operator, 2026-10-24), so its plan, context and decisions stay readable after its goal is met, as an archived change's record does.

**A shared goal is proposed, not opened.** Every other rule choosing an entry's workstream reads the open workstreams only, so entries sharing a goal no workstream holds stay `none` until someone looks across them; in commerce-ops, 40 of 123 entries sat there until the operator asked twice. Opening stays the operator's judgement about their work, so the rule obliges putting the decision in front of them, not taking it. A goal one change meets is not proposed, so `none` stays a legitimate answer. **A deferral is not a detach** because an entry carrying a note to re-check later carries `none` without the read the rule requires.

**This requirement owns the workstream rules**; `session-workflow` owns only when the fragment sends a session to the directory, and its fragment defers to the directory's `AGENTS.md` rather than restating them. `backlog-maintenance` reads them from that file.

The tool SHALL create no workstream.

#### Scenario: A project without a workstream register receives the seeded file

- **WHEN** the tool runs in a target with no `docs/workstreams/`
- **THEN** `docs/workstreams/AGENTS.md` is created holding the block with every statement listed above and no workstream, `docs/workstreams/CLAUDE.md` is created holding `@AGENTS.md`, no `archive/` directory is created, and the report states the workstream register was created

#### Scenario: An existing workstream register is preserved exactly

- **WHEN** the target already contains `docs/workstreams/AGENTS.md` holding a workstreams block
- **THEN** it and every file beside it are left byte-for-byte unchanged, and the report states the workstream register is already present

#### Scenario: The seeded register carries no status field

- **WHEN** the seeded file is written
- **THEN** its workstream shape names Goal, Done when, Steps, Not in scope, Open questions and Opened, and the Context and Decisions sections, and names no field or section recording a step's status

#### Scenario: An abandoned workstream is archived, not deleted

- **WHEN** a session reads the seeded file after the operator decides a workstream's goal will not be met
- **THEN** the file directs adding an Abandoned line with the date and reason and moving the workstream to a dated file under `archive/`, after its unfinished steps and the entries naming it are dealt with

#### Scenario: A finished workstream is archived

- **WHEN** a session reads the seeded file at the archive of the change that made a workstream's Done when hold
- **THEN** the file directs moving the workstream to a dated file under `archive/` in the record's commit, after its unfinished steps and the entries naming it are dealt with

#### Scenario: A step matching two sources takes the first status

- **WHEN** a step's change is open on the trunk and its backlog entry file has not yet been deleted
- **THEN** the seeded file's precedence makes the step in flight, not recorded

#### Scenario: Step order is not a dependency

- **WHEN** a session reads the seeded file to learn whether a step may start before the step listed above it
- **THEN** the file directs it to that step's backlog entry's `waits_on`, and states that list order gates nothing

#### Scenario: The seeded workstream's fields are a list

- **WHEN** the seeded file is written
- **THEN** its workstream shape gives Not in scope, Open questions and Opened as consecutive list items after the steps, each absent value as `none`, gives no Decisions list item, and places `## Context` and then `## Decisions` after the list

#### Scenario: A step is recorded by its entry file

- **WHEN** the seeded file is written
- **THEN** it states that a step is recorded where `docs/backlog/` holds an entry of the step's name, and does not name `docs/backlog.md`

#### Scenario: Done when asks for an observable effect of the Goal

- **WHEN** the seeded file is written
- **THEN** its workstream shape gives Done when as an observable effect of the Goal, and its prose states that every step being done may stand beside that effect but never in its place

#### Scenario: Research shared by several steps has a place in the workstream

- **WHEN** a session reads the seeded file holding research, findings or a decision that shapes more than one step of a workstream
- **THEN** the file directs it to the workstream's `## Context` or `## Decisions` section, and does not direct it to a separate document or keep the workstream short

#### Scenario: A decision for one step stays in that step's design

- **WHEN** a session reads the seeded file holding a decision that shapes one step only
- **THEN** the file directs it to that step's design, which points to the workstream for what it shares rather than copying it

#### Scenario: What a workstream holds is not progress

- **WHEN** a session reads the seeded file to learn what Context and Decisions may say
- **THEN** the file states that they say what is known and decided about the goal, never how far the work has come, and that neither names a step as done, in flight or merged

#### Scenario: Overturned content is revised in place

- **WHEN** a session reads the seeded file in a change in a workstream that overturns something the workstream's Context or Decisions holds
- **THEN** the file directs revising it in place, naming that change, in the change's plan commit or at the latest at its archive

#### Scenario: A step taken as a fix reads as done

- **WHEN** a session reads the seeded file for a step whose name is no change on the trunk, open or archived, and whose branch's pull request has merged
- **THEN** the file's lookups make the step done, not planned

#### Scenario: A change whose work has merged is still in flight

- **WHEN** a step's change is open on the trunk and a pull request from its branch has merged
- **THEN** the seeded file's lookups make the step in flight, not done

#### Scenario: A fix step without the forge

- **WHEN** a session reading a step's status cannot reach the forge and no other source holds for the step
- **THEN** the seeded file directs it to say so rather than read the step as planned

#### Scenario: A change needed by two workstreams is listed in one

- **WHEN** a session reads the seeded file for a change that serves the goals of two open workstreams
- **THEN** the file directs listing the change among the steps of one workstream only, and the other's dependent step naming it in its backlog entry's `waits_on`, recording that entry where the step has none

#### Scenario: The seeded block settles what placing means

- **WHEN** the seeded block is written
- **THEN** it states that an entry is placed when recorded or left for the archive with the reason said, that placing a recorded entry is not the edit at which the others fall due, that detaching re-points to another open workstream whose Goal is served and whose Not in scope admits it and clears only where there is none, and that only a step's own name places a change or an entry

#### Scenario: The seeded block directs proposing a workstream

- **WHEN** the seeded block is written
- **THEN** it states that opening a workstream is the operator's decision, that a session finding a goal no open workstream holds, shared by changes or by entries naming `none`, proposes one with the changes, entries and a draft Goal and opens none unasked, and that a goal one change meets is not proposed

#### Scenario: A detach is not a deferral

- **WHEN** a session reads the seeded block to detach the entries of an abandoned workstream
- **THEN** the block directs reading them with the entries already naming `none` for a shared goal, and re-pointing, clearing or deleting each, and states that a note deferring the read does not detach it

### Requirement: The backlog's rules are written where none exist

*Modified by `propose-a-workstream-for-entries-sharing-a-goal`: before `none` is written, the other entries naming `none` are read for a goal shared with the new one, a workstream is proposed where they share one that takes more than one change, and `none` is written meanwhile. Every scenario keeps its title; one is added.*

*Modified by `report-a-tasks-kind-and-wait`: the entry shape gains `need`, after `kind`, and `waits_for_type`, after `waits_for`, with their meanings, the absent `need` read as `should`, and **Need** among the body's reasons. Every scenario keeps its title; four are added.*

*Modified by `match-backlog-entries-to-a-workstream`: the rule on `workstream` requires reading the open workstreams' Goals before `none` is written. Every scenario keeps its title; one is added.*

*Replaces `A backlog is seeded where none exists`, removed by `list-what-a-project-receives`: the rules are a managed block in `docs/backlog/AGENTS.md`, read from the fragment `rules/backlog.md`, beside a `CLAUDE.md` importing it; a backlog holding them in a README is reported, not converted; a missing fragment blocks every run. The entry rules are carried over unchanged.*

Where neither `docs/backlog/` nor `docs/backlog.md` exists in the target, the tool SHALL write the backlog's rules as a managed block into `docs/backlog/AGENTS.md`, in both the new-project and the adoption mode, creating `docs/` and `docs/backlog/` if absent, and SHALL give the directory a `CLAUDE.md` as *A directory's rules block is imported by a `CLAUDE.md` beside it* states. Where `docs/backlog/AGENTS.md` holds a block of that name, the tool SHALL leave every file in the directory byte-for-byte unchanged and report the backlog present, with the versions *Workflow rules reach a project as a versioned managed block* requires of a block already present. Where `docs/backlog/` holds `README.md` and no such block, the tool SHALL act as *A directory holding its rules in a README is reported, not converted* states. Where `docs/backlog.md` exists and `docs/backlog/` does not, the tool SHALL leave the file byte-for-byte unchanged, create nothing under `docs/backlog/`, and report that the backlog is present in the single-file shape and that `scripts/backlog-migrate` converts it. Where `docs/backlog/` exists as a directory, not through a symbolic link, holding neither a block of that name nor a `README.md`, the tool SHALL write the block, appending it to an `AGENTS.md` the directory already holds and creating that file otherwise, leave every other file in the directory unchanged, and report the rules written beside existing entries. Where `docs/backlog` exists as a symbolic link or as anything other than a directory, the tool SHALL write nothing there and report that the path is not a directory it will write into, the remaining concerns proceeding as usual.

The tool SHALL read the block's text from its own copy of the library, from the fragment `rules/backlog.md`, which the manifest lists under the name `backlog` with `docs/backlog/AGENTS.md` as its target, and SHALL write the fragment's body without its frontmatter, as it does the workflow fragment's. A converted backlog receives the same block from the same tool, so a seeded backlog and a converted one carry the same rules. The fragment's absence blocks as any listed fragment's does.

The workflow fragment routes out-of-scope work to that directory and defers to its `AGENTS.md` for how an entry is written. Rules each project's first session invents carry a different entry shape and deletion rule in every project, so the rules the fragment defers to would not be the same rules anywhere.

The block SHALL state, as prose a session has loaded once it reads or writes a file in the directory:

- that the directory lists changes the project has identified and not yet archived, each recorded instead of being folded into the change that found it, one file per entry beside this file;
- that an entry's file is named for the change's kebab-case name, `<name>.md` — the name its branch and change directory are expected to take, which the session that opens the change may revise if the work turns out different — that the file's name is the entry's only identifier and the file carries no heading repeating it, that an entry is referred to only by that name, and that a fix takes it as its branch's name only;
- that `readme`, `agents` and `claude`, in any case, are not entry names, since their files would collide with `README.md`, `AGENTS.md` and `CLAUDE.md` where the filesystem ignores case;
- that entries carry no order, and that an entry states in its own fields what it waits on, how urgent it is, and which entries share a design with it;
- that an entry is kept short: what is needed and why, with files, specifications and changes named as pointers, and without line numbers, census tables or step-by-step plans;
- that an entry's file is deleted when its change is archived, when the operator takes it as a fix rather than a change, when a change makes it obsolete, or when the operator decides the change will not be made;
- that when a change is archived, the entries it unblocked, unparked or made stale are updated and their `re_checked` date set;
- that this file is kept when there are no entries;
- the shape of an entry's frontmatter, its keys in this order, one per line: `priority`, `high`, `normal` or `parked`; `parked_until`, present only on a parked entry, the condition that can be checked under which it becomes worth taking; `kind`, `fix` or `change`; `need`, `must`, `should` or `could`, measured against the Goal of the entry's workstream — `must` where the Goal does not hold without it, `could` where the Goal holds without it and the operator would not keep it among the steps, `should` otherwise, being a step making no entry `must` even where the Done when requires every step to be done — or, for an entry naming no workstream, against the project — `must` where its absence does harm, `could` where it is an improvement only, `should` otherwise; `waits_on`, a list of the names of entries or changes that must be archived first; `waits_for`, present only where the entry waits on something that is not a name, the condition that can be checked — a person's answer, an access grant, an event — kept short, what is awaited and from whom, the reasons in the body; `waits_for_type`, present only beside `waits_for`, the kinds of wait it states, from `decision`, the operator's decision; `answer`, an answer from someone other than the operator; `access`, an access grant, a credential or a setting someone must enable; `release`, a release reaching an environment; and `event`, any other condition that can be checked; `design_with`, a list of the entries that share a design with this one; `workstream`, the workstream the entry is a step of or serves, by name, or `none`; `recorded_by`, the change that identified it by name, or a double-quoted text where no change did; and `re_checked`, the date it was last verified against the repository, as `YYYY-MM-DD`;
- the frontmatter's form: a name, a value from a stated set or a date is written bare; free text is double-quoted, with `"` and `\` escaped by a backslash; a list is written inline as `[a, b]`, and empty as `[]`; nothing is nested, and no value spans more than one line;
- the meaning of an absent key: an entry without `priority` is `normal`; without `need`, `should`; with `waits_for` and without `waits_for_type`, untyped; without `waits_on` or `design_with`, the empty list; without `workstream`, `none`;
- the rules on `priority`: that `high` needs evidence of harm happening now — an incident, a measurement, an observation; that a parked entry is not folded into another change before its condition holds; that a parked entry whose condition holds becomes `normal`, or `high` with evidence; and that a `high` entry whose evidence no longer holds becomes `normal`;
- the rule on `workstream`: that an entry recorded by a change in a workstream takes that workstream unless it serves another goal or that workstream's Not in scope leaves it out; that otherwise it takes the open workstream whose Goal it serves, found by reading the Goal and Not in scope of every open workstream; that `none` is written only after that read finds none, or on the operator's word; and that before `none` is written the other entries naming `none` are read for a goal they share with this one, a workstream being proposed for one that takes more than one change as `docs/workstreams/AGENTS.md` directs, and `none` written meanwhile;
- the shape of an entry's body: what the change is and why, written for a session that has not seen the work that found it, followed by one list giving the reasons the frontmatter's values need — **Kind**, why it is a fix or a change; **Need**, on a `must` or `could` entry only, why; **Priority**, on a `high` or parked entry only, the evidence or why it is parked; **Recorded by**, why it was not done there — and that further items a project's own rules add to that list are kept as written.

**Kind is `fix` only where the entry owes no specification delta, needs no decision from the operator, and is small enough to review in one sitting**; otherwise it is `change`. The size condition is the workflow's own: a fix is work too small to be a change, which skips `plan`, so an entry too large for one sitting is not one whatever it owes. The reason is stated because the label alone cannot be checked, and an entry's kind is the first thing a session picking work reads.

**Waits on replaces a list of changes that must land first, and holds only names.** An entry that should precede another says so from the waiting side: the later entry names it in `waits_on`. A constraint stated on both sides is two statements that drift, and the waiting side is the one the pick and the archive re-read read. **A wait on something that is not a name is `waits_for`, apart from the names**, because a name is an edge a reader can follow and resolve — archived or not — and a sentence is not: mixed into one field, every reader has to guess which words are names. An entry may wait on both.

**Need is apart from priority.** Priority says how urgent an entry is, need whether the goal it serves holds without it, and the two vary independently: a `could` may be urgent while an opportunity lasts, and a `must` may be parked until its precondition exists. It is measured against the Goal and not the Done when, because a Done when may require every step to be done, which would make every step `must`, and a `could` step is one the operator may remove and return to the backlog without failing the Goal. `must` and `could` are the operator's judgement, so each states its reason; there is no "won't", which is already a deletion ground.

**A condition states its kind of wait beside it.** Whose move a wait is — the operator's decision, someone else's answer or grant, or nobody's yet — is what a reader of the backlog acts on, and a sentence makes every reader parse it. The type is a list because one condition may hold two waits, and a key of its own because the condition's words stay free text, valid without it.

**Priority is `high` only with evidence of harm happening now**, and **`parked` only with a condition that can be checked**, under which the entry becomes worth taking. Both are stated so that a later reading can tell whether they still hold, which a bare label cannot show. There is no `low`: an entry not worth taking with no condition under which it would be is one the operator has decided will not be made, which is already a deletion ground. Parked is not a wait: a waiting entry cannot be taken, a parked one can and is deliberately deferred, and an entry may be both. The condition has a key of its own, `parked_until`, because it is what a later reading checks; the reason it was parked is prose, in the body.

**Workstream is not Design with.** Design with groups entries that share a design, a property of the work; Workstream places an entry in a goal's sequence of changes, a property of the plan. Two entries may share either without the other, so neither field stands in for the other. The default is the recording change's workstream because work a change identifies usually serves the goal that change serves, and an entry recorded without it is detached from the plan it belongs to. **The search is an obligation of the entry rule, not only of the `backlog` skill**, because a session writing an entry by hand owes the same, and `none` written unexamined leaves a fitting goal unserved.

**One entry is one file, and its values are frontmatter.** A backlog shared by every session of a project is edited by several at once, and one file makes their edits conflict where one file per entry keeps them apart. A value a program reads — to build a board, to resolve a wait, to group a workstream — has to be found where it is without reading prose, and the free-text fields of the single file drifted in spelling across projects (`nothing`, `none`, `nothing.`) until no reader could rely on them. **The form is a flat subset of YAML** so that any YAML reader reads it and a shell tool reads it with no parser installed, which this library's tooling requires. **Reasons stay prose in the body**, because they are read by a person deciding, not by a program, and a long quoted value is harder to write and to read than a sentence.

**An absent key has a stated meaning, and the empty values are `[]` and `none`.** The file states them so that an entry written with fewer keys needs no edit, and so that one spelling of absence holds wherever the value is read. `none` is also the word the status row and a proposal use for a change in no workstream.

Entry brevity is stated because the details it excludes are the ones that go stale first, and the session that takes the entry up redoes them anyway. A census worth keeping belongs in the change's own artifacts once the change is opened.

**This requirement owns the backlog's entry rules**; `session-workflow` owns only routing work to the directory and when it is re-read, and its fragment defers to the directory's `AGENTS.md` for these rules rather than restating them. `backlog-maintenance` performs operations over the directory and likewise reads these rules from that file. `backlog-migration` converts a single-file backlog into this shape.

A path is present where it exists of any type, including a symbolic link whether or not it resolves. A link counted as absent would be written through, to wherever it points.

The tool SHALL create no entry, and the block SHALL NOT number entries or mention entry numbers. An entry carrying a number invites citing and ordering by it; a name is the identifier that survives other entries being deleted.

The file is kept when there are no entries because the tool created it: deleting it would leave the next session to recreate the rules from no text at all, which is the variance this requirement removes, and would leave a directory version control does not keep.

#### Scenario: A project without a backlog receives the seeded file

- **WHEN** the tool runs in a target with neither `docs/backlog/` nor `docs/backlog.md`
- **THEN** `docs/backlog/AGENTS.md` is created holding the block with every statement listed above, `docs/backlog/CLAUDE.md` is created holding `@AGENTS.md`, no entry file is created, and the report states the backlog was created

#### Scenario: An existing backlog is preserved exactly

- **WHEN** the target already contains `docs/backlog/AGENTS.md` holding a backlog block
- **THEN** it and every file beside it are left byte-for-byte unchanged and the report states the backlog is already present

#### Scenario: The seeded file carries no numbering

- **WHEN** the seeded block is written
- **THEN** no heading in it begins with a number and no sentence in it refers to an entry's number

#### Scenario: The seeded entry shape carries the structured fields

- **WHEN** the seeded block is written
- **THEN** its entry shape names the keys `priority`, `parked_until`, `kind`, `need`, `waits_on`, `waits_for`, `waits_for_type`, `design_with`, `workstream`, `recorded_by` and `re_checked`, in that order, and does not name Depends on

#### Scenario: A fix is distinguished from a change by what it owes

- **WHEN** a session reads the seeded block to record an entry that owes a specification delta
- **THEN** the block's definition of `kind` leaves only `change` available to it, because `fix` is stated as owing no delta, needing no decision and fitting one review sitting

#### Scenario: Priority's values and default are stated

- **WHEN** the seeded block is written
- **THEN** its entry shape states `priority`'s three values `high`, `normal` and `parked`, that `high` needs evidence of harm happening now, that `parked` needs a condition in `parked_until` that can be checked, and that an entry without the key is `normal`

#### Scenario: The seeded file offers no low priority

- **WHEN** a session reads the seeded block to record an entry it judges not worth taking
- **THEN** the block offers no `low` value, so the entry is either parked with a condition or not recorded

#### Scenario: The seeded file states how an entry leaves parked and high

- **WHEN** a session reads the seeded block at the archive of a change that fulfilled a parked entry's condition, or removed a `high` entry's evidence
- **THEN** the block directs that entry to `normal`, or to `high` with evidence for the parked one, and names unparked entries among those the archive updates

#### Scenario: Workstream's default is stated

- **WHEN** the seeded block is written
- **THEN** its entry shape states that an entry recorded by a change in a workstream takes that workstream unless it serves another goal, and that an entry without the key is `none`

#### Scenario: The seeded entry's fields are a list

- **WHEN** the seeded block is written
- **THEN** its entry shape gives the values as frontmatter keys, one per line in the stated order, and the reasons as one Markdown list in the body, `- **Kind**: …`, `- **Priority**: …`, `- **Recorded by**: …`, with no blank line between them

#### Scenario: An absent value reads as its field

- **WHEN** the seeded block is written
- **THEN** its entry shape gives the empty `waits_on` and `design_with` as `[]` and the absent `workstream` as `none`, and states the meaning of each key's absence

#### Scenario: A single-file backlog is pointed to the migration tool

- **WHEN** the tool runs in a target with `docs/backlog.md` and no `docs/backlog/`
- **THEN** `docs/backlog.md` is unchanged, `docs/backlog/` is not created, and the report states the backlog is in the single-file shape and names `scripts/backlog-migrate`

#### Scenario: A missing backlog fragment blocks every run

- **WHEN** the tool runs where `rules/backlog.md` is absent from its copy, once in a target with no backlog and once in a target whose `docs/backlog/AGENTS.md` holds the block
- **THEN** both runs report `BLOCKED` and write nothing

#### Scenario: The rules are added beside existing entries

- **WHEN** the tool runs in a target whose `docs/backlog/` holds entry files and neither `AGENTS.md` nor `README.md`
- **THEN** `AGENTS.md` holding the block and `CLAUDE.md` holding `@AGENTS.md` are created, and every entry file is byte-for-byte unchanged

#### Scenario: Project text beside the block survives

- **WHEN** the tool runs in a target whose `docs/backlog/AGENTS.md` holds text of the project's own and no backlog block
- **THEN** the block is appended, and every line the file held before is unchanged

#### Scenario: A backlog path that is not a directory is not written through

- **WHEN** the tool runs in a target where `docs/backlog` is a symbolic link, or a regular file
- **THEN** nothing is written at or through that path, and the report states it is not a directory the tool writes into

#### Scenario: Waits on holds only names

- **WHEN** a session reads the seeded block to record an entry waiting on a person's answer and on a named change
- **THEN** the block directs the change's name into `waits_on` and the answer, as a double-quoted condition, into `waits_for`

#### Scenario: The frontmatter is flat

- **WHEN** the seeded block is written
- **THEN** its entry shape states that names, set values and dates are bare, free text is double-quoted with `"` and `\` escaped, lists are inline, nothing is nested, and no value spans lines

#### Scenario: The seeded block makes `none` the end of a search

- **WHEN** the seeded block is written
- **THEN** its entry shape states that the Goal and Not in scope of every open workstream are read, that the entry takes the one whose Goal it serves, and that `none` is written only after that read finds none or on the operator's word

#### Scenario: Need's values and default are stated

- **WHEN** the seeded block is written
- **THEN** its entry shape states `need`'s three values `must`, `should` and `could`, each measured against the Goal of the entry's workstream or, naming none, against the project, and that an entry without the key is `should`

#### Scenario: A condition's types are stated

- **WHEN** the seeded block is written
- **THEN** its entry shape states that `waits_for_type` is present only beside `waits_for`, and names its five values `decision`, `answer`, `access`, `release` and `event` with their meanings

#### Scenario: A condition without a type stays valid

- **WHEN** a session reads the seeded block for an entry carrying `waits_for` and no `waits_for_type`
- **THEN** the block reads the entry as untyped, not as malformed

#### Scenario: A step is not must for being a step

- **WHEN** a session reads the seeded block for a step of a workstream whose Done when requires every step to be done, and the Goal holds without that step
- **THEN** the block leaves `could` available to it, since being a step does not make an entry `must`

#### Scenario: The seeded block reads the none entries before writing none

- **WHEN** the seeded block is written
- **THEN** its rule on `workstream` states that the other entries naming `none` are read for a shared goal before `none` is written, that a workstream is proposed as the workstreams rules direct where they share one, and that `none` is written meanwhile
