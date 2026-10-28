# tests/

Exercises `scripts/project-init`, `scripts/project-update` and `scripts/backlog-migrate`, the library's shipped tools — the first things in this library verified by running code rather than by review.

## Why these cases are written directly, not dispatched

The development workflow this change ships requires tests be derived from a change's specification by an independent author (`ai-toolkit:change-test-writer`) before implementation. This suite does not follow that path. The agent's dispatch contract requires a test command and a test-path glob as essential inputs — and neither exists until this harness creates them. Deriving this suite's own tests from a dispatch that needs this suite to already exist is circular, the same structural bootstrap problem `rules/project-foundation.md` records for the foundation change's test-authoring exemption. This is recorded as a stated exemption for this one suite, not a precedent: the very next change to this repository has a real test command (`bash tests/run.sh`) and a real test-path glob (`tests/cases/**`), and `change-test-writer` applies normally to it.

## The exemption's second use, and why

`revise-development-workflow` added three cases to this suite (`fragment-role-before-tool.sh`, `inlined-body-matches-fragment.sh`, and the `fragment_version` helper the version-coupled cases now use) without dispatching `ai-toolkit:change-test-writer`. That is a second stated exemption, recorded here rather than decided silently, because the paragraph above forecloses the silent option.

The reason is not the circularity that excused the first use — this suite has a real test command and a real test-path glob now. It is that the agent's own dispatch contract requires a change that "has passed review and is ready for implementation", and this change had no such verdict: its review returned `CHANGES REQUIRED` on its third round — the verdict set of the day, quoted as it was recorded — and implementation proceeded on the maintainer's explicit direction instead. Dispatching a test author against a plan no verdict had cleared is the precondition failure the workflow rules this very change introduces forbid. The exemption is therefore narrower than the first: it does not say test authoring was impossible, only that its stated precondition was not met, and it expires with the verdict.

What this costs is real and worth stating: these three cases were written by whoever wrote the change, so they carry that author's blind spots. Two are guarded against the usual failure of a test that cannot fail — each was run against a deliberately violating fixture and observed to fail, and each carries a vacuity guard that fails rather than passes when its extraction comes back empty.

## Running

```
bash tests/run.sh [CASE...]
```

With no argument every case runs; naming one or more cases, by file name with or without `.sh`, runs only those, and a name matching no case counts as a failure.

Each file in `tests/cases/*.sh` runs as its own subprocess in a fresh `mktemp -d` temporary directory (`$TESTDIR`), so no case can observe another's filesystem state. `tests/lib.sh` supplies `assert_exit`, `assert_file`, `assert_file_absent`, `assert_unchanged`, `assert_contains`, and `fenced_line` (the line number of a fenced `**<label>**` field, written as a paragraph or a list item) — sourced via `$TESTLIB`, which `run.sh` exports. A failed assertion prints to stderr and exits the case non-zero immediately. `run.sh` itself exits non-zero if any case failed.

## The report contract

`scripts/project-init` prints a fixed, greppable report to stdout. Cases assert against these tokens, so the script and this suite must agree on them — this is the normative form, written before the script, and section 5 implements against it rather than inventing wording independently.

A **shadowing file** is `CLAUDE.md`, `CLAUDE.local.md` or `.claude/CLAUDE.md` in the target or any directory above it, other than `$HOME/.claude/CLAUDE.md`. Cases asserting the note assume none exists above `$TESTDIR`; they check that first and fail with that reason rather than reporting a script defect.

Each applicable line, in order:

```
Target: <absolute path>
repository: created | already present
specification tooling: created via `openspec init --tools <value>` | already present
ignore file: created | already present
backlog: created | created beside existing entries | block appended to docs/backlog/AGENTS.md (version N)
       | already present (version N, matches)
       | already present (existing version N, tool carries version M; bring it current with <toolkit>/scripts/project-update)   [N lower]
       | already present (existing version N, tool carries version M; the block is ahead of this toolkit)   [N higher]
       | already present (existing version 'N', tool carries version M; the marker is malformed, see <toolkit>/scripts/project-update)   [N in neither form]
       | rules present as docs/backlog/README.md, the shape before 1.0.0 (tool carries version M); convert it with <toolkit>/scripts/project-update, nothing written
       | present as the single file docs/backlog.md; convert it with scripts/backlog-migrate
       | docs/backlog is not a directory the tool writes into; nothing written
       | docs/backlog/AGENTS.md is not a file the tool writes into; nothing written
workstreams: [the backlog's forms, for docs/workstreams/, with "created beside existing files"; no single-file form]
conventions file: created with block (version N)
           | block appended (version N)
           | block already present (version N, matches)
           | block already present (existing version N, tool carries version M; …)   [the three forms above]
directory import: docs/<dir>/CLAUDE.md created holding @AGENTS.md   [one per seeded directory where it was absent]
directory import: add the line @AGENTS.md to docs/<dir>/CLAUDE.md for docs/<dir>/AGENTS.md to load   [where that file exists without it]
Import needed: add `@AGENTS.md` to this project's own CLAUDE.md (create it if absent) for the rules to take effect   [only when the target's CLAUDE.md does not import AGENTS.md and a shadowing file exists]
Note: Claude Code reads AGENTS.md without a CLAUDE.md from version 2.1.277 (2.1.281 on Bedrock, Vertex AI, Foundry, gateways and telemetry-disabled sessions), unless its "Project instructions" setting says otherwise; on an earlier version, add `@AGENTS.md` to a CLAUDE.md.   [only when no shadowing file exists]
Outcome: SUCCESS | BLOCKED | ERROR
Reason: <text>   [BLOCKED or ERROR only]
Next step: foundation discovery — run /project-foundation to establish this project's foundation.   [new-project SUCCESS only]
Next step: none required — foundation discovery is available if you want to record this project's decisions; run /project-foundation.   [adoption SUCCESS only]
```

The seeded directories' lines follow the manifest's order, then the conventions file's, whatever order the blocks are written in; a record added to the manifest reports under its own name. A version N is `MAJOR.MINOR.PATCH`, or `v<N>` for a marker written before `1.0.0`.

`Target:` is printed before any filesystem change, per the target-directory requirement. A `BLOCKED` outcome prints `Target:` and `Reason:` and nothing else that implies a change was made.

## CLI contract

```
project-init [--tools <value>] [--help|-h] [TARGET_DIR]
```

- No arguments: operates on the current working directory, `--tools` defaults to `claude`.
- `TARGET_DIR`: optional positional argument, initializes that directory instead of the current one.
- `--tools <value>`: passthrough to `openspec init --tools <value>`.
- `--help` / `-h`: prints usage covering modes, arguments, flags, outcomes, and exit codes; makes no filesystem change; exits 0.
- Exit codes: `0` SUCCESS, `1` ERROR, `2` BLOCKED.

## project-update's report

`scripts/project-update [--help|-h] [TARGET_DIR]` takes `project-init`'s outcomes and exit codes: `0` SUCCESS, `1` ERROR, `2` BLOCKED. One line per manifest record, in manifest order, then the directory-import lines, then:

```
Target: <absolute path>
<name>: current (version X)
<name>: replaced (version X → Y)
<name>: converted from version vN to Y; not checked for edits, review with git diff
<name>: converted from <dir>/README.md to <dir>/AGENTS.md (version Y), README.md removed; not checked for edits, review with git diff
<name>: edited inside the markers (version X, toolkit carries Y); not replaced
    [unified diff, labelled project and toolkit, each line indented]
<name>: ahead of this toolkit (version X, toolkit carries Y); not replaced
<name>: markers malformed in <target>; not replaced
<name>: <target> is not a path the tool writes into; nothing written
<name>: absent; run <toolkit>/scripts/project-init to write it
backlog: present as the single file docs/backlog.md; convert it with <toolkit>/scripts/backlog-migrate
directory import: <dir>/CLAUDE.md created holding @AGENTS.md
directory import: add the line @AGENTS.md to <dir>/CLAUDE.md for <dir>/AGENTS.md to load
Attention: <name>, <name>   [only where a record was left edited, ahead, malformed, unwritable, absent or single-file]
Written before the failure:   [ERROR only, one indented line per file, saying whether to restore, remove or leave it]
Outcome: SUCCESS | BLOCKED | ERROR
Reason: <text>   [BLOCKED or ERROR only]
```

## backlog-migrate's report

`scripts/backlog-migrate [--help|-h] [TARGET_DIR]` takes `project-init`'s outcomes and exit codes: `0` SUCCESS, `1` ERROR, `2` BLOCKED. Its report:

```
Outcome: SUCCESS | BLOCKED | ERROR
Reason: <text>   [BLOCKED or ERROR only; one line per offending heading where headings block]
converted: <N> entries into docs/backlog/   [SUCCESS only]
preamble: the old preamble was not carried over; ...   [SUCCESS only]
kept or written for review:   [SUCCESS, where any line follows]
  <entry>: <Field> kept in the body: <why>
  <entry>: field <Label> kept as written
  <entry>: no kind written; the entry has no Kind field
  <entry>: Depends on read as waits_on
  <entry>: waits_for written: "<text>"
  <entry>: parked_until written: "<text>"
```

Each review line names its entry and its field or key on one line, so a case reads it with one `grep` for the entry and one for the field.

See `coverage.md` for which specification scenario each case (or its absence) accounts for.
