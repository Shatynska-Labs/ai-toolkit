#!/usr/bin/env bash
# Scenario: A missing manifest blocks.
# Requirement: Every run ends in one of three outcomes, and the exit code
# agrees. Change: list-what-a-project-receives (project-bootstrap, MODIFIED).
#
# SPECIFIED: where the toolkit root resolves but rules/manifest is absent, the
# tool reports BLOCKED, names the manifest, exits non-zero and writes
# nothing. BLOCKED's code is 2 (tests/README.md).
# DERIVED (token): "names the manifest" is read as the report containing
# `manifest`.
#
# Executes the tool. Red until task 2.1 lands (state 2: the real manifest is
# absent; the copy-based run then succeeds).
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

assert_file "$TOOLKIT_ROOT/rules/manifest" "target absent — the manifest the copy omits"
copy="$TESTDIR/copy"
toolkit_copy "$copy"
rm -f "$copy/rules/manifest"
work="$TESTDIR/work"
mkdir -p "$work"
(cd "$work" && bash "$copy/scripts/project-init") >"$TESTDIR/report.txt" 2>&1
assert_exit 2 "$?" "a missing manifest blocks"
assert_contains "$TESTDIR/report.txt" "Outcome: BLOCKED"
grep -q -i 'manifest' "$TESTDIR/report.txt" || { echo "FAIL: the report does not name the manifest" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
[ -z "$(ls -A "$work")" ] || { echo "FAIL: the blocked run wrote into the target:" >&2; ls -A "$work" >&2; exit 1; }
