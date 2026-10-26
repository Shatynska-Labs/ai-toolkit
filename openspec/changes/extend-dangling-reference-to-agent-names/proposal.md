## Why

`tests/cases/workflow-fragment-no-dangling-reference.sh` scans the workflow and binding fragments for `rules/` paths, fragment filenames and `@` imports, but not for an `ai-toolkit:` name that the library does not ship. That gap let `build`'s Claude Code binding name a code reviewer before `agents/change-code-reviewer.md` existed, and nothing would report a recurrence. `add-change-code-reviewer` (design decision 8) split this out as its own backlog entry, `extend-dangling-reference-to-agent-names`.

**Workstream**: none. This change advances no open workstream.

## What Changes

- `session-workflow`'s publication requirement states that neither fragment names an `ai-toolkit:` agent or skill the library does not ship, beside its existing ban on `rules/` paths, fragment files and imports, with a scenario for it.
- A new case, derived by `change-test-writer` from the delta, scans both fragment bodies: every `ai-toolkit:<name>` resolves to `agents/<name>.md` or `skills/<name>/SKILL.md`, and a fixture naming an absent one is shown to be reported.
- `tests/coverage.md` gains a section for this change recording the new scenario against that case.
- The backlog entry `extend-dangling-reference-to-agent-names` is deleted at archive.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `session-workflow`: *The session obligations are published in the workflow fragment and one binding fragment* gains the ban on an unshipped `ai-toolkit:` name and a scenario for it.

## Impact

- `openspec/specs/session-workflow/spec.md` (at archive)
- a new case under `tests/cases/`, `tests/coverage.md`; `tests/cases/workflow-fragment-no-dangling-reference.sh` is left as it is
- `docs/backlog/extend-dangling-reference-to-agent-names.md` (deleted at archive)
- No fragment text changes, so the workflow fragment's version does not rise: the three names it carries today all resolve.
