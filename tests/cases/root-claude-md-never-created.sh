#!/usr/bin/env bash
# Scenario: The root CLAUDE.md is never created.
# Requirement: A directory's rules block is imported by a CLAUDE.md beside it.
# Change: list-what-a-project-receives (project-bootstrap, ADDED).
#
# SPECIFIED: run in a directory with no CLAUDE.md, no CLAUDE.md is created at
# the project root, while docs/backlog/CLAUDE.md and
# docs/workstreams/CLAUDE.md are.
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
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"
assert_file_absent "$work/CLAUDE.md" "the root CLAUDE.md is never created"
for d in backlog workstreams; do
  holds_import "$work/docs/$d/CLAUDE.md" || { echo "FAIL: docs/$d/CLAUDE.md was not created holding @AGENTS.md" >&2; exit 1; }
done
