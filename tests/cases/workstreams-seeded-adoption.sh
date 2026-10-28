#!/usr/bin/env bash
# Scenario: A project without a workstream register receives the seeded file
# (adoption mode). Requirement: A workstream register is seeded where none
# exists. Change: add-workstreams (project-bootstrap, ADDED).
#
# SPECIFIED: "in both the new-project and the adoption mode, creating
# `docs/workstreams/` if absent". An existing repository with history and an
# existing `docs/` (holding a backlog of its own) but no `docs/workstreams/`
# receives the file, the report states it was created, and the existing
# backlog is untouched.
# DERIVED: the seeded text is the same in both modes. The requirement names
# no per-mode variant, so byte-identity with a new-project run carries every
# statement check over without restating it.
#
# Executes the tool; no fixture owed. Red until the concern lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work/docs"
cd "$work" || exit 1
git init -q
git config user.email "t@t.com"
git config user.name "t"
printf '# Backlog\n\nA project'"'"'s own backlog.\n' > docs/backlog.md
echo "print('hi')" > main.py
git add . && git commit -q -m "initial history"
sum_backlog="$(md5sum docs/backlog.md | awk '{print $1}')"

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_file "$work/docs/workstreams/AGENTS.md" "adoption creates the register, with docs/workstreams/ created for it"
assert_contains "$report" "workstreams: created" "the report states the register was created"
assert_file_absent "$work/docs/workstreams/archive" "no archive/ directory is created"
assert_unchanged "$work/docs/backlog.md" "$sum_backlog" "the project's own backlog is untouched"

fresh="$TESTDIR/fresh"
mkdir -p "$fresh"
(cd "$fresh" && bash "$PROJECT_INIT" >/dev/null 2>&1)
assert_file "$fresh/docs/workstreams/AGENTS.md" "the new-project run this case compares against"
if ! cmp -s "$fresh/docs/workstreams/AGENTS.md" "$work/docs/workstreams/AGENTS.md"; then
  echo "FAIL: the adoption-mode register differs from the new-project one" >&2
  diff "$fresh/docs/workstreams/AGENTS.md" "$work/docs/workstreams/AGENTS.md" >&2
  exit 1
fi
