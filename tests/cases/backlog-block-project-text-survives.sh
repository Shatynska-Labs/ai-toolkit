#!/usr/bin/env bash
# Scenario: Project text beside the block survives.
# Requirements: The backlog's rules are written where none exist (ADDED);
# Files the project already owns are never overwritten (MODIFIED: the
# exception covers each AGENTS.md the manifest names).
# Change: list-what-a-project-receives (project-bootstrap).
#
# SPECIFIED: where docs/backlog/AGENTS.md holds text of the project's own and
# no backlog block, the block is appended, and every line the file held
# before is unchanged.
# DERIVED (operationalisation): "appended" and "every line unchanged" are read
# together as the file beginning with its former bytes.
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
mkdir -p "$work/docs/backlog"
f="$work/docs/backlog/AGENTS.md"
printf '# Our backlog notes\n\nTag every entry with its owner.\n' > "$f"
cp "$f" "$TESTDIR/before.md"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"
[ -n "$(marker_line "$f" backlog)" ] || { echo "FAIL: the backlog block was not appended" >&2; exit 1; }
n="$(wc -c < "$TESTDIR/before.md")"
head -c "$n" "$f" | cmp -s - "$TESTDIR/before.md" || { echo "FAIL: the project's own text did not survive as the file's start" >&2; head -n 5 "$f" >&2; exit 1; }
