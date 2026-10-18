## Context

`handoff.md` carries the evidence and six proposed sections. The operator split them: sections 2, 3, 5 and 6 land here, with the audit included. Section 1, the fold-in rule with its reviewer exemption, goes to the backlog entry `fold-small-work-in`. Section 4 goes there too, because taking `fix` entries during `build:applying` is fold-in work and has no meaning without section 1.

Three facts constrain the shape:

- `session-workflow` (*A rule states an action…*) requires that any separately published document carry reasoning only, and that the fragment remain sufficient on its own. That rule is why `add-development-workflow-skill` was dropped. The handoff's "`development-workflow.md` points to the skill rather than restating" is therefore not available: the archive re-read is an obligation and goes in the fragment.
- `project-bootstrap` owns the entry rules, which the seeded file states. `session-workflow` owns routing and forbids the fragment from restating those rules.
- `project-init` writes `docs/backlog.md` only where it is absent. Every backlog that exists today keeps its older shape.

## Goals / Non-Goals

**Goals:** entries whose status is readable from fields; a re-read at every archive; one skill that performs record/pick/close/sweep/audit without restating anyone's rules.

**Non-Goals:**
- Folding work in, and any change to `agents/change-code-reviewer.md` (that is `fold-small-work-in`).
- Rewriting any existing backlog, this repository's included. This repository's backlog keeps its own preamble ("Argued in", ordering by position) until someone edits it.
- A format check of `docs/backlog.md` inside a consuming project. In commerce-ops the file is inert, and a test reading it would end that exemption.
- Commerce-ops' "entry's number is an identifier" sentence. It sits inside commerce-ops' generated block from v4 and goes when that project refreshes its block. Nothing here reaches it.

## Decisions

**1. Three owners, one statement each.** The seeded file states how an entry is shaped and updated. The fragment states *that* the backlog is re-read at archive and which entries to look for. The skill states *how to perform* each operation and reads the other two. The alternative, putting the shape in the skill and having the file point there, fails twice: the file would name a library asset that a project which took the rules by `@` import may not have installed, and `project-bootstrap` would lose the rules it owns.

**2. The seeded text:**

````markdown
# Backlog

Changes this project has identified and not yet archived. Each entry is a change recorded here instead of being folded into the change that found it, or opened on a branch of its own.

An entry's heading is the change's name in kebab-case — the name its branch and change directory are expected to take, though the session that opens the change may rename it if the work turns out different. Refer to an entry only by that name.

The order of entries carries no meaning. What an entry waits on, and which entries share a design with it, it states in its own fields.

Keep an entry short: what is needed and why, naming files, specifications and changes as pointers. Leave out line numbers, census tables and step-by-step plans; they go stale first, and the session that takes the entry up redoes them.

Delete an entry when its change is archived, when the operator takes it as a fix rather than a change, when a change makes it obsolete, or when the operator decides the change will not be made. When a change is archived, also update the entries it unblocked or made stale, and set their **Re-checked** date. Keep this file when it has no entries.

An entry takes this shape:

```
## `change-name`

What the change is and why it is needed, written for a session that has not seen the work that found it.

**Kind**: `fix` or `change`, and why. A fix owes no specification delta and needs no decision from the operator; anything else is a change, and says which delta it owes or which decision it needs.

**Waits on**: `nothing`, or something that can be checked: a change by name, a person's answer, an event.

**Design with**: the entries that share a design with this one, by name, or `nothing`.

**Recorded by**: the change that identified it, and why it was not done there.

**Re-checked**: the date the entry was last verified against the repository.
```
````

The spec fixes the statements and not the wording, as `seed-the-backlog` did. The existing seeded-content test asserts each statement by a stable phrase, and its `Depends on` assertion goes obsolete.

**3. The fragment's addition** is one sentence appended to **archive**: "Before opening that pull request, re-read `docs/backlog.md` for the entries this change completed, made obsolete, unblocked or made stale, and update each as the file directs, in the commit that carries the record." It names no field, so a later change to the shape needs no fragment version. Version 6 → 7.

**4. The skill's shape.** `SKILL.md` holds the five operations. `references/audit.md` holds the agent brief (inputs, the sources to check with archived changes and merged PRs named explicitly, the verdict vocabulary, the return format) and the merged report's sections, and is loaded only when an audit runs. The audit brief is not its own library agent. Only this skill dispatches it. An agent would need the cold-run and trigger machinery of `create-agent` for a prompt with one caller, so it can be promoted if a second caller appears. The skill dispatches the general-purpose agent type, with the brief as the prompt and the instruction to write nothing.

Range size: about 25 entries per agent, so commerce-ops' 92 split into four, as in the audit that motivated this. A backlog of 25 or fewer runs as one agent. The skill keeps no fan-out of its own below that size.

**5. Name, tags, triggers** (create-skill checkpoint 1 inputs, confirmed again at apply time):
- name `backlog`: free under `skills/`.
- tags `[project-lifecycle]`: existing vocabulary, shared with `project-init` and `project-foundation`. `openspec` is not added: the backlog sits outside OpenSpec, and the audit only reads its archive.
- positive trigger: "add this to the backlog", "what can I pick up from the backlog", "audit the backlog", "clean up docs/backlog.md". Negative: "open a change for the `x` backlog entry" → `openspec-new-change`/`openspec-propose`; "set up a new project" → `project-init`.

**6. Sweep finds by diff as well as by name.** It reads `git diff --name-only` of the archived change against the trunk point it branched from and matches the paths against the pointers in each entry. The brevity rule is what makes this workable: entries name files and specifications as pointers.

**7. Older shapes.** Where a field is missing, the skill reports the entry as `unclassified` and invents no value. Migrating an entry is offered and done only on the operator's word. This keeps the skill useful on every existing backlog without making `project-init`'s "never overwritten" untrue by proxy.

## Risks / Trade-offs

- [Audit agents are read-only by instruction only; the general-purpose type can write] → run the audit on a committed tree. A stray write then shows in `git status` and is undone with `git restore`, as the fragment's review rule already relies on.
- [The archive re-read adds work to every archive] → it is a search over one file. The audit found about half its problems were exactly this gap.
- [Adding `backlog` invalidates competing trigger fixtures] → re-run `project-init`'s and record `backlog`'s own in this change.
- [`fix` entries now exist with no rule that takes them along the way] → accepted until `fold-small-work-in`. Meanwhile pick lists them separately for the operator.

## Migration Plan

Adopting projects see version skew (6 → 7) and refresh their block as usual. Existing backlogs are migrated, if at all, by the skill on the operator's word.
