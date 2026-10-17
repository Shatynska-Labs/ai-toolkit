#!/usr/bin/env bash
# Scenario: A project without a backlog receives the seeded file (adoption
# mode). Change: seed-the-backlog.
#
# SPECIFIED: "in both the new-project and the adoption mode, creating `docs/`
# if absent". An existing repository with history and no `docs/` receives the
# file, and the report states it was created.
#
# DERIVED: the seeded text is the same in both modes. The requirement states
# the same six statements for every created file and names no per-mode
# variant; asserting byte-identity against a new-project run is the cheapest
# way to carry every statement check over without restating it here.
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
status=$?

assert_exit 0 "$status"
assert_file "$work/docs/backlog.md" "adoption creates the backlog, with docs/ created for it"
assert_contains "$report" "backlog: created" "the report states the backlog was created"

fresh="$TESTDIR/fresh"
mkdir -p "$fresh"
(cd "$fresh" && bash "$PROJECT_INIT" >/dev/null 2>&1)
assert_file "$fresh/docs/backlog.md" "the new-project run this case compares against"
if ! cmp -s "$fresh/docs/backlog.md" "$work/docs/backlog.md"; then
  echo "FAIL: the adoption-mode backlog differs from the new-project one" >&2
  diff "$fresh/docs/backlog.md" "$work/docs/backlog.md" >&2
  exit 1
fi
