## Why

`scripts/project-init` never rewrites a block it finds, and reports a block at an older version as skew it says is out of scope. Since `list-what-a-project-receives` every rule the toolkit puts in a project is a managed block that `rules/manifest` lists, each opening marker carries its version and the hash of what was written, and versions are semantic from `1.0.0`. Nothing yet acts on any of it: every adopting project still holds a `v12` (or `v10`) workflow block and its backlog and workstream rules in `README.md` files, and `project-init` reports those READMEs as legacy and writes nothing beside them. The projects are synced by hand, which is what the workstream exists to end.

This change was proposed in September and stopped at three open questions. The workstream answered them on 2026-10-28: an edited block is reported with its difference and never overwritten; the tool is a separate executable from `project-init`; one project per run.

**Workstream**: `keep-projects-on-the-current-workflow`, its second step.

## What Changes

- **A new shipped tool, `scripts/project-update`**, run against one project, classifies each block the manifest lists as current, stale, edited, ahead of the toolkit, malformed or absent, from the block alone, and reports each.
- **A stale block nobody edited is replaced**: the lines from its opening marker to its closing marker become the block the toolkit writes today, and every byte outside the markers is unchanged.
- **An edited block is never overwritten.** Its hash no longer matches its marker; the tool reports it, with a unified diff between what the block holds and what the toolkit would write, and leaves the file as it is.
- **The shapes before `1.0.0` are converted once.** A `v<N>` block, which carries no hash, is replaced; a directory's `README.md` holding its rules is removed and its rules written as the block into that directory's `AGENTS.md`, beside a `CLAUDE.md` importing it. Neither can be checked for edits, so the tool converts them only where git can show and undo the conversion: every file a conversion touches is tracked and unmodified, or the run blocks before writing anything. Every legacy item in a project is converted in one run, so a project never holds the `1.0.0` root block beside an old README.
- **`project-init` names the remedy instead of calling it out of scope.** Its report of a block at a lower version, and of a directory holding its rules in a README, names `scripts/project-update`; a block at a higher version is reported ahead of the toolkit, naming no tool.

## Capabilities

### New Capabilities

- `project-update`: the update tool — what it classifies, what it replaces and converts, what it refuses, its preconditions, outcomes and report.

### Modified Capabilities

- `project-bootstrap`: a block already present at a lower version, and a directory holding its rules in a README, are reported with `scripts/project-update` as the remedy, not as out of scope; a higher version is reported ahead. `project-init` itself still never rewrites a block.

## Impact

- `scripts/project-update`, new; `scripts/project-init`, two report lines and `--help`.
- `openspec/specs/project-update/spec.md`, new; `openspec/specs/project-bootstrap/spec.md`.
- `tests/`: new cases for the update tool; `managed-block-older-version.sh` and the legacy-README cases assert the old "out of scope" wording and are revised where the delta replaced it; `tests/README.md` gains the update tool's report contract.
- `AGENTS.md` and `rules/README.md`, where they name the shipped tools that read a fragment; `skills/project-init/SKILL.md` where it relays the report's next step.
- The adopting projects — `fuperia/commerce-ops`, `fuperia/infrastructure`, `shatynska/basis`, `shatynska/infrastructure`, `infrastructure-template` — are the material for confirming the tool against real blocks rather than fixtures.
- Not here: the changelog of what each version asks (`record-what-each-version-asks`), the plugin's version on release (`raise-the-plugin-version-on-release`), and a skill wrapping the tool.
