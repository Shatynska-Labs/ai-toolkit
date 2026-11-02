## Context

`project-bootstrap` owns the entry and workstream rules, written from `rules/backlog.md` and `rules/workstreams.md` as managed blocks. `session-workflow` owns when a session is sent to them, and its fragment names no entry field. `backlog-maintenance` owns the skill, which states no rule and is how the rules are carried out. So each new obligation goes into a rule first, and the skill carries it out. `handoff.md` holds the evidence and nine proposals. This design takes them with the departures in decision 7.

## Goals / Non-Goals

**Goals:**
- `none` is written only after the open workstreams' Goals were read, by a session with or without the skill.
- An entry naming an open workstream is a step, or is shown as not yet one, no later than the archive of a change in it.
- "A step names it" has one meaning.

**Non-Goals:**
- A deterministic check that fails on an unplaced entry. The handoff offers it as a project's own choice, and a rule mentioning an optional check obliges nobody.
- Defining how to read a Goal. `review-a-workstream-against-its-goal` reads Goals too, and neither change defines it: an entry serves a Goal when finishing it moves the workstream towards what the Goal says.
- Moving existing entries in a consumer. The next sweep finds them.
- Changing where the value is kept. The entry still states its workstream, and a workstream file still holds no progress.

## Decisions

**1. The `workstream` key in `rules/backlog.md`.** The key's second sentence becomes:

> An entry recorded by a change in a workstream takes that workstream unless it serves another goal or that workstream's Not in scope leaves it out. Otherwise it takes the open workstream whose Goal it serves, found by reading the Goal and Not in scope of every open workstream; `none` is written only after that read finds none, or on the operator's word.

The operator's word stays because what the plan is for is theirs to judge; a session's own statement is no exception, or `none` could again be written unexamined. The phrase "unless it serves another goal" stays, which `backlog-dir-seeded-workstream-default.sh` pins. The handoff's wording named only the Goal, but commerce-ops' first case was decided by Not in scope, so both are read.

**2. The placement paragraph in `rules/workstreams.md`.** The paragraph opening "A change or a backlog entry may name" becomes:

> A change or a backlog entry may name the workstream it serves before any step names it. Place an entry among the steps when it is recorded, or say that it is left for the archive and why. Place each such change or entry among the steps, or detach it, at the next edit of the workstream other than one placing a recorded entry, and at the latest at the archive of a change in it. Detaching re-points it to another open workstream whose Goal it serves and whose Not in scope does not leave it out, and clears it to `none` only where there is none. A step names a change or an entry only by its own name, the backticked name a numbered step begins with; a mention in a step's description, in Context or in Decisions places nothing.

Placing at recording is not absolute, because the operator may not be there to give the order. The reason said keeps the deferral visible. "Say" binds a session writing by hand as well, since it says it to the operator.

A placement at recording is itself an edit, so without the exemption it would make every other unplaced entry due then, turning a one-entry operation into a planning session and undoing a deferral already said. Dropping "next edit" for entries would weaken a rule projects hold, so only that one edit is exempted.

An entry re-pointed to another open workstream arrives unplaced there. The same paragraph then governs it: at that workstream's next edit, and at the latest at the archive of a change in it. A sweep does not edit a second workstream's steps.

The archive paragraph of `rules/workstreams.md` takes the same definition, because it too writes `none`. "it is first recorded as a backlog entry naming no workstream if it is not yet in flight" becomes "it is first recorded as a backlog entry detached from it if it is not yet in flight", and "Then re-point or clear every backlog entry still naming it." becomes "Then re-point or clear every backlog entry still naming it, by detaching it." `workstreams-seeded-statements.sh` pins "backlog entry naming no workstream", so that assertion goes obsolete and the test plan lists it.

**3. Record.** Skill step 6 is rewritten and a new closing step places the entry:

> 6. **Workstream.** The default is the open workstream the change you are in serves, as its proposal or a workstream's steps name it. Read the Goal and Not in scope of every open workstream, and keep or replace that default as the README's `workstream` key directs, asking the operator where more than one Goal is served. What the operator states the entry serves wins over this reading. Write only a name an open workstream carries, or the README's absent value, `none` in the seeded README. Say in your answer which workstream you chose for each entry and why. Where the workstreams README exists, the name check in step 2 also covers workstream names, open and archived.

The selection itself stays in the README, so the skill does not restate it.

> 10. **Place.** Where the entry names an open workstream, add it to that workstream's steps in the same edit, as the workstreams README directs, asking the operator where in the order. Where you do not, say that it is left for the archive and why.

The operation's opening sentence gains "the workstream file whose steps take it is the one other file you may edit". That is compatible with *Record writes one file*: an entry edit is still one file.

**4. Sweep.** Step 2's list gains one group, covering the handoff's proposals 2 and 6 together:

> and, where the change advanced an open workstream its archive does not archive, the entries the **workstreams** operation's *Unplaced* read finds in it, made over the change's working tree as well as the trunk so that the entries this change recorded are among them, each to be placed among the steps, the order asked of the operator, or detached as `docs/workstreams/AGENTS.md` directs, by the same read of the open workstreams' Goals **record** makes.

The working tree matters because *Unplaced* reads the fresh trunk, and an entry found on staging may sit only on the branch at the archive. The group for an archived workstream changes in the same way, keeping its words: "those naming that workstream, to be detached as `docs/workstreams/AGENTS.md` directs: re-pointed by the same read, or set to the README's absent value only where it finds none". `backlog-skill-sweep-workstream.sh` and `backlog-skill-sweep-absent-value.sh` pin those words. Sweep's opening sentence and step 4 gain that the workstream's steps are the one edit it makes outside the entry files, in the same commit.

One group suffices because an entry outside its workstream's scope has no business being a step, so it is unplaced in the cases seen. A placed entry was judged when it was placed. The accepted limit is a step placed by hand outside scope, or a Not in scope revised later: sweep does not re-judge steps, and revising a workstream is when that is looked at. The group reuses *Unplaced*, so there is no second definition, and *Unplaced* gains "as the README states what names a step" where it says "no step names them". The skill's other uses of "no step names" stay. The rule defines it; the skill does not restate it.

**5. The workflow fragments.** In both files:

- At **archive**, "place the entries attached to it" becomes "place the entries that name it and that no step names". The handoff's text said "whose `workstream` names it", which `session-workflow` forbids: the fragment names no entry field. A plain name works just as the re-read's existing wording does.
- After the two bullets of *A second change surfacing*: "_Claude Code binding:_ record an entry with `ai-toolkit:backlog`'s **record**."
- After the **archive** paragraph: "_Claude Code binding:_ carry out the entries' part of this re-read with `ai-toolkit:backlog`'s **sweep**."

Each binding sits where its act is stated, as the fragments' other bindings do, rather than one line carrying both. The two lines are identical across the files, so `workflow-fragments-differ-only-in-ship.sh` holds outside `ship`, and the archive line is the same inside it.

**6. The skill's description.** It measures 1,062 characters, over `create-skill`'s limit of 1,024, so adding phrases alone would worsen a standing defect. It becomes:

> This skill should be used when the user wants to work on a project's backlog in docs/backlog/ or its docs/workstreams/ — "add this to the backlog", "write up these follow-ups as backlog entries", "record the follow-ups found on staging", "where does this entry belong", "what can I pick up from the backlog", "close the x backlog entry", "sweep the backlog for the change I just archived", "audit the backlog", "where does the x workstream stand", "what's in flight". It performs six operations: record, pick, close, sweep (the archive re-read), audit (parallel read-only agents, applied only on the operator's word) and workstreams (each open workstream's steps and status, read from the repository). It reads entry and workstream rules from each directory's AGENTS.md. Not for writing them (project-init), nor for converting a single-file docs/backlog.md (scripts/backlog-migrate), nor for opening, proposing or implementing the change an entry names (openspec-new-change, openspec-propose, openspec-apply-change).

It measures 1,016 characters. To make room it drops the phrases "record this as a backlog entry" and "is the backlog still accurate", the near-duplicates of "add this to the backlog" and "audit the backlog", the words "in the project it is invoked in" and sweep's ", by name and by what the change's merged pull requests touched", which the body states, and shortens "steps and their status" to "steps and status". A positive fixture for follow-ups joins the trigger fixtures, and `create-skill`'s trigger check is run after the edit.

**7. Departures from the handoff.**

- Proposal 3's search reaches the archive paragraph too, which the handoff did not name (decision 2).
- Proposal 2 says an entry "falls outside that workstream's *Not in scope*". The meaning is the reverse, that *Not in scope* leaves it out, and the specs and rules say so.
- Proposals 2 and 6 become one group (decision 4).
- Proposal 9's field name is dropped (decision 5), and its optional check is a non-goal.
- Proposal 8 is stated in the rule only, since the skill restates no rule.
- The plugin version is added to the assets edited: `AGENTS.md` has required it of a shipped path since `raise-the-plugin-version-on-release`.

**8. Versions.** All four fragments rise by a minor, since each changes an obligation and asks no edit by hand. A project with unplaced entries needs no step: the next sweep presents them. `rules/changelog` takes one record per fragment, none with an `ask`. `development-workflow-direct`'s record stands under its own name, and `alternative_since` stays `2.0.0` on `rules/development-workflow.md`, since the choice between the two did not move. The plugin rises to `2.1.0`: the largest fragment rise is a minor.

**9. This repository follows.** Its backlog and workstreams blocks are brought current by `scripts/project-update`, not by hand. `complete-the-workstream-loop` takes this change as a step after `observe-what-finishes-a-workstream`, in the plan commit.

**10. Tests.** The rule and fragment statements are static scans, as `workstreams-seeded-statements.sh` and `backlog-skill-record-absent-value.sh` are. Whether a session actually reads the Goals is conduct, which a scan cannot hold, and the test plan says so. The phrases those cases pin are kept, except the one decision 2 names. `manifest-alternative-and-versions.sh` pins the workflow fragments' exact versions, on the shipped files and in its mutants, so that assertion goes obsolete too, and the test plan lists both.

## Risks / Trade-offs

- [Record reads every open workstream at each entry] → They are few and short, and the read is what the operator was doing by hand.
- [A judgement replaces a default, so two sessions may place one entry differently] → The answer states the choice and why, the operator sees it, and more than one served Goal goes to the operator.
- [Placing at recording adds steps to a workstream file more often] → Edits stay tied to a plan change, which the rules already allow, and the deferral remains for a session without the operator.
- [`backlog-maintenance` and the rule both speak of reading Goals] → The rule states the obligation and the skill the procedure, the split that requirement already draws.

## Migration Plan

Merging reaches installed copies by `/plugin update`. `scripts/project-update` then replaces each unedited block and prints the changed lines. Rolling back is reverting the pull request and the next plugin rise.
