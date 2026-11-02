## Why

`.claude-plugin/plugin.json` has stood at `1.0.0` since `list-what-a-project-receives`, and an installed plugin is cached by that version, so `/plugin update` finds nothing new however much has merged. The operator's installed copy is still `0.2.0` and holds no `scripts/project-update`, so the update tool and its changelog reach nobody through the plugin. This is step 5 of `keep-projects-on-the-current-workflow`, whose Done when requires `/plugin update` to install the release a change shipped in.

## What Changes

- The plugin's version rises in every pull request whose diff changes a shipped path: `skills/`, `agents/`, `rules/` or `scripts/`. The operator decided this over rising only on an explicit release, which this repository has no process for.
- The size of the rise carries the meanings a fragment's version already has, for the plugin as a whole: major where a project or caller must do something by hand, minor for a new capability or a changed obligation, patch for the rest.
- A test holds what a diff can show: a change to a shipped path needs a rise above both where the branch left the trunk and the trunk's tip, a rise is at least as large as the largest fragment rise in the diff, a new skill, agent, script or fragment needs at least a minor, and removing one needs a major. Whether a change inside a script or skill is a fix or a new behaviour stays the author's judgement, and the code review's.
- `AGENTS.md` states the rule.
- `plugin.json` rises to `2.0.0`, the rise owed for what has merged since `1.0.0`, including two fragments' majors.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `toolkit-structure`: adds that the plugin's version rises with what it ships, and narrows *Skills are discovered without manifest enumeration* to enumeration, since a new skill now raises the version in `plugin.json`.

## Impact

- `.claude-plugin/plugin.json`, `AGENTS.md`, `docs/workstreams/keep-projects-on-the-current-workflow.md`, `tests/README.md`, `tests/coverage.md`, new cases in `tests/cases/`, and the check's logic in `tests/cases/lib/`.
- Every later pull request touching a shipped path edits `plugin.json`. Two open at once may make the same edit, which merges with no conflict, so the test compares with the trunk's tip and the second takes the next number of the size it owes.
- This repository has no CI, so the test holds only where `bash tests/run.sh` runs, which the workflow requires before a pull request. A required check is out of scope.
- No fragment's body changes, so no fragment's version rises and `rules/changelog` gains nothing.

## Workstream

Serves `keep-projects-on-the-current-workflow`, of which it is step 5.
