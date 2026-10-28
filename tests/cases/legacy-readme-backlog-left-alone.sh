#!/usr/bin/env bash
# Scenario: A backlog README is left alone.
# Requirement: A directory holding its rules in a README is reported, not
# converted. Change: list-what-a-project-receives (project-bootstrap, ADDED).
#
# SPECIFIED: where docs/backlog/ holds README.md and entry files and no
# AGENTS.md, no AGENTS.md or CLAUDE.md is created in it, every file in it is
# unchanged, and the report states the backlog's rules are in the shape
# before 1.0.0.
# DERIVED (token): read as the `backlog:` line naming `1.0.0`.
#
# Executes the tool. Red until task 2.3 lands (state 1: the backlog is
# reported already present).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work/docs/backlog"
printf '# Backlog\n\nOur rules, as seeded before 1.0.0.\n' > "$work/docs/backlog/README.md"
printf -- '---\npriority: normal\nkind: fix\n---\n\nAn entry.\n' > "$work/docs/backlog/some-entry.md"
before="$(cd "$work/docs/backlog" && md5sum README.md some-entry.md)"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
assert_file_absent "$work/docs/backlog/AGENTS.md" "no AGENTS.md beside the README"
assert_file_absent "$work/docs/backlog/CLAUDE.md" "no CLAUDE.md beside the README"
[ "$(cd "$work/docs/backlog" && md5sum README.md some-entry.md)" = "$before" ] || { echo "FAIL: a file in docs/backlog/ changed" >&2; exit 1; }
# shellcheck disable=SC2012 # names are the test's own fixture names, plain ASCII
[ "$(ls -A "$work/docs/backlog" | sort | tr '\n' ' ')" = "README.md some-entry.md " ] || { echo "FAIL: docs/backlog/ gained a file" >&2; ls -A "$work/docs/backlog" >&2; exit 1; }
grep -E '^backlog:' "$TESTDIR/report.txt" | grep -q -F '1.0.0' || { echo "FAIL: the backlog line does not state the rules are in the shape before 1.0.0" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
