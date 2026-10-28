#!/usr/bin/env bash
# DERIVED from requirement text, not a scenario: Every run ends in one of
# three outcomes, and the exit code agrees (project-bootstrap, MODIFIED by
# list-what-a-project-receives) — "where a block is outstanding, neither
# sha256sum nor shasum available to hash it" is a BLOCKED precondition, and a
# command precondition is scoped to the concerns outstanding.
#
# SPECIFIED: with neither command on PATH, a run in an empty directory
# reports BLOCKED (exit 2) and writes nothing; a run in a project every
# concern of which a first run already satisfied is not blocked (exit 0).
# DERIVED (fixture): PATH is a directory of links to every command on the
# caller's PATH except sha256sum and shasum, so nothing else the tool drives
# goes missing.
#
# Executes the tool. Red until task 2.2 lands (state 1: the run succeeds).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

bin="$TESTDIR/bin"
mkdir -p "$bin"
IFS=: read -r -a dirs <<< "$PATH"
for d in "${dirs[@]}"; do
  [ -d "$d" ] || continue
  for c in "$d"/*; do
    n="${c##*/}"
    case "$n" in sha256sum|shasum) continue ;; esac
    [ -x "$c" ] && [ ! -e "$bin/$n" ] && ln -s "$c" "$bin/$n"
  done
done
if PATH="$bin" command -v sha256sum >/dev/null 2>&1 || PATH="$bin" command -v shasum >/dev/null 2>&1; then
  echo "FAIL: fixture — a hash command is still reachable" >&2; exit 1
fi
PATH="$bin" command -v git >/dev/null 2>&1 || { echo "FAIL: fixture — git is not reachable on the reduced PATH" >&2; exit 1; }

outstanding="$TESTDIR/outstanding"
mkdir -p "$outstanding"
(cd "$outstanding" && PATH="$bin" bash "$PROJECT_INIT") >"$TESTDIR/report-outstanding.txt" 2>&1
assert_exit 2 "$?" "no hash command while blocks are outstanding blocks"
assert_contains "$TESTDIR/report-outstanding.txt" "Outcome: BLOCKED"
[ -z "$(ls -A "$outstanding")" ] || { echo "FAIL: the blocked run wrote into the target:" >&2; ls -A "$outstanding" >&2; exit 1; }

satisfied="$TESTDIR/satisfied"
mkdir -p "$satisfied"
(cd "$satisfied" && bash "$PROJECT_INIT") >/dev/null 2>&1
assert_exit 0 "$?" "the first, full run"
(cd "$satisfied" && PATH="$bin" bash "$PROJECT_INIT") >"$TESTDIR/report-satisfied.txt" 2>&1
assert_exit 0 "$?" "no hash command blocks nothing where no block is outstanding"
