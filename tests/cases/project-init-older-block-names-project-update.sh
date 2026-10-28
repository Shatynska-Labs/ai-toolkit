#!/usr/bin/env bash
# Scenario: An existing block at a different version is reported, not
# rewritten (as revised).
# Requirement: Workflow rules reach a project as a versioned managed block.
# Change: update-managed-block (project-bootstrap, MODIFIED).
#
# SPECIFIED: where a managed block for the same fragment already exists at an
# earlier version, the block is left unchanged, and the report states both
# versions and names scripts/project-update as what brings it current.
# DERIVED (fixtures): both earlier forms the requirement names — a hashed
# marker one version below the fragment's, and `v12`, below every semantic
# version. DERIVED (token): read on the `conventions file:` line
# (tests/README.md's report contract); "names" as `scripts/project-update`;
# the superseded "out of scope" wording must be gone from that line.
#
# Executes project-init. Red until task 2.1 lands (state 1: the line says
# reconciling is out of scope).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
carried="$(fversion development-workflow)"
older="$(lower_version "$carried")" || { echo "FAIL: fixture — no version below $carried" >&2; exit 1; }
i=0
for form in hashed v12; do
  i=$((i + 1))
  work="$TESTDIR/work-$form"
  mkdir -p "$work"
  if [ "$form" = hashed ]; then
    put_block "$work" development-workflow "$older" "an earlier text"
    shown="$older"
  else
    printf '%s\n' "$V12_BLOCK" > "$work/$(target_of development-workflow)"
    shown=v12
  fi
  f="$work/$(target_of development-workflow)"
  sum="$(md5sum "$f" | awk '{print $1}')"
  (cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report-$i.txt" 2>&1
  assert_exit 0 "$?" "$form"
  assert_unchanged "$f" "$sum" "$form: the older block is not rewritten"
  expect_line "$TESTDIR/report-$i.txt" "conventions file" "$shown" "$carried" "scripts/project-update"
  refuse_line "$TESTDIR/report-$i.txt" "conventions file" "out of scope"
done
