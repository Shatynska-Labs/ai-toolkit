#!/usr/bin/env bash
# Scenario: A project without a workstream register receives the seeded file
# (delivery half). Requirement: A workstream register is seeded where none
# exists. Change: list-what-a-project-receives (project-bootstrap, MODIFIED).
#
# SPECIFIED: in a target with no docs/workstreams/, docs/workstreams/AGENTS.md
# is created holding the workstreams block and no workstream,
# docs/workstreams/CLAUDE.md holding @AGENTS.md, no archive/ directory is
# created, and the report states the register was created.
# DERIVED (token): `workstreams: created` (tests/README.md).
# DERIVED (operationalisation of "no workstream", carried from
# workstreams-seeded-new-project.sh): outside fenced code the block carries
# one heading at most, and docs/workstreams/ holds AGENTS.md and CLAUDE.md
# alone.
# NOT HERE: the statements the block carries — the existing
# workstreams-seeded-*.sh and workstreams-dir-*.sh cases, re-anchored per
# test-plan.md's obsolete list, and workstreams-block-reserved-names.sh.
#
# Executes the tool. Red until tasks 1.1 and 2.3 land (state 2).
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
mkdir -p "$work"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"
f="$work/docs/workstreams/AGENTS.md"
[ -n "$(marker_line "$f" workstreams)" ] || { echo "FAIL: docs/workstreams/AGENTS.md holds no workstreams block" >&2; exit 1; }
holds_import "$work/docs/workstreams/CLAUDE.md" || { echo "FAIL: docs/workstreams/CLAUDE.md does not hold @AGENTS.md" >&2; exit 1; }
assert_file_absent "$work/docs/workstreams/archive" "no archive/ directory is created"
# shellcheck disable=SC2012 # names are the test's own fixture names, plain ASCII
[ "$(ls -A "$work/docs/workstreams" | sort | tr '\n' ' ')" = "AGENTS.md CLAUDE.md " ] || { echo "FAIL: docs/workstreams/ holds more than AGENTS.md and CLAUDE.md:" >&2; ls -A "$work/docs/workstreams" >&2; exit 1; }
assert_contains "$TESTDIR/report.txt" "workstreams: created" "the report states the register was created"
block_body "$f" workstreams > "$TESTDIR/block.md"
fences="$(grep -c -E '^[[:space:]]*(```|~~~)' "$TESTDIR/block.md")"
[ $((fences % 2)) -eq 0 ] || { echo "FAIL: the block has unbalanced fences; the no-workstream scan cannot be read" >&2; exit 1; }
count="$(awk '/^[[:space:]]*(```|~~~)/ { infence = !infence; next } !infence && /^#/ { n++ } END { print n + 0 }' "$TESTDIR/block.md")"
[ "$count" -le 1 ] || { echo "FAIL: outside fenced code the block carries $count headings; it SHALL contain no workstream" >&2; exit 1; }
