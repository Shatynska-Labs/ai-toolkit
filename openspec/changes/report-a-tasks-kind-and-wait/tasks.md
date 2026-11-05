## 1. Rules

- [x] 1.1 In `rules/backlog.md`, add `need` after `kind` and `waits_for_type` after `waits_for` with design.md decisions 1 and 2's text, add the short-condition sentence to `waits_for`, add `need: should` and `waits_for_type` to the example's frontmatter, and **Need** to the body's reasons and to the example's list worded as its **Priority** item is ("on a `must` or `could` entry only, why"), and raise `version` to `1.2.0`. Verify with the derived cases and the `backlog-dir-seeded-*` cases
- [x] 1.2 Add a `backlog` record at `1.2.0` to `rules/changelog`, with no `ask` (decision 3). Verify that `scripts/project-update` does not block on it

## 2. Skill

- [x] 2.1 In `skills/backlog/SKILL.md`, add **Need** to **record** and the type to **Waits** (decision 4), the need order to **pick** (decision 5), and the two readings to *Entries missing a key* (decision 7). Verify with the `backlog-skill-*` cases
- [x] 2.2 In `skills/backlog/references/audit.md`, extend the brief's **Waits for** item and the report's **Stale facts** (decision 6). Verify by reading both against the delta

## 3. Tool

- [x] 3.1 In `scripts/task-board`, read `kind`, `need`, `waits_for`, `waits_for_type` and `parked_until` from an entry's frontmatter, unquoting free text
- [x] 3.2 Add the seven fields to the JSON task in the order decision 8 gives, deriving `waits_on_done` and `readiness` from `status()` counting a name done exactly where `status()` says so, and warning of a name not done that a partial forge read could have missed. Verify with the derived `task-board-json-*` cases
- [x] 3.3 Show kind, need, done names, the warning for a named wait not checked and the typed condition on the page's task row (decision 9). Verify with the derived `task-board-*` cases and that every value is escaped

## 4. Records

- [x] 4.1 Raise `.claude-plugin/plugin.json` to `2.3.0`. Verify with `plugin-version-rise-checks-this-repository.sh`
- [x] 4.2 Bring this repository's `docs/backlog/AGENTS.md` current by running `scripts/project-update` against it. Verify that the marker names `1.2.0` and nothing outside the block changed
- [x] 4.3 Account for the added and modified scenarios in `tests/coverage.md`, and retire any assertion the test plan lists as obsolete. Verify that every scenario has a row

## 5. Verify

- [x] 5.1 `bash tests/run.sh` passes
- [x] 5.2 `shellcheck` is clean on every test this change adds or modifies
- [x] 5.3 `openspec validate report-a-tasks-kind-and-wait --strict` passes
