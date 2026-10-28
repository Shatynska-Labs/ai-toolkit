## 1. The update tool

- [x] 1.1 Create `scripts/project-update` with `--help`, the target argument, the target line, the three outcomes and exit codes, self-location, and the manifest and fragment validation copied from `scripts/project-init`; block where neither `sha256sum` nor `shasum` exists; verify with the derived interface and outcome cases
- [x] 1.2 Classify each manifest record into the states of design.md decision 2, in order — marker parsing in either form, the hash recomputed over the lines between the markers, numeric version comparison; verify with the derived classification cases
- [x] 1.3 Replace a `stale` block per decision 3: the block built as `project-init` builds it, every line outside the markers kept, written through a root `AGENTS.md` link, mode kept; verify with the derived replacement cases, including the comparison with `project-init`'s block under both hash commands, the presence-agreement case and the second run
- [x] 1.4 Report an `edited` block with its indented `diff -u` and leave it, and leave `ahead`, `malformed` and `not writable` records; verify with the derived cases
- [x] 1.5 Check decision 4's git preconditions before any write where a record is legacy, resolving a root `AGENTS.md` link to the file it names; then convert a `legacy block` and a `legacy README` (block written into the directory's `AGENTS.md`, its `CLAUDE.md` handled as `project-init` handles it, then README removed); verify with the derived conversion and blocking cases
- [x] 1.6 Name `project-init` for `absent` and `backlog-migrate` for `single file`, and print the `Attention:` line; verify with the derived cases

## 2. project-init and documentation

- [x] 2.1 `scripts/project-init`: the two "out of scope" report lines name `scripts/project-update`, or state a block ahead of the toolkit, by numeric version comparison (design.md decision 8); `--help` names it; verify with the derived cases
- [x] 2.2 `tests/README.md`: the suite exercises `scripts/project-update` too, with its CLI and report contract (design.md decision 7); `project-init`'s two revised lines
- [x] 2.3 `AGENTS.md` (Reaching a project) and `rules/README.md`: `scripts/project-update` reads the fragments the manifest lists and brings a project's blocks current; `skills/project-init/SKILL.md` where it relays a block at another version or a legacy README

## 3. Tests and records

- [x] 3.1 Revise the existing cases the change's `test-plan.md` (written when tests are derived) lists as obsolete — `managed-block-older-version.sh`, its "out of scope" assertion — changing only what the delta replaced
- [x] 3.2 Account for the added and modified requirements and scenarios in `tests/coverage.md`

## 4. Verify

- [x] 4.1 `bash tests/run.sh` passes
- [x] 4.2 `shellcheck scripts/project-init scripts/project-update scripts/backlog-migrate tests/*.sh tests/cases/*.sh tests/cases/lib/*.sh` is clean
- [x] 4.3 `openspec validate update-managed-block --strict` passes
- [x] 4.4 Run `scripts/project-update` in a scratch clone of each adopting project (`fuperia/commerce-ops`, `fuperia/infrastructure`, `shatynska/basis`, `shatynska/infrastructure`, `infrastructure-template`) and read each report and `git diff`: the `v12`/`v10` block and the READMEs converted, project text outside the markers unchanged; a second run reports every block current
