#!/usr/bin/env bash
# Scenario: The rules are added beside existing entries.
# Requirement: The backlog's rules are written where none exist.
# Change: list-what-a-project-receives (project-bootstrap, ADDED; replaces
# the removed scenario "A README is added beside existing entries").
#
# SPECIFIED: where docs/backlog/ holds entry files and neither AGENTS.md nor
# README.md, AGENTS.md holding the block and CLAUDE.md holding @AGENTS.md are
# created, and every entry file is byte-for-byte unchanged; the report states
# the rules written beside existing entries.
# DERIVED (token): a `backlog:` line saying `beside` (tests/README.md's
# `created beside existing entries`).
#
# Executes the tool. Red until task 2.3 lands (state 1: a README is written).
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

# Local arrangement (test-plan.md, Missing shared arrangement:
# holds_import). holds_import FILE: FILE holds exactly the one line @AGENTS.md.
holds_import() {
  [ -f "$1" ] && [ ! -L "$1" ] && [ "$(cat "$1")" = "@AGENTS.md" ] && [ "$(grep -c '' "$1")" -eq 1 ]
}

work="$TESTDIR/work"
mkdir -p "$work/docs/backlog"
printf -- '---\npriority: normal\nkind: fix\n---\n\nThe first.\n' > "$work/docs/backlog/first-entry.md"
printf -- '---\nkind: change\n---\n\nThe second.\n' > "$work/docs/backlog/second-entry.md"
before="$(cd "$work/docs/backlog" && md5sum first-entry.md second-entry.md)"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"
[ -n "$(marker_line "$work/docs/backlog/AGENTS.md" backlog)" ] || { echo "FAIL: no backlog block in docs/backlog/AGENTS.md" >&2; exit 1; }
holds_import "$work/docs/backlog/CLAUDE.md" || { echo "FAIL: docs/backlog/CLAUDE.md does not hold @AGENTS.md" >&2; exit 1; }
assert_file_absent "$work/docs/backlog/README.md" "no README is written"
[ "$(cd "$work/docs/backlog" && md5sum first-entry.md second-entry.md)" = "$before" ] || { echo "FAIL: an entry file changed" >&2; exit 1; }
grep -E '^backlog:' "$TESTDIR/report.txt" | grep -q 'beside' || { echo "FAIL: the backlog line does not state the rules written beside existing entries" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
