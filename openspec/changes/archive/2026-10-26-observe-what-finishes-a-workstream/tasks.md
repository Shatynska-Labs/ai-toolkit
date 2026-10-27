## 1. Seeded text

- [x] 1.1 In `scripts/project-init`'s seeded workstream README, replace the shape's Done when line with design.md decision 1's, and add decision 2's paragraph immediately before the archive paragraph. Verify with the derived cases
- [x] 1.2 Bring this repository's `docs/workstreams/README.md` to the seeded text. Verify by diffing it against the heredoc

## 2. Records

- [x] 2.1 Account for the modified and added scenarios in `tests/coverage.md`

## 3. Verify

- [x] 3.1 `bash tests/run.sh` passes
- [x] 3.2 `shellcheck scripts/project-init tests/*.sh tests/cases/*.sh tests/cases/lib/*.sh` is clean
- [x] 3.3 `openspec validate observe-what-finishes-a-workstream --strict` passes
