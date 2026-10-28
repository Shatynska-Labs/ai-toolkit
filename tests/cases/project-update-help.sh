#!/usr/bin/env bash
# Scenario: Help describes the tool and changes nothing.
# Requirement: The update tool is a standalone executable beside project-init.
# Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: `project-update --help`, run in a project, names the target
# argument, the outcomes and their exit codes, exits 0, and the project is
# unchanged.
# DERIVED (token): the target argument is read as the word `target` (any
# case); each outcome's code is read as the digit on a line naming that
# outcome (SUCCESS 0, ERROR 1, BLOCKED 2), the layout project-init's --help
# uses.
#
# Executes the tool. Red until task 1.1 lands (state 2: the tool is absent).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
mkdir -p "$work"
seed_all "$work" stale
before="$(tree_sum "$work")"
(cd "$work" && bash "$PROJECT_UPDATE" --help) >"$TESTDIR/help.txt" 2>&1
assert_exit 0 "$?" "--help exits zero"
assert_tree "$work" "$before" "--help changes nothing"
grep -q -i 'target' "$TESTDIR/help.txt" || { echo "FAIL: --help does not name the target argument" >&2; cat "$TESTDIR/help.txt" >&2; exit 1; }
for pair in SUCCESS:0 ERROR:1 BLOCKED:2; do
  o="${pair%%:*}"; c="${pair##*:}"
  grep -w -- "$o" "$TESTDIR/help.txt" | grep -q -w -- "$c" || { echo "FAIL: --help does not state $o with exit code $c on one line" >&2; cat "$TESTDIR/help.txt" >&2; exit 1; }
done
