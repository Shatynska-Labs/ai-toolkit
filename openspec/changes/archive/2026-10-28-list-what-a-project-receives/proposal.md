## Why

The operator changes the workflow often, and the projects that adopted it are synced by hand. Nothing in the toolkit says what it puts into a project, and only one of the three things it writes carries a version: the `AGENTS.md` block is marked `v12`, while `docs/backlog/README.md` and `docs/workstreams/README.md` carry none, so no tool can tell an older copy from one a project edited. The two READMEs are also not loaded by Claude Code unless something sends a session to them. An update tool needs a list of what it maintains, a version on each item, and a way to tell an edit from an older text; this change provides those three, so the tool that follows has something to read.

**Workstream**: `keep-projects-on-the-current-workflow`, its first step.

## What Changes

- **Every rule the toolkit puts in a project is a managed block.** The backlog's and the workstreams' rules move from seeded `README.md` files into blocks in `docs/backlog/AGENTS.md` and `docs/workstreams/AGENTS.md`, delimited and generated like the workflow block in the root `AGENTS.md`. A project may add its own text to either file, outside the markers. **BREAKING** for adopting projects: their READMEs are not converted by this change; `update-managed-block` converts them.
- **Each directory gets a `CLAUDE.md` holding `@AGENTS.md`**, created where absent, so the rules load whenever a session reads or writes a file there. A root `CLAUDE.md`, which every adopting project has, keeps a directory's `AGENTS.md` from loading on its own.
- **The texts become `rules/` fragments.** The backlog's seed and the workstreams' heredoc in `scripts/project-init` become `rules/backlog.md` and `rules/workstreams.md`, and `scripts/seed/` is removed.
- **A manifest lists what a project receives.** `rules/manifest` names each block and the file it is written into, in the flat YAML subset the backlog entries use; `scripts/project-init` writes exactly what it lists.
- **Versions are semantic, and everything starts at `1.0.0`.** Every fragment's `version` becomes `MAJOR.MINOR.PATCH`, at `1.0.0` (the workflow fragment was `12`), and so does the plugin's (`0.2.0`). A patch changes wording only, a minor changes an obligation that needs no edit in the project, a major asks the project to do something by hand.
- **A block's opening marker carries its version and the hash of the body written**, e.g. `<!-- ai-toolkit:backlog 1.0.0 sha256:… -->`, so a later tool tells an edited block from an older one with no history of past versions and no record file in the project. A legacy `vN` marker is read as older than `1.0.0`.
- **`scripts/backlog-migrate` converts the entries only**, and names `scripts/project-init` as what writes the backlog's rules, so one tool writes every block.
- **The `backlog` skill and the workflow fragment name the directories' `AGENTS.md`**, the skill falling back to a legacy `README.md` where no block exists.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `project-bootstrap`: the managed block generalises from the workflow fragment to every manifest entry, its marker gains the hash and a semantic version; the backlog and workstream registers are seeded as blocks with a directory `CLAUDE.md`, and a legacy README is reported, not converted; the resources it reads are the fragments and the manifest; the version rule becomes the semantic one.
- `toolkit-structure`: `rules/` holds the manifest; `scripts/seed/` is removed and the statement of why a seed is not a fragment with it; the fragment's `version` is semantic and the plugin's starts at `1.0.0`.
- `backlog-migration`: the tool no longer writes the backlog's rules, and reports that `scripts/project-init` writes them.
- `backlog-maintenance`: the skill reads the rules from the directories' `AGENTS.md`, or a legacy `README.md` where no block exists, and record refuses `agents` and `claude` as it refuses `readme`.
- `session-workflow`: the fragment defers to the directories' `AGENTS.md` rather than their README.

## Impact

- `scripts/project-init`, `scripts/backlog-migrate`; `scripts/seed/` removed.
- `rules/`: `backlog.md` and `workstreams.md` added, `manifest` added, every fragment's `version` to `1.0.0`, the workflow fragment's three README references; `rules/README.md`.
- `AGENTS.md` (Reaching a project; Three categories), `.claude-plugin/plugin.json` (`1.0.0`), `skills/backlog/SKILL.md`, `skills/project-init/SKILL.md`.
- This repository's own `docs/backlog/README.md` and `docs/workstreams/README.md` become the blocks, each with a `CLAUDE.md`.
- `tests/`: about 60 cases name the READMEs or the seed; the derived cases cover the manifest, the marker and the directory files.
- Adopting projects keep their READMEs until `update-managed-block` converts them; `project-init` reports a legacy README and writes no block beside it.
- `openspec/changes/update-managed-block` is the workstream's next step and is revised against this one when it is planned.
