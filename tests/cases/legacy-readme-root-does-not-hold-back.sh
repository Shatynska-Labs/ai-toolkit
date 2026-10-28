#!/usr/bin/env bash
# Scenario: A root README does not hold back the workflow block.
# Requirement: A directory holding its rules in a README is reported, not
# converted. Change: list-what-a-project-receives (project-bootstrap, ADDED).
#
# SPECIFIED: where the project root holds README.md and no AGENTS.md, the root
# AGENTS.md is created with the workflow block; the root README is left as
# it was ("files the project already owns are never overwritten").
#
# Executes the tool. Red until task 2.2 lands (state 1: the marker carries no
# hash).
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
mkdir -p "$work"
printf '# Our project\n\nWhat it is.\n' > "$work/README.md"
sum="$(md5sum "$work/README.md" | awk '{print $1}')"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"
assert_file "$work/AGENTS.md" "the root AGENTS.md is created"
[ -n "$(marker_line "$work/AGENTS.md" development-workflow)" ] || { echo "FAIL: the root AGENTS.md has no workflow block with a version and hash" >&2; exit 1; }
assert_unchanged "$work/README.md" "$sum" "the root README is left"
