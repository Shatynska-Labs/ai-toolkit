#!/usr/bin/env bash
# Scenario: Project text around the block survives.
# Requirement: A stale block nobody edited is replaced, and nothing outside
# its markers changes. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where a stale block's target holds project text above the
# opening marker and below the closing marker, one of those lines not yet
# committed, every line outside the markers is byte-for-byte what it was.
# DERIVED (fixture): the root AGENTS.md in a committed repository, a line
# below the block changed after the commit, and a last line with no newline
# ("every byte"); the block is checked replaced, so the case cannot pass on a
# tool that wrote nothing.
#
# Executes the tool. Red until task 1.3 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
mkdir -p "$work"
f="$work/$(target_of development-workflow)"
printf '# Our project\n\nAbove the block.\n\n' > "$f"
put_block "$work" development-workflow "$(lower_version "$(fversion development-workflow)")" "old"
printf '\n## Below\n\nA committed line.\n' >> "$f"
git_fixture "$work"
sed 's/^A committed line\.$/A line changed and not committed./' "$f" > "$f.new" && cat "$f.new" > "$f" && rm -f "$f.new"
printf 'The last line, with no newline.' >> "$f"
outside() {  # FILE: the bytes before the opening marker's line, a separator, and the bytes after the closing marker's line
  local o c
  o="$(grep -n -F '<!-- ai-toolkit:development-workflow ' "$1" | head -n 1 | cut -d: -f1)"
  c="$(grep -n -F '<!-- /ai-toolkit:development-workflow -->' "$1" | head -n 1 | cut -d: -f1)"
  head -n $((o - 1)) "$1"
  printf '=== between ===\n'
  tail -n +$((c + 1)) "$1"
}
outside "$f" > "$TESTDIR/before"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
[ "$(marker_version "$f" development-workflow)" = "$(fversion development-workflow)" ] || { echo "FAIL: the stale block was not replaced" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
outside "$f" > "$TESTDIR/after"
cmp -s "$TESTDIR/before" "$TESTDIR/after" || { echo "FAIL: text outside the markers changed" >&2; diff "$TESTDIR/before" "$TESTDIR/after" >&2; exit 1; }
