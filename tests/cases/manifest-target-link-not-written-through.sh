#!/usr/bin/env bash
# Scenario: A link at a target is not written through.
# Requirement: A project receives exactly the blocks the manifest lists.
# Change: list-what-a-project-receives (project-bootstrap, ADDED).
#
# SPECIFIED: where docs/workstreams/AGENTS.md is a symbolic link, nothing is
# written at or through it, the report states it is not a path the tool
# writes into, and the other blocks are written. "Write nothing for that
# record" is read to cover the record's CLAUDE.md as well.
# DERIVED (token): the statement is read as a report line naming
# docs/workstreams and saying `not`; its wording is not fixed by the spec.
# DELIBERATELY UNTESTED: the run's outcome and exit code, which the spec does
# not state for a refused record.
#
# Executes the tool. Red until task 2.3 lands (state 1 or 2).
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
mkdir -p "$work/docs/workstreams" "$TESTDIR/outside"
outside="$TESTDIR/outside/rules.md"
printf 'outside text\n' > "$outside"
sum="$(md5sum "$outside" | awk '{print $1}')"
ln -s "$outside" "$work/docs/workstreams/AGENTS.md"

(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
if [ ! -L "$work/docs/workstreams/AGENTS.md" ] || [ "$(readlink "$work/docs/workstreams/AGENTS.md")" != "$outside" ]; then
  echo "FAIL: the link at docs/workstreams/AGENTS.md changed" >&2; exit 1
fi
assert_unchanged "$outside" "$sum" "nothing written through the link"
assert_file_absent "$work/docs/workstreams/CLAUDE.md" "nothing written for the refused record"
grep -i 'docs/workstreams' "$TESTDIR/report.txt" | grep -q -i -E '(^|[^a-z])not([^a-z]|$)' \
  || { echo "FAIL: the report does not state docs/workstreams/AGENTS.md is not a path the tool writes into" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
[ -n "$(marker_line "$work/AGENTS.md" development-workflow)" ] || { echo "FAIL: the workflow block was not written" >&2; exit 1; }
[ -n "$(marker_line "$work/docs/backlog/AGENTS.md" backlog)" ] || { echo "FAIL: the backlog block was not written" >&2; exit 1; }
