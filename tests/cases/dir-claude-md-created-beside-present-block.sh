#!/usr/bin/env bash
# Scenario: A CLAUDE.md created beside a present block is reported.
# Requirement: A directory's rules block is imported by a CLAUDE.md beside it.
# Change: list-what-a-project-receives (project-bootstrap, ADDED).
#
# SPECIFIED: where docs/backlog/AGENTS.md holds the backlog block and
# docs/backlog/CLAUDE.md is absent, the report states the backlog present,
# CLAUDE.md is created holding @AGENTS.md, and the report states on its own
# line that it was created; the block's file is left unchanged.
# DERIVED (fixture): the present block is the one a first run wrote, its
# CLAUDE.md then removed. DERIVED (tokens): "present" is a `backlog:` line
# saying `already present` (tests/README.md); the creation is a line naming
# docs/backlog/CLAUDE.md and `created` that is not the `backlog:` line.
#
# Executes the tool. Red until task 2.3 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Local arrangement (test-plan.md, Missing shared arrangement:
# holds_import). holds_import FILE: FILE holds exactly the one line @AGENTS.md.
holds_import() {
  [ -f "$1" ] && [ ! -L "$1" ] && [ "$(cat "$1")" = "@AGENTS.md" ] && [ "$(grep -c '' "$1")" -eq 1 ]
}

work="$TESTDIR/work"
mkdir -p "$work"
(cd "$work" && bash "$PROJECT_INIT") >/dev/null 2>&1
assert_exit 0 "$?" "the first run"
assert_file "$work/docs/backlog/AGENTS.md" "target absent — the first run wrote no docs/backlog/AGENTS.md"
rm -f "$work/docs/backlog/CLAUDE.md"
sum="$(md5sum "$work/docs/backlog/AGENTS.md" | awk '{print $1}')"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"
assert_unchanged "$work/docs/backlog/AGENTS.md" "$sum" "the present block is left"
holds_import "$work/docs/backlog/CLAUDE.md" || { echo "FAIL: docs/backlog/CLAUDE.md was not created holding @AGENTS.md" >&2; exit 1; }
grep -q -E '^backlog:.*already present' "$TESTDIR/report.txt" || { echo "FAIL: the report does not state the backlog present" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
grep -F 'docs/backlog/CLAUDE.md' "$TESTDIR/report.txt" | grep -v -E '^backlog:' | grep -q -i 'created' \
  || { echo "FAIL: no report line of its own states docs/backlog/CLAUDE.md was created" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
