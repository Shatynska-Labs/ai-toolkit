## Context

`rules/project-foundation.md` is a `procedural-checklist` fragment — read on demand, never inlined, unversioned. `skills/project-foundation/SKILL.md` wraps it and states that the fragment carries the checklist and reasoning while the skill carries the conversation; the skill does not restate the nine decisions. `project-foundation`'s spec already fixes a `design.md` section layout and requires a section absorbing several decisions to carry a named item per decision (`Identity` does). `Development Tooling` is a single section today.

The workflow fragment already has a mechanism for work identified inside one change that belongs in another: a branch of its own with a committed `handoff.md` and no proposal. It also already obliges a project to name its provisioning steps.

`docs/backlog.md`'s `move-setup-gates-to-project-setup` holds three setup obligations without a home — CI fails rather than skips, a hook is not an authority, secrets are kept out by the ignore file — and asks for `project-foundation`, `scripts/project-init`, or both. `session-workflow` forbids them in the fragment. The seeded ignore file already excludes `.env` and `.env.*`.

`basis` (after its `scaffold-workspace` change) is the motivating case: foundation ran to completion there and left no quality tooling, a separate change built it afterwards, the forge's branch-protection change was refused in auto mode and applied by hand, and its hooks stand down for documentation-only changes. `basis` is not available locally, so these facts are as reported by its operator; no requirement here depends on their exact detail.

## Goals / Non-Goals

**Goals:**

- Make the quality layer individually visible in foundation's artifact, so an undiscussed concern shows as a gap.
- Give every decided tooling item an owner that survives foundation's archival.
- Give the three backlog obligations a home and close that entry.

**Non-Goals:**

- Any change to `scripts/project-init` or `project-bootstrap`, including detecting a remote or reporting forge setup as outstanding.
- Shipping templates or tool-specific configuration for any stack.
- A skill or agent that builds the quality tooling. The successor change is an ordinary change; no library asset is added to drive it.
- Revisiting projects whose foundation is already archived.

## Decisions

**1. Coverage by named items under `Development Tooling`, not a second section.** The spec's existing rule — a section absorbing several decisions carries a named item each — is exactly the mechanism needed, and `Identity` is the precedent. A new top-level `Quality` section would split one decision (development tooling) across two sections and make the README/AGENTS routing ambiguous. Items, in order: Linting, Formatting, Type checking, Build tooling, Local hooks, Commit messages, Secrets, Dependency updates and audit, Continuous integration, Toolchain pinning, Branch protection, Provisioning, Ignore entries, Delivery.

**2. Every item is required to be answered; "not applicable, because…" is an answer.** The open question was which items are mandatory to discuss and which optional to record. Splitting them would reintroduce the original gap — the optional ones are where a conversation silently stops. Requiring an answer for every item while accepting a reasoned "not applicable" keeps coverage checkable without forcing tooling a project does not need (type checking in a language without it; branch protection decided against for a single-maintainer repository). "No forge" is deliberately not the example: the inlined workflow fragment assumes every project has a remote, pull requests and continuous integration, so a missing forge is at most a deferral, not a reason. Alternative rejected: a mandatory core plus an optional tail, which is the current situation with a longer list.

**3. Items remain proposable.** Nothing in the quality layer is identity: all of it can be derived from the stack and the architecture. The skill proposes a coherent set with reasoning once technology and architecture settle, in one turn rather than a question per item. "Converse, don't interrogate" is unchanged and gets one sentence in the skill saying the items are coverage, not a question sequence.

**4. Three positions are fixed, not options.** CI is the authority and fails rather than skips; a hook is not a gate; secrets are excluded by the ignore file. Each is what makes its item a control. They are stated in the fragment as positions a project records, not choices it makes. The secrets position folds into the existing ignore-file deliverable — the stack's secret-bearing paths join its build and dependency exclusions — rather than adding a second deliverable. This absorbs `move-setup-gates-to-project-setup`'s three open items; its fourth (test command and glob) is already owned by foundation. The entry is deleted at archive.

**5. Hook stand-down names its classifier.** `basis` stands documentation-only changes down in hooks. That is a reasonable choice and the checklist does not forbid it, but a stand-down whose membership nobody can predict varies silently, so where one is recorded, what decides membership is recorded with it.

**6. Delivery by successor change (option a).** Foundation ends by opening a successor change using the workflow's existing "second change surfacing" mechanism — branch plus committed `handoff.md` — and names it under `Delivery`. Rejected: (b) a backlog entry, which records the work without opening it and is easier to leave indefinitely — the `basis` failure was precisely decisions with no one building them; (c) foundation builds the tooling, which breaks its decision-only shape and its test-authoring exemption, since building a test runner is exactly what makes tests derivable. The fragment suggests a default successor name (`establish-quality-gate`) and leaves the project free to choose another; the spec fixes only that one is named.

The handoff points at `AGENTS.md`'s `## Development Tooling` and `## Testing Strategy` sections, not at the foundation's `design.md`. The successor session starts once foundation is archived — exactly when `design.md` moves into the archive directory — while the `AGENTS.md` sections are where the existing surfacing requirement already puts these decisions, at a path that does not move.

The successor also owns installing the test runner the testing strategy decides, where the project lacks one. The runner belongs to `Testing Strategy`, not `Development Tooling`, so without naming it the owner rule would cover the linter but not the thing that makes the next change's tests runnable.

The successor is the owner of the tooling, not a second deliverable of foundation. Foundation builds one thing — the ignore entries — and names who builds the rest; calling the successor a deliverable would blur the decision-only line this design draws.

**7. The successor is not exempt from test authoring.** It is the first change after foundation, which the existing requirement already says gets no exemption. Its derived tests may be red until the runner they need exists; that is the ordinary state of tests derived before implementation, not a case for a second exemption.

**8. Branch protection: decided by foundation, applied by the change introducing CI, confirmed by the operator.** `project-init` is deterministic and runs before a remote, a stack or a CI job exists; a required status check must name a job that has reported at least once; changing forge settings is outward-facing. In `basis` the classifier refused the change in auto mode and the operator applied it by hand — the confirmation step makes that the designed path rather than a workaround. Rejected: having `project-init` detect a remote and report forge setup as outstanding. It would add a concern to a tool whose report already names foundation as the next step, and foundation now names the successor that owns it; detection without a decision adds a line, not an owner.

The application task exists only where a policy was decided. A reasoned "decided against" leaves nothing to apply, and a mandatory task would force a placeholder.

The `project-foundation` spec states initialization's non-involvement as rationale, not as a `SHALL NOT` on `project-init`. A normative clause binding `scripts/project-init` belongs in `project-bootstrap`, which owns it; stated here it would be invisible to a later change to that capability. `project-bootstrap` already says nothing about forges, and this change keeps it that way.

**9. Where the text lives.** The checklist content (items, fixed positions, delivery rule) goes in `rules/project-foundation.md`, as today. The skill gains only what changes the conversation: the `Development Tooling` items in its copy of the section layout, a sentence that the items are proposed as a set rather than asked, the rule that an item may be answered "not applicable" with a reason, with its gate sentence widened from `Identity` to every section carrying named items, and a replacement for "The development-tooling decision has a concrete deliverable" that names the one deliverable — the ignore file, including secret-bearing paths — and the successor as owner of everything else, and that foundation does not build the tooling. The skill keeps not restating the README/AGENTS split; every new item routes to `AGENTS.md` under `## Development Tooling`, which the fragment's existing rule already implies.

## Risks / Trade-offs

- [The named items lengthen the foundation conversation] → they are proposed as one coherent set once the stack is known; the operator confirms or redirects in bulk.
- [A reasoned "not applicable" can be used to skip a concern the project needs] → the reason is in the artifact, where a reviewer sees it; a silent gap was the failure this fixes.
- [The successor branch can be left unopened by a project that ignores the fragment] → nothing in this library enforces process in a consuming project; the archive precondition makes leaving it a visible breach of the checklist rather than an omission nothing names.
- [Coverage is verified by structural review only] → same as every existing `project-foundation` scenario; `tests/cases/` exercises `scripts/`, and foundation has no script.
- [`tests/coverage.md` already under-counts `project-foundation`] → it lists 14 of the spec's 18 scenarios, missing the four from "Settled decisions are surfaced…". This change touches that section anyway, so it adds the four missing rows alongside its own rather than leaving a count it would then have to verify against.

## Trigger check results

Recorded here by task 2.5.
