## 1. Fragments and the manifest

- [ ] 1.1 Create `rules/backlog.md` from `scripts/seed/backlog-README.md` and `rules/workstreams.md` from `scripts/project-init`'s workstreams heredoc, each with `kind: standing-constraint` and `version: 1.0.0`, reading "this README" as "this file", and add the statement that `readme`, `agents` and `claude` are not entry (or workstream) names; verify each body differs from its source only there
- [ ] 1.2 Set every fragment's `version` to `1.0.0` (`development-workflow`, `development-workflow-database`, `test-plan`) and add `rules/manifest` with the three records of design.md decision 1; verify with the derived manifest cases
- [ ] 1.3 In `rules/development-workflow.md`, replace every reference to a directory's README (four, on three lines) with its `AGENTS.md`; verify the "fragment defers" cases
- [ ] 1.4 Remove `scripts/seed/`; verify `grep -rn 'scripts/seed' scripts skills rules AGENTS.md` finds nothing

## 2. project-init

- [ ] 2.1 Read `rules/manifest` and validate every fragment it lists (`kind`, semantic `version`) before any write, blocking on a missing or invalid one; verify with the derived blocking cases
- [ ] 2.2 Generalise `build_block` to a manifest record: the marker with name, version and SHA-256 hash (via `sha256sum` or `shasum -a 256`, blocking where neither exists and a block is outstanding), the notice ending "outside the markers", the body; read an existing block's version from either marker form; verify with the derived marker cases
- [ ] 2.3 Write each record into its target: the root `AGENTS.md` by its existing rules; a directory target per design.md decisions 4–6 (link or non-directory refused, legacy README reported, block appended or file created, directory `CLAUDE.md` created where absent or reported); keep the single-file backlog check on the `backlog` record; verify with the derived seeding cases
- [ ] 2.4 Update `--help`, the report lines and the header comment for the blocks and directory files; verify `--help` names every block the manifest lists

## 3. backlog-migrate, the backlog skill and documentation

- [ ] 3.1 `scripts/backlog-migrate`: stop writing the README, drop the seed precondition, block entries named `agents` or `claude`, and report that the `project-init` beside it writes the rules; verify with the derived migrate cases
- [ ] 3.2 `skills/backlog/SKILL.md`: read each directory's rules from its `AGENTS.md`, falling back to `README.md` where it holds no block, count neither file nor `CLAUDE.md` as an entry, and refuse `agents` and `claude` in record's name check beside `readme`; reword the description's "seeding either README"; verify with the derived skill cases
- [ ] 3.3 `skills/project-init/SKILL.md`: its description names the blocks and directory files rather than "a seeded `docs/backlog/` README"
- [ ] 3.4 `AGENTS.md` (Reaching a project; Three categories, where the `scripts/seed/` paragraph becomes the statement that every rule text written into a project is a fragment the manifest lists, the ignore file and a directory's `CLAUDE.md` line excepted) and `rules/README.md` (fragment frontmatter, semantic version, the manifest as a delivery list, not an index); verify the documentation cases
- [ ] 3.5 `.claude-plugin/plugin.json` version `0.2.0` → `1.0.0`

## 4. This repository's own directories

- [ ] 4.1 Replace `docs/backlog/README.md` and `docs/workstreams/README.md` with the blocks `project-init` writes and a `CLAUDE.md` holding `@AGENTS.md` in each; verify each block's hash matches its contents and its body matches the fragment

## 5. Tests and records

- [ ] 5.1 Revise the existing cases the test plan lists as obsolete — those naming `docs/*/README.md`, `scripts/seed/`, the `vN` marker or the seed precondition — changing only what the delta replaced
- [ ] 5.2 Account for the added, modified and removed requirements and scenarios in `tests/coverage.md`

## 6. Verify

- [ ] 6.1 `bash tests/run.sh` passes
- [ ] 6.2 `shellcheck scripts/project-init scripts/backlog-migrate tests/*.sh tests/cases/*.sh tests/cases/lib/*.sh` is clean
- [ ] 6.3 `openspec validate list-what-a-project-receives --strict` passes
- [ ] 6.4 Run `scripts/project-init` in a scratch directory and in a scratch copy of commerce-ops: the first receives three blocks and two directory `CLAUDE.md` files; the second reports both READMEs as the shape before `1.0.0`, the `v12` block present, and writes nothing
