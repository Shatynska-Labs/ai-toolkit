#!/usr/bin/env bash
# Scenario: A README is converted into an existing AGENTS.md.
# Requirement: The shapes before 1.0.0 are converted only where git holds the
# original. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where docs/workstreams/ holds a committed, unmodified README.md
# and a committed, unmodified AGENTS.md of project text with no block,
# AGENTS.md holds its project text unchanged, followed by a blank line and the
# workstreams block, and README.md is gone.
# DERIVED (operationalisation): the file's first bytes are the old AGENTS.md
# byte for byte, the next line is empty, and the line after it is the
# workstreams block's hashed opening marker at the fragment's version.
#
# Executes the tool. Red until task 1.5 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
d="$work/docs/workstreams"
mkdir -p "$d"
printf '# Workstreams\n\nOur rules.\n' > "$d/README.md"
printf '# Our workstream notes\n\nKept as written.\n' > "$d/AGENTS.md"
cp "$d/AGENTS.md" "$TESTDIR/agents.before"
git_fixture "$work"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
assert_file_absent "$d/README.md" "the README is removed"
n="$(grep -c '' "$TESTDIR/agents.before")"
head -n "$n" "$d/AGENTS.md" > "$TESTDIR/agents.head"
cmp -s "$TESTDIR/agents.before" "$TESTDIR/agents.head" || { echo "FAIL: the project text of AGENTS.md changed" >&2; cat "$d/AGENTS.md" >&2; exit 1; }
[ "$(sed -n "$((n + 1))p" "$d/AGENTS.md")" = "" ] || { echo "FAIL: no blank line after the project text" >&2; cat "$d/AGENTS.md" >&2; exit 1; }
sed -n "$((n + 2))p" "$d/AGENTS.md" | grep -q -E "^<!-- ai-toolkit:workstreams $(fversion workstreams | sed 's/[.]/[.]/g') sha256:[0-9a-f]{64} -->\$" || { echo "FAIL: the workstreams block does not follow the blank line" >&2; cat "$d/AGENTS.md" >&2; exit 1; }
hash_ok "$d/AGENTS.md" workstreams || { echo "FAIL: the workstreams block's hash does not match" >&2; exit 1; }
