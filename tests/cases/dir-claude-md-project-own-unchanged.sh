#!/usr/bin/env bash
# Scenario: A directory CLAUDE.md of the project's own is not written.
# Requirement: A directory's rules block is imported by a CLAUDE.md beside it.
# Change: list-what-a-project-receives (project-bootstrap, ADDED).
#
# SPECIFIED: where docs/workstreams/CLAUDE.md holds other text and no
# @AGENTS.md, it is byte-for-byte unchanged, and the report states that
# @AGENTS.md must be added to it.
# SPECIFIED (A workstream register is seeded where none exists): the
# directory holds neither block nor README, so the block is written into
# docs/workstreams/AGENTS.md.
# DERIVED (token): the statement is read as a report line naming
# docs/workstreams/CLAUDE.md and @AGENTS.md.
#
# Executes the tool. Red until task 2.3 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Local arrangement (test-plan.md, Missing shared arrangement: block readers).
# block_body FILE NAME: the lines strictly between NAME's opening and closing
# markers, each with its newline.
block_body() {
  awk -v n="$2" '
    index($0, "<!-- /ai-toolkit:" n " -->") == 1 { exit }
    f { print }
    index($0, "<!-- ai-toolkit:" n " ") == 1 { f = 1 }
  ' "$1"
}
# marker_line FILE NAME: NAME's opening line in the form
# `<!-- ai-toolkit:NAME MAJOR.MINOR.PATCH sha256:<64 hex> -->`, or nothing.
marker_line() {
  grep -E "^<!-- ai-toolkit:$2 [0-9]+[.][0-9]+[.][0-9]+ sha256:[0-9a-f]{64} -->\$" "$1" 2>/dev/null
}

work="$TESTDIR/work"
mkdir -p "$work/docs/workstreams"
printf '# Notes of our own\n\nRead the plan first.\n' > "$work/docs/workstreams/CLAUDE.md"
sum="$(md5sum "$work/docs/workstreams/CLAUDE.md" | awk '{print $1}')"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"
assert_unchanged "$work/docs/workstreams/CLAUDE.md" "$sum" "the project's own CLAUDE.md is not written"
[ -n "$(marker_line "$work/docs/workstreams/AGENTS.md" workstreams)" ] || { echo "FAIL: the workstreams block was not written into docs/workstreams/AGENTS.md" >&2; exit 1; }
grep -F 'docs/workstreams/CLAUDE.md' "$TESTDIR/report.txt" | grep -q -F '@AGENTS.md' \
  || { echo "FAIL: the report does not state that @AGENTS.md must be added to docs/workstreams/CLAUDE.md" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
