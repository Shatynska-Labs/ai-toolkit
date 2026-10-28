#!/usr/bin/env bash
# Scenario: A missing backlog fragment blocks every run.
# Requirement: The backlog's rules are written where none exist (ADDED);
# with "Every run ends in one of three outcomes" (MODIFIED).
# Change: list-what-a-project-receives (project-bootstrap; replaces the
# removed scenario "A missing seed blocks only an outstanding backlog").
#
# SPECIFIED: with rules/backlog.md absent from the tool's copy, a run in a
# target with no backlog and a run in a target whose docs/backlog/AGENTS.md
# holds the block both report BLOCKED and write nothing; BLOCKED exits 2
# (tests/README.md).
# DERIVED (fixture): the copy differs from the toolkit in that fragment
# alone; the present block is the one a run of the real toolkit wrote.
#
# Executes the tool. Red until task 1.1 lands (state 2: the real fragment is
# absent).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Local arrangement (test-plan.md, Missing shared arrangement: toolkit_copy).
# toolkit_copy DIR: rules/ and scripts/ of the toolkit under test, copied to
# DIR, so a case can alter the copy without touching the repository.
toolkit_copy() {
  mkdir -p "$1"
  cp -R "$TOOLKIT_ROOT/rules" "$1/rules" || exit 1
  cp -R "$TOOLKIT_ROOT/scripts" "$1/scripts" || exit 1
}

assert_file "$TOOLKIT_ROOT/rules/backlog.md" "target absent — the fragment the copy omits"
copy="$TESTDIR/copy"
toolkit_copy "$copy"
rm -f "$copy/rules/backlog.md"

empty="$TESTDIR/empty"
mkdir -p "$empty"
(cd "$empty" && bash "$copy/scripts/project-init") >"$TESTDIR/report-empty.txt" 2>&1
assert_exit 2 "$?" "BLOCKED where the backlog is outstanding"
assert_contains "$TESTDIR/report-empty.txt" "Outcome: BLOCKED"
[ -z "$(ls -A "$empty")" ] || { echo "FAIL: the blocked run wrote into the target:" >&2; ls -A "$empty" >&2; exit 1; }

seeded="$TESTDIR/seeded"
mkdir -p "$seeded"
(cd "$seeded" && bash "$PROJECT_INIT") >/dev/null 2>&1
assert_file "$seeded/docs/backlog/AGENTS.md" "the real toolkit wrote the block this run finds present"
snap() { (cd "$1" && find . -path ./.git -prune -o -type f -print | sort | xargs md5sum); }
before="$(snap "$seeded")"
(cd "$seeded" && bash "$copy/scripts/project-init") >"$TESTDIR/report-present.txt" 2>&1
assert_exit 2 "$?" "BLOCKED where the backlog block is present"
assert_contains "$TESTDIR/report-present.txt" "Outcome: BLOCKED"
[ "$(snap "$seeded")" = "$before" ] || { echo "FAIL: the blocked run changed the target" >&2; exit 1; }
