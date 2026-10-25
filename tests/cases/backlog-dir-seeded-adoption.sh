#!/usr/bin/env bash
# Scenario: A project without a backlog receives the seeded file (adoption
# mode). Requirement: A backlog is seeded where none exists.
# Change: one-file-per-backlog-entry (project-bootstrap, MODIFIED).
#
# SPECIFIED: in an existing repository with history and neither docs/backlog/
# nor docs/backlog.md, docs/backlog/README.md is created "in both the
# new-project and the adoption mode", the report states it was created, and
# no entry file is created. The README is the same text the new-project run
# seeds (one seed, scripts/seed/backlog-README.md), so the statements
# backlog-dir-seeded-new-project.sh reads hold here too.
# DERIVED (token): `backlog: created` (tests/README.md report contract).
#
# Executes the tool; red until tasks 1.1 and 1.2 land (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
git init -q
git config user.email "t@t.com"
git config user.name "t"
echo "print('hi')" > main.py
git add . && git commit -q -m "initial history"

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
assert_exit 0 "$?"
assert_file "$work/docs/backlog/README.md" "adoption creates the README, with docs/ and docs/backlog/ created for it"
assert_file_absent "$work/docs/backlog.md" "no single file is seeded"
assert_contains "$report" "backlog: created" "the report states the backlog was created"
[ "$(ls -A "$work/docs/backlog")" = "README.md" ] || { echo "FAIL: docs/backlog/ holds more than the README" >&2; exit 1; }

fresh="$TESTDIR/fresh"
mkdir -p "$fresh"
(cd "$fresh" && bash "$PROJECT_INIT") >/dev/null 2>&1
assert_file "$fresh/docs/backlog/README.md" "the new-project run this case compares against"
if ! cmp -s "$fresh/docs/backlog/README.md" "$work/docs/backlog/README.md"; then
  echo "FAIL: the adoption-mode README differs from the new-project one" >&2
  diff "$fresh/docs/backlog/README.md" "$work/docs/backlog/README.md" >&2
  exit 1
fi
