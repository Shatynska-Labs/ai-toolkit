## Context

See proposal.md — Why. The workflow fragment (`rules/development-workflow.md`, version 12) is inlined into every adopting project's `AGENTS.md`, and its `ship` stage already names agents in Claude Code bindings beneath the role they fill. `tests/cases/workflow-fragment-names-shipped-assets.sh` resolves every `ai-toolkit:` name in the fragment against `agents/` and `skills/`, so a binding naming a skill is already covered by an existing check. `rules/project-foundation.md` is a procedural checklist (unversioned, never inlined); its `Development Tooling` items are repeated in `skills/project-foundation/SKILL.md` and in the `project-foundation` spec.

## Goals / Non-Goals

**Goals:**
- One place that says what a commit message and a pull request carry, loaded only when one is written.
- A reliable route to it from the workflow, without the fragment carrying the format.
- Foundation asks each project to decide its pull request convention, independently of its commit convention.

**Non-Goals:**
- Choosing a commit convention for any project, this one included.
- When to commit or open a pull request, or how many a change takes — the workflow fragment's.
- A pull request template file seeded by `scripts/project-init`, or any check enforcing the format.
- Rewriting this repository's past pull request titles or descriptions.

## Decisions

**1. A skill, not fragment text.** The operator chose this: the guidance is about form, matters a few times per change, and every line in the fragment is carried in every session of every adopting project. A skill costs nothing until it loads. *Alternative:* a "Pull requests" paragraph in the fragment — rejected for exactly that cost. *Alternative:* a separate unversioned `rules/` fragment imported by hand — rejected because nothing would load it at the moment a pull request is written.

**2. One skill covering commits and pull requests.** A description summarises its commits, and folded-in work is named in both, so splitting them would put one rule in two skills. Name: `commits-and-pull-requests` — the directory is the invocation name, and the name says both halves; checked free under `skills/`. *Alternative:* `pull-requests` alone — rejected, it would leave commit-message bodies and the folded-in commit form with no home.

**3. Reached by one binding line at `open pr`, and by description for commits.** Skill triggering is probabilistic, so the moment that matters most — writing the pull request — gets a binding in the fragment, the same mechanism as the reviewer bindings: `_Claude Code binding:_ write the pull request's title and description with `ai-toolkit:commits-and-pull-requests`.` Commits are written far more often and mostly need only the project's own convention, which is already in its `AGENTS.md`; they rely on the skill's description. *Alternative:* a second binding under *Commits* — rejected to keep the fragment's growth to one line; revisit if commit bodies are observed not to load the skill.

**4. No commit convention named.** The skill reads the project's convention; foundation is where it is decided. Naming Conventional Commits in the skill would decide it for every installing project.

**5. Pull request title is the effect, never a commit subject.** Per the operator: a pull request spans several commits on different concerns. Foundation's new item is therefore separate from *Commit messages* and is not framed as "do titles follow the commit convention". This repository's own practice since #62 already matches.

**6. The record pull request's content in `references/record-pull-request.md`.** It is needed once per change and is the longest of the three kinds. The work and fix kinds stay in `SKILL.md`, short enough to read in one pass.

**7. Frontmatter.** Tags: `[git]`, new. No existing tag (`review`, `openspec`, `project-lifecycle`, `authoring`, `hitl`, `testing`, language and infrastructure tags) classifies version-control practice; `review` was considered and rejected, since the skill writes what a reviewer reads rather than reviewing. No `allowed-tools`: the skill wraps no single command. The description disambiguates against `backlog` (archive sweeps read merged pull requests), `change-code-reviewer` (reviews a diff before the pull request), `openspec-archive-change` (the archive itself), and `create-skill`, whose positive fixture mentions commit messages. At the Draft checkpoint the operator asked for a shorter description; the approved one disambiguates against `change-code-reviewer`, `backlog` and `openspec-archive-change` only, and leaves `create-skill` to the trigger check, which routed `create-skill`'s fixtures unchanged.

**8. The skill is classified as a form skill under `session-workflow`.** That capability forbids an operational skill to carry an obligation the fragment does not state, so that a session never loading it still meets every obligation. The skill's content — title wording, description sections, describing a fix or record pull request, revising a description after review — is form, and losing it costs only form; the one constraint it touches, naming folded-in work, stays stated in the fragment. A `MODIFIED` block adds a narrowly worded form-skill clause to that requirement rather than leaving the classification implicit. *Alternative:* rephrase the skill's spec as advisory without touching `session-workflow` — rejected, because the contradiction would remain for the next editor to resolve, plausibly by moving the content into the fragment against decision 1.

**9. Fragment version 12 → 13.** The binding line is body text, so `project-bootstrap`'s increment rule applies.

## Risks / Trade-offs

- [The skill does not load when a commit is written] → commit subjects follow the project's own convention from `AGENTS.md` regardless; only body guidance is lost. Decision 3 names the revisit.
- [Adopting projects at version 12 lack the binding] → the skill still triggers by description; the binding arrives when their managed block is updated.
- [The default description sections clash with a forge template] → precedence requirement: the template wins.
- [A new competing asset silently falsifies recorded trigger fixtures] → re-run, in this change, every recorded fixture whose prompt mentions commits or pull requests — `create-skill`, `create-agent` and `n8n-workflow-review` in their `SKILL.md`, and `change-code-reviewer.checks.yaml` — and `backlog`'s, whose archive sweep reads merged pull requests.

## Migration Plan

None beyond the version increment. Rollback is reverting the change's pull request; no project state depends on the skill.
