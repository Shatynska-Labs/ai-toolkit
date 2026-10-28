#!/usr/bin/env bash
# Scenario: Several records to attend to are named in manifest order.
# Requirement: Every run ends in one of three outcomes, and the exit code
# agrees. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: with the workstreams block edited and the backlog block's target
# a symbolic link, the report holds one line `Attention: backlog, workstreams`.
# DERIVED (fixture): every other record holds a current block; the link points
# outside the project, at a file holding a current backlog block.
#
# Executes the tool. Red until tasks 1.2 and 1.6 land (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
mkdir -p "$work"
seed_all "$work" current
edit_inside "$work/$(target_of workstreams)" workstreams "a line the project changed"
bt="$work/$(target_of backlog)"
mkdir -p "$TESTDIR/elsewhere"
mv "$bt" "$TESTDIR/elsewhere/AGENTS.md"
ln -s "$TESTDIR/elsewhere/AGENTS.md" "$bt"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
lines="$(grep -E '^Attention:' "$TESTDIR/report.txt")"
[ "$lines" = "Attention: backlog, workstreams" ] || { echo "FAIL: expected one line 'Attention: backlog, workstreams', got: $lines" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
