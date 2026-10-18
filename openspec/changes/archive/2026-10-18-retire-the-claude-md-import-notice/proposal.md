## Why

`scripts/project-init` reports `Import needed: add @AGENTS.md to CLAUDE.md for the rules to take effect` whenever `CLAUDE.md` does not import `AGENTS.md`, including where no `CLAUDE.md` exists, which is every new project. That rested on an observation from 2026-08-17 that Claude Code did not read `AGENTS.md` on its own. It does now: Claude Code 2.1.277 added reading `AGENTS.md` in a project with no `CLAUDE.md`, and 2.1.281 extended that to Bedrock, Vertex AI, Foundry, gateways and telemetry-disabled sessions. On 2026-10-18, at 2.1.302, a scratch project with only `AGENTS.md` applied its rule, and one with a `CLAUDE.md` lacking the import did not.

So in the common case the report tells the operator to do something unnecessary, and in the one case where the instruction is still true it is indistinguishable from that noise. This change replaces the backlog entry `act-on-the-claude-md-import-at-initialization`, whose premise (that a new project's rules are inert until the import is added) no longer holds.

## What Changes

- Where any project instructions file shadows the fallback — `CLAUDE.md`, `CLAUDE.local.md` or `.claude/CLAUDE.md` in the target or any directory above it, the user's own `~/.claude/CLAUDE.md` excepted — and the target's `CLAUDE.md` doesn't import `AGENTS.md`, the report keeps the `Import needed:` line. That includes a target nested in a directory with its own `CLAUDE.md`, which today's check misses only by luck of always printing the line.
- Where no such file exists, the report no longer says the import is needed. It prints a note instead, naming the Claude Code versions from which `AGENTS.md` is read without a `CLAUDE.md`, and the setting that can turn that off.
- The `project-bootstrap` requirement records the new observation next to the old one, and makes the reporting obligation depend on whether a shadowing file exists, defining which files shadow.
- The tool still writes nothing into `CLAUDE.md` and creates none.
- `docs/backlog.md`: delete `act-on-the-claude-md-import-at-initialization`.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `project-bootstrap`: *Workflow rules reach a project as a versioned managed block* — the import-needed obligation applies where a shadowing file exists and the target's `CLAUDE.md` doesn't import `AGENTS.md`; where none exists, a version note.

## Impact

- `scripts/project-init`: the import-reporting branch, and its `--help` if it describes the import.
- `tests/README.md`: the normative report form, whose import line condition and wording change and which gains the note line.
- `tests/coverage.md`: the change's scenarios.
- `tests/cases/`: `empty-directory-new-project.sh` asserts the import line where neither file exists, so it becomes obsolete. New cases come from the delta's scenarios.
- `docs/backlog.md`: one entry deleted.
- Not affected: the fragment, so no version bump; the `project-init` skill, which relays whatever the report says; `CLAUDE.md` handling otherwise.
