#!/usr/bin/env bash
# Scenario: A fragment without a semantic version blocks.
# Requirement: Every run ends in one of three outcomes, and the exit code
# agrees. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where a fragment the manifest lists carries no `kind`, or a
# `version` such as `12`, the tool reports BLOCKED, exits 2, and the project
# is unchanged.
# DERIVED (fixture): `version: 12` on workstreams.md and no `kind` on
# backlog.md, each in its own copy; the project holds a stale block for every
# record.
#
# Executes the tool. Red until task 1.1 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
run_blocked() {  # LABEL COPY
  local work="$TESTDIR/work-$1" before
  mkdir -p "$work"
  seed_all "$work" stale "$TOOLKIT_ROOT"
  before="$(tree_sum "$work")"
  (cd "$work" && bash "$2/scripts/project-update") >"$TESTDIR/report-$1.txt" 2>&1
  assert_outcome "$TESTDIR/report-$1.txt" 2 "$?" BLOCKED
  assert_tree "$work" "$before" "$1"
}
counter="$TESTDIR/counter"
toolkit_copy "$counter"
require_update "$counter/scripts/project-update"
set_version "$counter/rules/workstreams.md" 12
run_blocked counter-version "$counter"

nokind="$TESTDIR/nokind"
toolkit_copy "$nokind"
awk 'NR == 1 && $0 == "---" { fm = 1; print; next } fm && $0 == "---" { fm = 0; print; next } fm && /^kind:/ { next } { print }' "$nokind/rules/backlog.md" > "$nokind/rules/backlog.md.new" && mv "$nokind/rules/backlog.md.new" "$nokind/rules/backlog.md"
[ -z "$(frag_key "$nokind/rules/backlog.md" kind)" ] || { echo "FAIL: fixture — the kind was not removed" >&2; exit 1; }
run_blocked no-kind "$nokind"
