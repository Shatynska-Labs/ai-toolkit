#!/usr/bin/env bash
# Scenario: A README beside a CLAUDE.md of the project's own.
# Requirement: The shapes before 1.0.0 are converted only where git holds the
# original. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where docs/backlog/ holds a committed, unmodified README.md and a
# CLAUDE.md holding other text, with an uncommitted change, the conversion
# proceeds, CLAUDE.md is byte-for-byte unchanged, and the report states the
# line `@AGENTS.md` to add to it.
# DERIVED (token): "proceeds" is read as README.md gone and AGENTS.md holding
# the backlog block; the line to add as a report line naming
# docs/backlog/CLAUDE.md and `@AGENTS.md`.
#
# Executes the tool. Red until task 1.5 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
d="$work/docs/backlog"
mkdir -p "$d"
printf '# Backlog\n\nOur rules.\n' > "$d/README.md"
printf 'Our own instructions for this directory.\n' > "$d/CLAUDE.md"
git_fixture "$work"
printf 'A line not yet committed.\n' >> "$d/CLAUDE.md"
sum="$(md5sum "$d/CLAUDE.md" | awk '{print $1}')"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
assert_file_absent "$d/README.md" "the conversion proceeds: README removed"
[ "$(marker_version "$d/AGENTS.md" backlog)" = "$(fversion backlog)" ] || { echo "FAIL: the conversion did not write the backlog block" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
assert_unchanged "$d/CLAUDE.md" "$sum" "the project's own CLAUDE.md"
grep -F 'docs/backlog/CLAUDE.md' "$TESTDIR/report.txt" | grep -q -F '@AGENTS.md' || { echo "FAIL: the report does not state the @AGENTS.md line to add to docs/backlog/CLAUDE.md" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
