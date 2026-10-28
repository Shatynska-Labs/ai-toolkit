#!/usr/bin/env bash
# Scenario: A target that is a link is left.
# Requirement: An edited block is reported with its difference and never
# overwritten. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where docs/backlog/AGENTS.md is a symbolic link to a file holding
# a stale backlog block, the link and the file it points to are unchanged,
# and the backlog line states the path is not one the tool writes into.
# DERIVED (token): the statement is read as the backlog line saying `not` and
# `write`; its wording is design.md decision 7's, not the spec's.
#
# Executes the tool. Red until tasks 1.2 and 1.4 land (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
mkdir -p "$work"
put_block "$TESTDIR/elsewhere-root" backlog "$(lower_version "$(fversion backlog)")" "old"
real="$TESTDIR/elsewhere-root/$(target_of backlog)"
bt="$work/$(target_of backlog)"
mkdir -p "$(dirname "$bt")"
ln -s "$real" "$bt"
sum="$(md5sum "$real" | awk '{print $1}')"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
if [ ! -L "$bt" ] || [ "$(readlink "$bt")" != "$real" ]; then echo "FAIL: the link changed" >&2; exit 1; fi
assert_unchanged "$real" "$sum" "the file the link points to"
expect_line "$TESTDIR/report.txt" backlog not write
