## Context

`project-bootstrap` owns the entry and workstream rules, written from `rules/backlog.md` and `rules/workstreams.md` as managed blocks. `session-workflow` owns when a session is sent to them; its **draft** step already says "propose opening one, as that directory's `AGENTS.md` directs", and that directory's `AGENTS.md` says only that the operator decides. `backlog-maintenance` owns the skill, which carries the rules out and restates none of them. So each obligation goes into a rule, and the skill carries it out. `handoff.md` holds the evidence and four proposals; this design takes them with the departures in decision 7.

## Goals / Non-Goals

**Goals:**
- An entry is written `none` only after the other `none` entries were read for a goal it shares with them, by a session with or without the skill.
- A shared goal that takes more than one change reaches the operator as a proposed workstream, at recording, at detaching and at audit.
- Detaching ends in a value or a deletion, never in a deferral.

**Non-Goals:**
- Opening a workstream without the operator. The session proposes; the operator decides or delegates.
- Defining how to tell that entries share a goal. As in `match-backlog-entries-to-a-workstream`, it is a judgement read from the entries: finishing them together would make one statement of what is true hold.
- Moving entries already under `none` in a consumer. The next record, detach or audit meets them.
- A deterministic check. Whether two entries share a goal is not a property a scan can read.

## Decisions

**1. The opening paragraph of `rules/workstreams.md`.** It becomes:

> Open a workstream when the operator decides a goal needs more than one change. A session that finds such a goal that no open workstream holds, shared by changes it proposes or by backlog entries naming `none`, proposes opening one to the operator, naming those changes and entries and a draft Goal, and opens none unasked; a goal one change meets is not proposed. Commit it with the plan of the first change that advances it, or as work too small to be a change.

The first sentence is kept verbatim, which `workstreams-seeded-statements.sh` and the spec pin, so opening stays the operator's. The proposal names the changes as well as the entries because the workflow's **draft** sentence ("propose opening one, as that directory's `AGENTS.md` directs") points here: handoff proposal 4 asked for the obligation to be stated once, and stating it here makes the existing pointer carry it. **draft** keeps its own trigger, a change that is one of several a goal needs, including changes not yet proposed; this paragraph gives the form the proposal takes, which applies to both triggers. "A goal one change meets is not proposed" keeps `none` legitimate: no one-entry workstream to avoid it.

**2. The detaching sentence of `rules/workstreams.md`.** After "and clears it to `none` only where there is none." the placement paragraph gains:

> Before clearing one, read it together with the entries already naming `none`, and with the others detached in the same edit, for a goal they share, proposing a workstream for it as above. Each detached entry is re-pointed, cleared after that read, or deleted on a ground the backlog's rules give; a note deferring the read does not detach it.

The archive and abandon paragraphs already deal with entries "by detaching", so both are reached without editing them. An abandonment detaching many entries at once is when they are likeliest to share a goal, which is why the read covers the batch. Deletion is named because the commerce-ops abandonment made some entries obsolete, and the backlog's grounds already allow it; the rule states no new ground.

**3. The `workstream` key in `rules/backlog.md`.** After "`none` is written only after that read finds none, or on the operator's word." it gains:

> Before `none` is written, the other entries naming `none` are read for a goal they share with this one; where they share one that takes more than one change, a workstream is proposed for it as `docs/workstreams/AGENTS.md` directs, and `none` is written meanwhile.

It applies on the operator's word too: the operator ruled out the open workstreams, not one not yet proposed. "`none` is written meanwhile" keeps the proposal from blocking the entry.

**4. Record.** Step 7 (**Workstream**) gains, after "Say in your answer which workstream you chose for each entry and why.":

> Before writing the absent value, read the bodies of the other entries carrying it, not the repository, for a goal they share with this entry. Where they share one, propose opening a workstream for it as the workstreams README directs, naming the entries and a draft Goal, and write the absent value meanwhile. Say in your answer what you proposed, or that no shared goal was found.

Reading bodies only keeps the read cheap and bounded, as the handoff requires. "Never open it unasked" is the rule's, so the skill does not restate it.

**5. Sweep.** Step 2's group for an archived workstream, "re-pointed by the same read, or set to the README's absent value only where it finds none", gains: ", those to be set to it read together with the entries already carrying it for a shared goal, as **record** reads them, and with each other where several are detached at once". The batch is named in the skill as well as the rule because the commerce-ops abandonment is the case where a goal is shared only within the detached batch. The words `backlog-skill-sweep-workstream.sh` and `backlog-skill-sweep-absent-value.sh` pin stay. Unplaced entries sweep detaches from an open workstream go through the same read, since it is record's read they already take.

**6. Audit.** Step 4 gains: "Then read every entry carrying the README's absent value together, across ranges, for goals they share, and add what you find to the report." `references/audit.md`'s merged report gains, after **Groups**:

> 7. **Shared goals**: groups of entries carrying the README's absent value (`none` in the seeded README) that share a goal taking more than one change, each with a draft Goal and the entries it would hold, proposed as workstreams to open. The skill reads them itself, from the entries' bodies, because no agent sees two ranges.

**Fixes** and **Unverified** become 8 and 9. Step 5 gains: "A shared goal the operator approves is opened as the workstreams README and the workflow direct, its entries re-pointed to it", and the approved edit spans the entry files and the workstream files it opens. The agents' brief is unchanged.

**7. Departures from the handoff.**

- Proposal 4 is answered without a fragment edit: the **draft** sentence already defers to `docs/workstreams/AGENTS.md`, so the obligation lands there (decision 1). `session-workflow` is unchanged.
- Proposal 2 names "proposed for deletion". The rule says "deleted on a ground the backlog's rules give", since whether the operator's abandonment is that ground is already the backlog's to say.
- The changes a session proposes join the entries in the rule, since the pointer from **draft** now reaches it.

**8. Versions.** `backlog` rises to `1.3.0` and `workstreams` to `2.2.0`: each changes an obligation and asks no edit by hand. `rules/changelog` takes one record each, with no `ask`. The plugin rises from `2.3.0` to `2.4.0`.

**9. This repository follows.** Its backlog and workstreams blocks are brought current by `scripts/project-update`. `complete-the-workstream-loop` takes this change as its fourth step, after `match-backlog-entries-to-a-workstream`, in the plan commit, which a workstream review precedes.

**10. Tests.** The rule and skill statements are static scans, as the existing `backlog-skill-*` and `workstreams-seeded-statements.sh` cases are. Whether a session actually reads the entries and judges a shared goal is conduct, which no scan holds.

## Risks / Trade-offs

- [Record reads every `none` entry at each entry written `none`] → Bodies only, and the read the operator otherwise made by hand twice.
- [A judgement of a shared goal may differ between sessions] → It is only a proposal, the operator decides, and the answer names the entries and the draft Goal.
- [Proposals repeat on every record while the operator declines one] → Accepted: a declined proposal leaves the goal unheld, which is the situation the operator should keep seeing. A project wanting silence records the decision in its own rules.

## Migration Plan

Merging reaches installed copies by `/plugin update`. `scripts/project-update` then replaces each unedited block and prints the changelog lines. Rolling back is reverting the pull request and the next plugin rise.
