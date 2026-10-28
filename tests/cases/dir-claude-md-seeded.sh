#!/usr/bin/env bash
# Scenario: A seeded directory gets its import.
# Requirement: A directory's rules block is imported by a CLAUDE.md beside it.
# Change: list-what-a-project-receives (project-bootstrap, ADDED).
#
# SPECIFIED: once the tool writes the backlog block into a new
# docs/backlog/AGENTS.md, docs/backlog/CLAUDE.md exists holding exactly the
# line @AGENTS.md; likewise for docs/workstreams/ (the requirement covers any
# AGENTS.md other than the root's).
# SPECIFIED (requirement text): a CLAUDE.md holding @AGENTS.md is left
# unchanged and nothing is said of it — read on a second run, whose report
# names neither directory's CLAUDE.md.
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
for d in backlog workstreams; do
  assert_file "$work/docs/$d/AGENTS.md" "the $d block's file"
  holds_import "$work/docs/$d/CLAUDE.md" || { echo "FAIL: docs/$d/CLAUDE.md does not hold exactly the line @AGENTS.md" >&2; cat "$work/docs/$d/CLAUDE.md" >&2 2>/dev/null; exit 1; }
done
s1="$(md5sum "$work/docs/backlog/CLAUDE.md" | awk '{print $1}')"
s2="$(md5sum "$work/docs/workstreams/CLAUDE.md" | awk '{print $1}')"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report2.txt" 2>&1
assert_exit 0 "$?"
assert_unchanged "$work/docs/backlog/CLAUDE.md" "$s1" "an importing CLAUDE.md is left"
assert_unchanged "$work/docs/workstreams/CLAUDE.md" "$s2" "an importing CLAUDE.md is left"
if grep -E 'docs/(backlog|workstreams)/CLAUDE[.]md' "$TESTDIR/report2.txt" >&2; then
  echo "FAIL: the report speaks of a directory CLAUDE.md that already imports AGENTS.md" >&2
  exit 1
fi
