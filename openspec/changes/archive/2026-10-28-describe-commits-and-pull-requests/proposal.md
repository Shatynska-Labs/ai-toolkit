## Why

Pull requests are what a reviewer, and later a reader of the history, actually opens. Yet nothing in this library says what a pull request's title or description carries. The workflow fragment requires only that folded-in work be named in the description. The foundation checklist makes a project decide its commit-message convention but asks nothing about pull requests. This repository's own pull requests show the drift: titles switched from commit-style (`feat(backlog): …`) to plain sentences around #62, archive pull requests are titled two different ways, and descriptions range from sectioned (#72) to free prose (#73).

Putting the guidance in the workflow fragment would grow every adopting project's `AGENTS.md` with formatting guidance that matters only when a commit or pull request is being written. The operator asked for a skill instead: it loads on demand and costs a project nothing until then.

## What Changes

- New skill `skills/commits-and-pull-requests/SKILL.md`, with a `references/` file for the record pull request. It covers commit messages and pull requests together, because a pull request's description summarises its commits and folded-in work is named in both. It holds:
  - **Precedence:** a project's own commit convention, pull request template and stated conventions win over the skill's defaults.
  - **Commit messages:** the subject follows the project's convention; the body says why, not what the diff already shows; folded-in work is said to be folded in.
  - **Pull request title:** the effect, written for a reader who will not open the diff. A pull request spans several commits, often on different concerns, so its title is not a commit subject and does not take a commit-convention prefix.
  - **Pull request description:** what changed, why (with a link to the change record), what else it carries (folded-in work), and the verification actually run with its results and review verdicts. Nothing is claimed that was not run.
  - **The workflow's pull request kinds:** the work, a fix re-entering at review, and the record. The record's content (which pull requests it records, the specification sync, the outcome of the backlog and workstream re-read, the confirmation or waiver) lives in `references/`.
- `rules/development-workflow.md`: one Claude Code binding line under `open pr` naming the skill. The fragment states no pull request format itself. Its `version` increments, since its body changes.
- `rules/project-foundation.md` and `skills/project-foundation/SKILL.md`: a new **Pull requests** development-tooling item, separate from **Commit messages**: what a pull request's title and description carry, whether the forge supplies a template, and whether anything checks it. It is deliberately not tied to the commit convention.

## Capabilities

### New Capabilities

- `commit-and-pull-request-practice`: what the `commits-and-pull-requests` skill covers — precedence of project conventions, commit-message content, pull request titles and descriptions, and the content of each pull request kind the workflow produces.

### Modified Capabilities

- `session-workflow`: the rule that an operational skill carries no obligation the fragment does not state gains a form-skill clause naming `commits-and-pull-requests`; the workflow fragment binds writing a pull request's title and description to the skill under `open pr`, and states no pull request format itself.
- `project-foundation`: the development-tooling decision gains a pull request concern, separate from the commit-message convention, and the design artifact's `Development Tooling` section gains a `Pull requests` item.

## Impact

- New: `skills/commits-and-pull-requests/SKILL.md`, `skills/commits-and-pull-requests/references/record-pull-request.md`.
- Modified: `rules/development-workflow.md` (body and `version`), `rules/project-foundation.md`, `skills/project-foundation/SKILL.md`.
- Trigger fixtures: the new skill competes with every asset whose recorded fixture mentions commits or pull requests (`create-skill`, `create-agent`, `n8n-workflow-review`, `change-code-reviewer`) and with `backlog`, whose archive sweep reads merged pull requests, so those checks are re-run, per `skill-authoring`'s invalidation rule.
- Adopting projects receive the binding line when their managed block is next updated; until then nothing changes for them.
- `tests/coverage.md` accounts for the new and modified scenarios.
- The change advances no workstream.
