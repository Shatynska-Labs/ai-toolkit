#!/usr/bin/env bash
# Scenario: A v12 workflow block is converted.
# Requirement: The shapes before 1.0.0 are converted only where git holds the
# original. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where a committed, unmodified AGENTS.md holds a
# `<!-- ai-toolkit:development-workflow v12 -->` block with project text below
# it, the block is replaced by the current workflow block, the project text is
# unchanged, and the report states it was converted from v12, not checked for
# edits, and to be reviewed with `git diff`.
# DERIVED (token): the workflow line states `v12`, `not checked` and
# `git diff`; "the current workflow block" is read as a hashed marker at the
# fragment's version whose hash matches.
#
# Executes the tool. Red until task 1.5 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
mkdir -p "$work"
f="$work/$(target_of development-workflow)"
{ printf '%s\n' "$V12_BLOCK"; printf '\n## Our conventions\n\nKept as written.\n'; } > "$f"
git_fixture "$work"
tail -n +6 "$f" > "$TESTDIR/below.before"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
[ "$(marker_version "$f" development-workflow)" = "$(fversion development-workflow)" ] || { echo "FAIL: the v12 block was not replaced by the current block" >&2; cat "$f" "$TESTDIR/report.txt" >&2; exit 1; }
hash_ok "$f" development-workflow || { echo "FAIL: the converted block's hash does not match" >&2; exit 1; }
if grep -q -F 'development-workflow v12' "$f"; then echo "FAIL: the v12 marker remains" >&2; exit 1; fi
c="$(grep -n -F '<!-- /ai-toolkit:development-workflow -->' "$f" | head -n 1 | cut -d: -f1)"
tail -n +$((c + 1)) "$f" > "$TESTDIR/below.after"
cmp -s "$TESTDIR/below.before" "$TESTDIR/below.after" || { echo "FAIL: the project text below the block changed" >&2; diff "$TESTDIR/below.before" "$TESTDIR/below.after" >&2; exit 1; }
expect_line "$TESTDIR/report.txt" development-workflow v12 "not checked" "git diff"
