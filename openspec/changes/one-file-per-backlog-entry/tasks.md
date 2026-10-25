## 1. Seed

- [x] 1.0 State in `AGENTS.md`'s *Three categories* what `scripts/seed/` holds and why it is not `rules/` (`toolkit-structure` delta). Verify with the derived toolkit-structure case
- [x] 1.1 Create `scripts/seed/backlog-README.md` with every statement *A backlog is seeded where none exists* lists (design.md decisions 1–4) (decision 5). Verify by reading it against the requirement's list
- [x] 1.2 In `scripts/project-init`, replace the backlog heredoc with a copy of the seed into `docs/backlog/README.md`; block on the seed's absence only where the backlog concern is outstanding; report a single-file backlog as present in that shape naming `scripts/backlog-migrate`; add a README beside existing entry files (decisions 5, 6). Verify with the derived seeded-backlog cases
- [x] 1.3 In `scripts/project-init`'s seeded workstream README, name `docs/backlog/` in the recorded-status lookup and `waits_on` where it names Waits on. Verify with the derived workstream-register cases

## 2. Converter

- [x] 2.1 Write `scripts/backlog-migrate`: its preconditions and outcomes, the temporary directory moved into place, the seeded README from its own copy (decision 8). Verify with the derived outcome cases
- [x] 2.2 Implement the field mapping, known names and the nothing-dropped rule for all three shapes, and the report. Verify with the derived mapping cases and fixtures of the oldest, middle and current shapes, the current one with the seeded preamble and its fenced example
- [x] 2.3 Dry-run the converter on a scratch copy of each of the eight projects' backlogs (outside every repository, nothing committed) and read each report for text it mapped wrongly or dropped. Verify that every level-2 heading outside fenced code that names an entry has a file, that no file exists for a heading inside a fence, and that the text of each old entry appears in its new file

## 3. Workflow fragment and skills

- [ ] 3.1 In `rules/development-workflow.md`, name `docs/backlog/` wherever `docs/backlog.md` is named, say that its README states the entry rules, and bump `version` to 12 (decision 9). Verify with the derived fragment cases and that `inlined-body-matches-fragment.sh` passes
- [ ] 3.2 Rewrite `skills/backlog/SKILL.md` for the directory: the single-file refusal, record writing one file with names and conditions apart, pick's unwaited and satisfied, close editing frontmatter, sweep, workstreams, and the narrowed *Entries in an older shape*; update the description to name `scripts/backlog-migrate` (decision 7). Verify with the derived skill cases and the trigger fixtures
- [ ] 3.3 Update `skills/backlog/references/audit.md` for entry files, `waits_for` and unknown names. Verify by reading against the audit requirement
- [ ] 3.4 Update `skills/project-init/SKILL.md` where it names the seeded `docs/backlog.md`. Verify by reading

## 4. This repository

- [ ] 4.1 Convert this repository's `docs/backlog.md` with `scripts/backlog-migrate` once its own entries are committed, and act on the report: move into values any text the tool kept as prose that is plainly one. Verify that the report's entry count matches the old entry headings outside fenced code
- [ ] 4.2 Bring `docs/workstreams/README.md` to the seeded text. Verify by diffing it against the seed
- [ ] 4.3 Record `backlog-board` as an entry in `docs/backlog/`, waiting on this change, in the workstream. Verify with the `backlog` skill's record procedure

## 5. Tests and records

- [ ] 5.1 Judge each existing case `test-plan.md` lists as obsolete, and rewrite or retire the cases asserting `docs/backlog.md`. Verify that `bash tests/run.sh` passes
- [ ] 5.2 Deal with every entry under the test plan's *Missing shared arrangement*, promoting into `tests/lib.sh` or keeping with a reason, recorded against the entry
- [ ] 5.3 Account for the modified and added scenarios in `tests/coverage.md`, and describe `scripts/backlog-migrate` and its report in `tests/README.md`

## 6. Verify

- [ ] 6.1 `bash tests/run.sh` passes
- [ ] 6.2 `shellcheck scripts/project-init scripts/backlog-migrate tests/*.sh tests/cases/*.sh tests/cases/lib/*.sh` is clean
- [ ] 6.3 `openspec validate one-file-per-backlog-entry --strict` passes
- [ ] 6.4 Correct the Purpose of `openspec/specs/backlog-maintenance/spec.md`, which names `docs/backlog.md` and which a delta cannot change, to name `docs/backlog/`. Verify by reading
