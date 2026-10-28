---
kind: procedural-checklist
---

# Establishing a project's foundation

This is a one-time procedure for a new project, run once before normal development begins. It is not a standing rule and is never inlined into a project's conventions file — read it on demand, when establishing a foundation, not as an ongoing constraint.

## What must be settled

Nine decisions, falling into two groups by how they may be reached.

**Supplied — not derivable from anything available, and must come from the person establishing the project:**

- **Identity**: what the project is.
- **Problem**: what problem it solves.
- **Audience**: who or what it is intended for.
- **Scope**: its initial scope.
- **Non-goals**: what is deliberately out of scope. This is not the inverse of scope stated for form's sake — it is a first-class decision recording what was considered and rejected, not merely what was not mentioned. Its absence is what lets scope creep back in six weeks later; do not skip it because scope already sounds clear.

**Proposable — may be proposed with reasoning, for confirmation or rejection, once identity and scope are established:**

- **Technology**: language and framework.
- **Architecture**: the shape of the system.
- **Testing strategy**: how the project's behavior will be verified, including three items a later change's test author is dispatched with — the **test command**, the **test-path glob**, and the **shared test arrangement**: where the project's tests take builders, fixtures, fakes and stubs from, as a path, or the statement that the project has none. "None" is an answer; an empty item is a gap. A test author dispatched without the shared test arrangement declares every piece of arrangement locally, and the implementation step has nowhere named to promote it to. Answering "none" does not oblige foundation to create one.
- **Development tooling**: the project's quality layer, decided concern by concern — see *Development tooling, concern by concern* below. Which tool serves each concern is the project's choice; this checklist names the concern, never the tool.

## Development tooling, concern by concern

"Linting, formatting and whatever else" reads as answered once two concerns are settled, and the rest go undiscussed. So the decision is split into named concerns, each of which gets an answer — a choice, or "not applicable" with the reason:

- **Linting** — static checks on the code beyond what the compiler or interpreter enforces.
- **Formatting** — whether layout is mechanically fixed, and how.
- **Type checking** — static types and how strictly they are checked, where the language has them.
- **Build tooling** — how the project is built, packaged and run. The test runner is decided under Testing Strategy, not here.
- **Local hooks** — which checks run before a commit or push in a working copy.
- **Commit messages** — the convention commit messages follow, and whether anything checks it.
- **Pull requests** — what a pull request's title and description carry, whether the forge supplies a template for them, and whether anything checks it. Decided on its own, apart from the commit-message convention: a pull request spans several commits, often on different concerns.
- **Secrets** — how credentials and other secrets stay out of version control, and how a working copy gets them.
- **Dependency updates and audit** — how dependencies are kept current and checked for known vulnerabilities.
- **Continuous integration** — the gate every change must pass before it reaches the trunk, and which checks it runs.
- **Toolchain pinning** — how the language runtime and tool versions are fixed so every working copy and the gate run the same ones.
- **Branch protection** — what the forge requires before a change reaches the trunk.
- **Provisioning** — what a new working tree needs before its verification can be trusted, including how every tool that recurses the tree without reading the ignore file — test collection, a linter, a container build context — is kept out of the roots the workflow places working trees under (`.worktrees/`, and `.claude/worktrees/` by its Claude Code binding), whether or not the ignore file names them.

Three of these carry a position rather than an open choice. Each is what makes its concern a control rather than a convenience, so record it as stated:

- **Continuous integration is the authority, and fails rather than skips.** A step that cannot reach a dependency it requires fails the run. A skip a check declares for itself — a platform it does not apply to, an optional dependency — is a decision, not a gate that failed to run.
- **A local hook is not a gate.** A hook exists only in a working copy where someone installed it, so its silence is not a pass and no completion claim rests on it. Record hooks as a fast local mirror of checks the continuous-integration gate enforces — every check a change must pass that a hook runs is also a check of the gate. Where a hook stands down for some class of change — documentation only, for example — record what decides membership of that class too; a stand-down nobody can predict is a gate that silently varies.
- **Secrets are kept out of version control by the ignore file**, not by vigilance at commit time, so committing one takes an override rather than an oversight. Secret scanning, where chosen, is a second line, not a replacement.

**Branch protection is decided here and applied later.** Record the policy — which continuous-integration checks are required, whether changes reach the trunk only through pull requests, whether administrators are bound by it — and change no forge setting. Where a policy is decided, applying it is a task of the change that introduces continuous integration, performed once the required checks have reported at least once — a check that has never reported cannot be required — and confirmed by the operator first, since changing a forge's settings is outward-facing. Where protection is decided against, with its reason recorded, there is nothing to apply and no such task. Foundation is where this is decided because nothing earlier can decide it: initialization runs before a remote, a stack or any check exists, and is deterministic by design.

**Foundation builds one thing: the ignore entries.** Once the stack is known, extend the project's `.gitignore` with that stack's build and dependency exclusions and its secret-bearing paths. Initialization deliberately created a `.gitignore` with no stack assumption, because it could not know the language yet — this is the first point the language is known, and closing that gap here is what makes it closed rather than merely handed off.

**Everything else it decides has a named owner before foundation archives.** Foundation stays a decision-only change and writes no linter, formatter, hook, continuous-integration or dependency-update configuration. Decisions recorded with nobody to build them are how a project ends foundation with none of its quality layer in place. So, before archiving, open a successor change the way the workflow opens a second change surfacing — a branch of its own carrying a committed `handoff.md`, with no proposal. A suggested name is `establish-quality-gate`; any name will do. Its handoff names:

- each decided item it must build that the project does not already have;
- the test runner the testing strategy chose, if the project does not already have one;
- the branch-protection application task, only where a policy was decided;
- `AGENTS.md`'s `## Development Tooling` and `## Testing Strategy` sections as where the decisions are recorded — not this change's `design.md`, which moves into the archive exactly when the successor is taken up.

Name the successor under the `Delivery` item. Where every decided item already exists in the project, `Delivery` says so and no successor is opened.

The successor is the owner of the tooling, not a further deliverable of foundation, and it does not inherit foundation's exemption from test authoring: it is the first change for which the test command and test-path glob are decided, and test authoring applies to it as to any later change.

## How to cover them

Coverage is the obligation; interrogation order is not. Do not fire these nine items as a sequence of questions — that produces worse discovery than a conversation that reaches the same coverage by a natural route. Identity, problem, audience, scope, and non-goals must be elicited, since nothing available makes them derivable. The proposable four are faster to propose, with reasoning, than to ask about; propose and let the person confirm or redirect. The development-tooling concerns are coverage, not a question sequence: once the stack is known, propose them as one coherent set and let the person confirm or redirect in bulk.

## Where the answers go

The foundation is a normal change, authored through the project's existing change-authoring mechanism — this procedure does not implement a competing way to produce a proposal, design, or task list. Its own contribution is coverage, classification, and knowing when there is enough to write.

Write each decision into the change's `design.md` as it settles, rather than holding it in conversation until a final write. A foundation conversation can span sessions, and a decision that exists only in conversation is invisible to whoever resumes it.

`design.md` carries a fixed set of named sections, one per decision. Three sections absorb several decisions and carry a named item per decision, so an unanswered one stays individually visible: `Identity` groups problem, audience and identity itself, `Testing Strategy` carries the test command, the test-path glob and the shared test arrangement, and `Development Tooling` carries one item per concern above, plus `Ignore entries` and `Delivery`:

```
## Identity
   - What it is
   - Problem it solves
   - Intended audience
## Scope
## Non-Goals
## Technology
## Architecture
## Testing Strategy
   - Test command
   - Test-path glob
   - Shared test arrangement
## Development Tooling
   - Linting
   - Formatting
   - Type checking
   - Build tooling
   - Local hooks
   - Commit messages
   - Pull requests
   - Secrets
   - Dependency updates and audit
   - Continuous integration
   - Toolchain pinning
   - Branch protection
   - Provisioning
   - Ignore entries
   - Delivery
```

An unfilled section, or an unfilled item within one, is a visible gap — that is what makes coverage checkable in the artifact rather than only inside the conversation that produced it. An item may be answered "not applicable" with its reason — type checking in a language without it, branch protection decided against for a single-maintainer repository. A stated reason is an answer; an empty item is a gap.

## Decisions also reach README.md and AGENTS.md

`design.md` is the canonical, checkable record, but it is archived with the change once foundation completes — discoverable only by someone who goes looking inside OpenSpec's archive, not what a human landing on the project or a fresh agent session reads by default. As each decision settles, write it a second time into whichever of the project's `README.md` or `AGENTS.md` the decision belongs in, in addition to — never instead of — the `design.md` write.

The split is not by audience. Do not route a decision to `AGENTS.md` because an agent might someday want it, or to `README.md` because a human might read it. Route it by whether a future agent turn needs the fact without being told to go look for it: only `AGENTS.md` reaches an agent that way, since this workflow's own bootstrap step and this fragment's sibling change both established that Claude Code auto-loads `AGENTS.md` (via a `CLAUDE.md` import) every session, while `README.md` is never auto-loaded at all.

Under that test:

- **`README.md`** gets identity, problem, audience, scope, non-goals, technology, and architecture — decisions that inform without needing to shape a future agent turn automatically. Create the file if it is absent; otherwise append a section. Delimit it with `<!-- ai-toolkit:project-foundation -->` / `<!-- /ai-toolkit:project-foundation -->`, unversioned — this content is never regenerated from a toolkit fragment, so there is nothing to stamp a version against, and a human is free to edit it afterward. Use these headings, in order: `## What it is`, `## Problem`, `## Audience`, `## Scope`, `## Non-Goals`, `## Technology`, `## Architecture`. As each decision settles, rewrite the content between the markers rather than duplicating it.
- **`AGENTS.md`** gets testing strategy and development tooling only — the two decisions a later change's test-authoring step actually depends on as inputs (the test command, the test-path glob, the shared test arrangement or that there is none), and which reach an agent automatically only through this file. Append a second, separate section — outside the existing `<!-- ai-toolkit:development-workflow vN -->` block if one is present, never inside it, since that block is regenerated wholesale on update and would silently destroy project-owned content living inside it. Delimit it the same way, unversioned, with headings `## Testing Strategy` and `## Development Tooling`, placed after the workflow block where one exists. `AGENTS.md` is presupposed to already exist — this workflow's own initialization step always creates it before foundation can run — so there is no create-if-absent case to handle here, unlike `README.md`.

## The foundation change is exempt from test authoring

The workflow's rule that tests be derived from a change's specification before implementation does not apply to the foundation change. Test authoring needs the project's test command and test-path locations as inputs — and those are outputs of foundation, not inputs to it. Foundation is the one change in a project's life where deriving tests before implementation is structurally impossible, since the thing that would produce the inputs is the change itself.

State this exemption explicitly when foundation reaches the point where test authoring would normally run, rather than leaving it to be discovered by an agent stalling on an undefined test command, or invented around by writing a placeholder suite that asserts nothing. The exemption applies to this one change only — the very next change after foundation has a defined test command and test-path glob, and test authoring applies to it normally.

## Foundation is complete when archived, and stays complete

Foundation is done when every section above is filled, the successor named under `Delivery` has been opened where one is needed, and the change is archived. Archival is the signal that the project has moved from establishment into normal development — nothing else needs to track that transition.

Foundation is a historical record, not an invariant to maintain. Once archived, it stays complete regardless of what happens afterward. A later architectural change, a stack swap, a testing-strategy revision — each is simply a new change going through the normal workflow. None of them invalidates the foundation or requires it to be revisited or updated.
