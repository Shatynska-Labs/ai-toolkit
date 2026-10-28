#!/usr/bin/env bash
# Scenario: The file's mode is kept.
# Requirement: A stale block nobody edited is replaced, and nothing outside
# its markers changes. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where a stale block's target has permission bits 0640, after the
# replacement its permission bits are 0640.
# DERIVED (fixture): the backlog target; the block is checked replaced, so the
# mode cannot be kept by a tool that wrote nothing.
#
# Executes the tool. Red until task 1.3 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
mode_of() { stat -c %a "$1" 2>/dev/null || stat -f %Lp "$1"; }
work="$TESTDIR/work"
mkdir -p "$work"
seed_all "$work" stale
f="$work/$(target_of backlog)"
chmod 0640 "$f"
[ "$(mode_of "$f")" = 640 ] || { echo "FAIL: fixture — the mode is not 640" >&2; exit 1; }
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
[ "$(marker_version "$f" backlog)" = "$(fversion backlog)" ] || { echo "FAIL: the stale backlog block was not replaced" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
[ "$(mode_of "$f")" = 640 ] || { echo "FAIL: the mode is $(mode_of "$f"), not 640" >&2; exit 1; }
