# Test plan: retire-the-claude-md-import-notice

Written by `ai-toolkit:change-test-writer` before implementation. Not an artifact the OpenSpec schema knows about: `openspec instructions apply` does not list it, so read it on purpose before implementing.

Test command: `bash tests/run.sh` from the working-tree root. Each case is a file in `tests/cases/`, and `bash tests/run.sh` runs all of them. To run one case on its own: `TOOLKIT_ROOT=$PWD TESTLIB=$PWD/tests/lib.sh PROJECT_INIT=$PWD/scripts/project-init TESTDIR=$(mktemp -d) bash tests/cases/<name>.sh`. Cases below are named by file stem.

## Baseline

Full suite, taken before any case was written, at 6cb3e49 with a clean tree: **101 passed, 0 failed.**

After this pass: 113 cases, 102 passed, 11 failed. All 11 failures are new cases. No existing case changed result.

## Scenario accounting

The delta has one `MODIFIED` requirement, *Workflow rules reach a project as a versioned managed block*, with 8 scenarios. 8 are accounted for below: 4 are new or revised and covered by new cases, and 4 are unchanged and covered by existing cases.

| # | Scenario | Delta status | Covered by |
|---|---|---|---|
| 1 | A project's adopted version is readable | text unchanged | existing `managed-block-current-version.sh`, `inlined-body-matches-fragment.sh`. No new case, because the behaviour is not changed |
| 2 | Project content below the block survives | text unchanged | existing `existing-agents-md-appended.sh`. No new case |
| 3 | A project with only a CLAUDE.md | text unchanged | existing `claude-md-only.sh`. No new case |
| 4 | Rules written but not yet loadable are reported as such | WHEN revised (the target's `CLAUDE.md` exists without the import) | new `import-line-names-own-claude-md`. Existing `import-line-reported.sh` still holds (see Obsolete) |
| 5 | A shadowing file above the target is reported like one in it | new | new `shadowing-claude-md-above-target` (parent is not a repository), `shadowing-claude-md-in-enclosing-repo` (parent is a repository) |
| 6 | The user's own instructions file does not shadow | new | new `home-dot-claude-does-not-shadow` |
| 7 | No CLAUDE.md yields a version note, not an instruction | new | new `no-shadowing-file-version-note` |
| 8 | An existing block at a different version is reported, not rewritten | text unchanged | existing `managed-block-older-version.sh`. No new case |

Uncovered scenarios: none.

### Cases from the requirement body that no scenario names

These cover the requirement's definition of a shadowing file and its "state nothing" clause. Every assertion in them is specified by the requirement text:

- `shadowing-claude-local-md-in-target`: the target has `CLAUDE.local.md` and no `CLAUDE.md`, so the import line is printed.
- `shadowing-dot-claude-in-target`: the target has `.claude/CLAUDE.md`, so the import line is printed.
- `shadowing-claude-local-md-above-target`: a parent directory has `CLAUDE.local.md`, so the import line is printed.
- `shadowing-dot-claude-above-target`: a parent directory that is not `$HOME` has `.claude/CLAUDE.md`, so the import line is printed.
- `shadowing-importing-claude-md-above-target`: a parent's `CLAUDE.md` holds `@AGENTS.md` and the target has no `CLAUDE.md`, so the import line is printed. Only the target's own `CLAUDE.md` counts as importing ("a `CLAUDE.md` above the target would import that directory's `AGENTS.md`").
- `home-root-claude-md-shadows`: `$HOME/CLAUDE.md` exists and the target is under `$HOME`, so the import line is printed. Only `.claude/CLAUDE.md` in the home directory is excepted. This case catches an implementation that skips the whole of `$HOME`.
- `claude-md-import-states-nothing`: the target's `CLAUDE.md` holds `@AGENTS.md`, so the report has neither the import line nor the note ("the report SHALL state nothing about the import").

## Assertion classification

Shared assertion `assert_import_line` is used in `import-line-names-own-claude-md`, all `shadowing-*` cases and `home-root-claude-md-shadows`:

| Assertion | Class | Basis |
|---|---|---|
| A line containing `Import needed:` is present | specified | spec: "the report SHALL state the one line the user must add". The `Import needed:` prefix is the existing normative token (tests/README.md), and design Decision 2a keeps it |
| That line contains `@AGENTS.md` | specified | the line the user must add |
| That line contains `own CLAUDE.md` | **derived** | the spec requires "naming the target's own `CLAUDE.md`" but sets no wording. The substring comes from design Decision 2a's proposed wording ("this project's own CLAUDE.md") |
| That line contains `creat` | **derived** | the spec requires "that the file may need creating". The substring comes from Decision 2a ("create it if absent") |
| The report does not contain `2.1.277` | **derived** | stands in for "not the version note" (scenario 5). It assumes the note is the only output that names 2.1.277 |
| The shadowing or `CLAUDE.md` file is unchanged / no target `CLAUDE.md` is created | specified | "SHALL still write nothing into any such file"; the proposal says the tool creates no `CLAUDE.md` |
| exit 0, `AGENTS.md` created | specified | existing ordered branches |

Shared assertion `assert_version_note` is used in `no-shadowing-file-version-note` and `home-dot-claude-does-not-shadow`:

| Assertion | Class | Basis |
|---|---|---|
| No `Import needed:` anywhere in the report | specified | "SHALL NOT state that the import is needed", and the note is "not beginning `Import needed:`" |
| No `for the rules to take effect` anywhere in the report | **derived** | the old line's wording. Absence is a stand-in for not stating that the import is needed |
| A line contains `2.1.277` | specified | "naming the version from which Claude Code reads `AGENTS.md` without a `CLAUDE.md`". The version comes from the spec's recorded observation |
| That line does not begin `Import needed:` | specified | spec |
| That line begins `Note:` | **derived** | design Decision 2's proposed wording |
| Report contains `2.1.281` | specified | "the later version for the providers and sessions it reached afterwards" |
| Report contains `Project instructions` | specified | "that its 'Project instructions' setting can turn the fallback off" |

`claude-md-import-states-nothing`: the absence of `Import needed:` is specified. The absence of `2.1.277` is **derived**, standing in for the note, the same as above.

Deliberately untested:

- Where the note sits in the report's line order. The spec states no order, and tests/README.md's form is updated by task 2.1, after this pass.
- That the note names Bedrock, Vertex AI and the other providers. The spec requires the later version for them, not the names.
- An import placed in the target's `CLAUDE.local.md` or `.claude/CLAUDE.md`. This is design Non-Goal 4: the import line is still printed there, and the spec does not require it either way.
- Detecting the Claude Code version or the `/config` setting. This is Non-Goal 2.

## Failure state of each new case at authoring

The target script exists, so these runs reach the assertions. Each case exits at its first failing assertion, so assertions after that one have not run yet.

- `no-shadowing-file-version-note`, `home-dot-claude-does-not-shadow`: **state 1, code ran and gave a wrong value.** Both fail on `Import needed:` being present. The note-content assertions after it have not run yet.
- `import-line-names-own-claude-md`, the seven `shadowing-*` cases, `home-root-claude-md-shadows`: **state 1.** Each fails on the derived `own CLAUDE.md` wording. The specified part (an `Import needed:` line with `@AGENTS.md`) already passes against the current script, which prints the line whenever the target's `CLAUDE.md` lacks the import. So against the current code these cases tell the two apart only through the derived wording. Against an implementation that checks only the target's own `CLAUDE.md` for shadowing (the rejected first draft in design Decision 1), the five above-target cases fail on the specified part: such an implementation would print the note there.
- `claude-md-import-states-nothing`: **state 4, passed on first run.** Investigated: the behaviour already holds, because the current script prints no import line when the import is present and has no note at all. The case only starts telling right from wrong once the note exists. Record it as a guard against regression, not as coverage gained.

**Precondition guard discriminator.** The no-shadowing-file guard is inlined in `no-shadowing-file-version-note` and `home-dot-claude-does-not-shadow`. It was run against a scratch fixture with each of `CLAUDE.md`, `CLAUDE.local.md` and `.claude/CLAUDE.md` above `$TESTDIR`. It failed with the precondition reason all three times, and passes in this environment. It lists a file twice when `$TESTDIR`'s logical and physical paths are the same. That is cosmetic.

## Obsolete tests (candidates for human confirmation)

The superseded behaviour comes from comparing the delta with `openspec/specs/project-bootstrap/spec.md`. The current requirement says the import line is reported "whenever `CLAUDE.md` does not already contain the import, whether `CLAUDE.md` is absent entirely…". The delta removes the absent-and-unshadowed case and replaces it with the version note. The search covered `tests/cases/*.sh` only. It matched on `Import needed`, `import` and `CLAUDE.md`, and checked every case that runs `project-init` in a directory with no `CLAUDE.md` and greps the report.

| Test | Superseding delta | Evidence | Marking |
|---|---|---|---|
| `empty-directory-new-project`, the assertion at line 26: `assert_contains "$report" "Import needed:" "neither file existed — CLAUDE.md does not import AGENTS.md, so the import line must be reported"` | MODIFIED *Workflow rules reach a project as a versioned managed block*, which says "Where no shadowing file exists, the report SHALL NOT state that the import is needed" | it asserts `Import needed:` in an empty target with no shadowing file, the exact case the delta reverses. Its message gives the superseded reasoning | **candidate for human confirmation**. It will fail once task 2.2 lands. Task 2.3 owns updating it. Only this one assertion is superseded, and the case's other assertions cover other scenarios |

Reviewed and judged **not** obsolete:

- `import-line-reported`: the target's `CLAUDE.md` exists without the import, which is still a shadowing case. Its assertions (`Import needed:`, `@AGENTS.md`, `CLAUDE.md` unchanged) all still hold under the delta, and Decision 2a keeps both tokens. Its header comment ("not only when CLAUDE.md is absent") gives superseded reasoning, but no assertion depends on it.
- `claude-md-only`: asserts that no `Import needed:` line appears when `CLAUDE.md` holds `@AGENTS.md`. This is unchanged under the delta.

These are outside the test glob and are not tests, so they are listed only for the implementer: `tests/coverage.md` row "Rules written but not yet loadable…" names `empty-directory-new-project.sh` (task 2.4), and the `Import needed:` line in the `tests/README.md` report form (task 2.1).

## Unresolved project questions

1. **Wording of the import line and the note.** The spec sets the content, not the wording, and the normative form in `tests/README.md` is only updated by task 2.1, after this pass. Assumption: the wording proposed in design Decisions 2 and 2a. These cases depend on it: every case using `assert_import_line` (the `own CLAUDE.md` and `creat` substrings) and every case using `assert_version_note` (the `Note:` prefix). If task 2.1 settles on different wording, these are derived assertions: reconsider them openly, not as a repair.
2. **What "the user's home directory" resolves to.** Assumption: `$HOME` as set when the script runs, matching design Decision 1. This affects `home-dot-claude-does-not-shadow` and `home-root-claude-md-shadows`. Both export `HOME`, `XDG_CONFIG_HOME` and `GIT_CONFIG_NOSYSTEM` the way the `initial-branch-*` cases do. Comparing logical against physical paths, for example when `TMPDIR` goes through a symlink, is not exercised.
3. **Where to put the shared helpers.** `tests/lib.sh` is outside the dispatched glob, so the precondition guard and the two assertion helpers are copied inline into each case. Whether they belong in `lib.sh` is for the project to decide. Moving them is a refactor of these cases and must keep each case's assertions and results the same.
4. **No-shadowing-file assumption for the environment.** The two note cases need no shadowing file above `$TESTDIR` (design Risks). If there is one, they fail with the precondition reason, not a script finding. Task 2.1 records this assumption in `tests/README.md`.

## What implementation must make pass

All 113 cases. Specifically, the 11 failing new cases above, `claude-md-import-states-nothing` staying green, and `empty-directory-new-project` once task 2.3 updates its obsolete assertion.
