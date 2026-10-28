#!/usr/bin/env bash
# Scenario: No hash command blocks.
# Requirement: Every run ends in one of three outcomes, and the exit code
# agrees. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where neither sha256sum nor shasum is on the PATH, the tool
# reports BLOCKED, exits 2, and the project is unchanged.
# DERIVED (fixture): PATH is a directory of links to every command on the
# caller's PATH except sha256sum and shasum (after
# hash-command-absent-blocks-outstanding.sh); the project holds stale blocks.
#
# Executes the tool. Red until task 1.1 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
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
work="$TESTDIR/work"
mkdir -p "$work"
seed_all "$work" stale
before="$(tree_sum "$work")"
(cd "$work" && PATH="$bin" bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
assert_outcome "$TESTDIR/report.txt" 2 "$?" BLOCKED
assert_tree "$work" "$before" "no hash command"
