#!/usr/bin/env bash
# Scenario: A project without a backlog receives the seeded file (delivery
# half). Requirement: The backlog's rules are written where none exist.
# Change: list-what-a-project-receives (project-bootstrap, ADDED; replaces
# the removed "A backlog is seeded where none exists").
#
# SPECIFIED: in a target with neither docs/backlog/ nor docs/backlog.md,
# docs/backlog/AGENTS.md is created holding the backlog block,
# docs/backlog/CLAUDE.md holding @AGENTS.md, no entry file is created, and
# the report states the backlog was created; in both the new-project and the
# adoption mode.
# DERIVED (token): `backlog: created` is tests/README.md's report line.
# DERIVED (operationalisation): "no entry file" is docs/backlog/ holding
# AGENTS.md and CLAUDE.md alone; the two modes are compared byte for byte, as
# backlog-dir-seeded-adoption.sh did for the README.
# NOT HERE: the statements the block carries — the existing
# backlog-dir-seeded-*.sh cases, re-anchored per test-plan.md's obsolete
# list, and backlog-block-reserved-names.sh.
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
f="$work/docs/backlog/AGENTS.md"
[ -n "$(marker_line "$f" backlog)" ] || { echo "FAIL: docs/backlog/AGENTS.md holds no backlog block" >&2; exit 1; }
[ "$(grep -c -F '<!-- ai-toolkit:backlog ' "$f")" -eq 1 ] || { echo "FAIL: docs/backlog/AGENTS.md holds more than one backlog block" >&2; exit 1; }
holds_import "$work/docs/backlog/CLAUDE.md" || { echo "FAIL: docs/backlog/CLAUDE.md does not hold @AGENTS.md" >&2; exit 1; }
# shellcheck disable=SC2012 # names are the test's own fixture names, plain ASCII
[ "$(ls -A "$work/docs/backlog" | sort | tr '\n' ' ')" = "AGENTS.md CLAUDE.md " ] || { echo "FAIL: docs/backlog/ holds more than AGENTS.md and CLAUDE.md:" >&2; ls -A "$work/docs/backlog" >&2; exit 1; }
assert_file_absent "$work/docs/backlog.md" "no single file is written"
assert_contains "$TESTDIR/report.txt" "backlog: created" "the report states the backlog was created"

adopt="$TESTDIR/adopt"
mkdir -p "$adopt"
git -C "$adopt" init -q
git -C "$adopt" config user.email t@t.com
git -C "$adopt" config user.name t
echo "print('hi')" > "$adopt/main.py"
git -C "$adopt" add . && git -C "$adopt" commit -q -m history
(cd "$adopt" && bash "$PROJECT_INIT") >"$TESTDIR/report-adopt.txt" 2>&1
assert_exit 0 "$?" "adoption"
cmp -s "$f" "$adopt/docs/backlog/AGENTS.md" || { echo "FAIL: the adoption-mode docs/backlog/AGENTS.md differs from the new-project one" >&2; exit 1; }
holds_import "$adopt/docs/backlog/CLAUDE.md" || { echo "FAIL: adoption — docs/backlog/CLAUDE.md does not hold @AGENTS.md" >&2; exit 1; }
