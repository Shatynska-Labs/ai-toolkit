#!/usr/bin/env bash
# Scenario: A backlog README is converted.
# Requirement: The shapes before 1.0.0 are converted only where git holds the
# original. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where docs/backlog/ holds a committed, unmodified README.md and
# entry files, and no AGENTS.md or CLAUDE.md, README.md is gone,
# docs/backlog/AGENTS.md holds the backlog block, docs/backlog/CLAUDE.md holds
# exactly `@AGENTS.md`, every entry file is unchanged, and the report states
# the conversion and that it was not checked for edits.
# DERIVED (token): the backlog line states `README` and `not checked`;
# "exactly @AGENTS.md" admits one trailing newline; "the backlog block" is a
# hashed marker at the fragment's version whose hash matches.
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
printf '# Backlog\n\nOur rules, as seeded before 1.0.0.\n' > "$d/README.md"
printf -- '---\npriority: normal\nkind: fix\n---\n\nAn entry.\n' > "$d/some-entry.md"
printf -- '---\npriority: high\nkind: change\n---\n\nAnother.\n' > "$d/other-entry.md"
git_fixture "$work"
entries="$(cd "$d" && md5sum some-entry.md other-entry.md)"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
assert_file_absent "$d/README.md" "the README is removed"
[ "$(marker_version "$d/AGENTS.md" backlog)" = "$(fversion backlog)" ] || { echo "FAIL: docs/backlog/AGENTS.md does not hold the backlog block" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
hash_ok "$d/AGENTS.md" backlog || { echo "FAIL: the backlog block's hash does not match" >&2; exit 1; }
assert_file "$d/CLAUDE.md" "docs/backlog/CLAUDE.md is created"
if [ "$(cat "$d/CLAUDE.md")" != "@AGENTS.md" ] || [ "$(grep -c '' "$d/CLAUDE.md")" != 1 ]; then echo "FAIL: docs/backlog/CLAUDE.md does not hold exactly @AGENTS.md" >&2; cat "$d/CLAUDE.md" >&2; exit 1; fi
[ "$(cd "$d" && md5sum some-entry.md other-entry.md)" = "$entries" ] || { echo "FAIL: an entry file changed" >&2; exit 1; }
expect_line "$TESTDIR/report.txt" backlog README "not checked"
