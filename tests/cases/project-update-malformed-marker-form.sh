#!/usr/bin/env bash
# Scenario: A marker in neither form is malformed.
# Requirement: Each block the manifest lists is classified from the project
# alone. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where the backlog target's opening marker reads
# `<!-- ai-toolkit:backlog 1.0 sha256:<64 hex> -->`, or
# `<!-- ai-toolkit:backlog 1.0.0 -->` with no hash, its line reports the
# markers malformed, not absent, and the target is byte-for-byte unchanged.
# DERIVED (fixture): each marker with a closing marker after it; "not absent"
# is read as the line not stating `absent`.
#
# Executes the tool. Red until task 1.2 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
hex="$(printf 'x\n' | sha256_of)"
i=0
for marker in "<!-- ai-toolkit:backlog 1.0 sha256:$hex -->" "<!-- ai-toolkit:backlog 1.0.0 -->"; do
  i=$((i + 1))
  work="$TESTDIR/work-$i"
  f="$work/$(target_of backlog)"
  mkdir -p "$(dirname "$f")"
  printf '%s\nsome rules\n<!-- /ai-toolkit:backlog -->\n' "$marker" > "$f"
  sum="$(md5sum "$f" | awk '{print $1}')"
  (cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report-$i.txt" 2>&1
  expect_line "$TESTDIR/report-$i.txt" backlog malformed
  refuse_line "$TESTDIR/report-$i.txt" backlog absent
  assert_unchanged "$f" "$sum" "marker: $marker"
done
