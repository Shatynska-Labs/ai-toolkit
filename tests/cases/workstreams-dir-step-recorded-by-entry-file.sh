#!/usr/bin/env bash
# Scenario: A step is recorded by its entry file.
# Requirement: A workstream register is seeded where none exists.
# Change: one-file-per-backlog-entry (project-bootstrap, MODIFIED).
#
# SPECIFIED: the seeded docs/workstreams/AGENTS.md states that a step is
# recorded where docs/backlog/ holds an entry of the step's name, and does
# not name docs/backlog.md.
# DERIVED (operationalisation): a sentence carries `recorded` and
# `docs/backlog/`.
#
# Executes the tool; every scan is discriminated on the fixture. Red until
# task 1.3 lands (state 1: the current register names docs/backlog.md).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

W=docs/workstreams/AGENTS.md
scan require "$W" "" recorded-in-directory 'recorded[^.]*docs/backlog/'
# shellcheck disable=SC2016 # backticks are literal markdown in the specimen
scan forbid "$W" "" no-single-file 'docs/backlog[.]md' 'Recorded where its `docs/backlog.md` has an entry of that name.'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/docs/workstreams"
cat > "$fixture/$W" <<'FIXTURE'
# Workstreams

A step is recorded where `docs/backlog/` holds an entry of its name.
FIXTURE
scan_discriminate "$fixture" || exit 1

work="$TESTDIR/work"
mkdir -p "$work"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
scan_check "$work"
st=$?
[ "$st" -eq 2 ] && echo "FAIL: target absent — no seeded workstream register" >&2
[ "$st" -eq 0 ] || exit 1
