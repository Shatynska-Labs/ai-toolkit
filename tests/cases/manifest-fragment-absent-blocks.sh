#!/usr/bin/env bash
# Scenarios: Missing fragment blocks rather than degrades (as revised); The
# fragment is read even when nothing will be written.
# Requirement: Every run ends in one of three outcomes, and the exit code
# agrees. Change: list-what-a-project-receives (project-bootstrap, MODIFIED).
#
# SPECIFIED: with a fragment the manifest lists absent from the tool's copy —
# here the workflow fragment, the backlog's being
# backlog-fragment-absent-blocks-every-run.sh — the tool reports BLOCKED,
# exits non-zero and writes nothing, whether the target lacks the block or
# already holds it.
# DERIVED (fixture): the copy keeps rules/manifest, so the block is the
# fragment's and not the manifest's (the existing fragment-absent-*.sh cases
# copy no manifest, and would block for that reason alone). The present block
# is in the earlier v12 form, which the tool reads as a block present.
#
# Executes the tool. Red until task 2.1 lands (state 2: no manifest).
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

assert_file "$TOOLKIT_ROOT/rules/manifest" "target absent — the manifest the copy keeps"
copy="$TESTDIR/copy"
toolkit_copy "$copy"
rm -f "$copy/rules/development-workflow.md"

empty="$TESTDIR/empty"
mkdir -p "$empty"
(cd "$empty" && bash "$copy/scripts/project-init") >"$TESTDIR/report-empty.txt" 2>&1
assert_exit 2 "$?" "BLOCKED where the block is outstanding"
assert_contains "$TESTDIR/report-empty.txt" "Outcome: BLOCKED"
[ -z "$(ls -A "$empty")" ] || { echo "FAIL: the blocked run wrote into the target" >&2; exit 1; }

present="$TESTDIR/present"
mkdir -p "$present"
cat > "$present/AGENTS.md" <<'BLOCK'
<!-- ai-toolkit:development-workflow v12 -->
placeholder
<!-- /ai-toolkit:development-workflow -->
BLOCK
sum="$(md5sum "$present/AGENTS.md" | awk '{print $1}')"
(cd "$present" && bash "$copy/scripts/project-init") >"$TESTDIR/report-present.txt" 2>&1
assert_exit 2 "$?" "BLOCKED where the block is already present"
assert_contains "$TESTDIR/report-present.txt" "Outcome: BLOCKED"
assert_unchanged "$present/AGENTS.md" "$sum" "nothing written"
[ "$(ls -A "$present")" = "AGENTS.md" ] || { echo "FAIL: the blocked run wrote into the target" >&2; ls -A "$present" >&2; exit 1; }
