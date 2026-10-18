#!/usr/bin/env bash
# Scenario (mechanical half only): A declined commit leaves both gaps stated.
# (project-bootstrap: A wrapper offers the direct initial commit only to a
# repository without one, and shows what it holds.)
#
# "Where the operator declines the commit, the wrapper SHALL state that the
# repository's first commit and a remote are both outstanding."
#
# SPECIFIED: one paragraph covering the declined commit names both the first
# (or initial) commit and a remote. DERIVED: the anchors `declin`,
# `(first|initial) commit` and `remote` on one line; "initial" is accepted
# because the requirement itself uses both words for the same commit.
#
# Not asserted: that no commit and no remote exist afterwards — that is the
# behaviour of a wrapper following the prose, checked by the cold run, not by
# reading. Nor that the paragraph adds that the first pull request needs both;
# that clause is in the requirement but not in this scenario's outcome.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

TARGET_REL="skills/project-init/SKILL.md"

# Prints every line of FILE matching all of the given case-insensitive EREs.
# This repository writes one paragraph per line, so a line is a paragraph and
# co-occurrence on a line is co-occurrence in one statement.
lines_with_all() {
  local file="$1"; shift
  local out
  out="$(cat "$file")"
  local re
  for re in "$@"; do
    out="$(printf '%s\n' "$out" | grep -i -E -- "$re")" || return 1
  done
  printf '%s\n' "$out"
}

# Fails with status 2 where the target is absent, so a missing file is never
# read as either a pass or a rejection on the asserted property.
require_target() {
  if [ ! -f "$1/$TARGET_REL" ]; then
    echo "FAIL: $1/$TARGET_REL does not exist — the scans below would pass vacuously" >&2
    return 2
  fi
}

check() {
  require_target "$1" || return 2
  local file="$1/$TARGET_REL"
  if ! lines_with_all "$file" 'declin' '(first|initial) commit' 'remote' >/dev/null; then
    echo "FAIL: $file does not state, for a declined commit, that the first commit and a remote are both outstanding" >&2
    echo "      A decline that says only 'nothing was committed' leaves the missing remote unstated." >&2
    return 1
  fi
  return 0
}


# Near-miss: the decline is handled and the first commit named, but the
# remote gap is not.
FIXTURE='# project-init

4. If the operator declines, say that the initial commit is outstanding and nothing was committed.'
EXPECTED_REASON="first commit and a remote are both outstanding"

# The discriminator runs before the committed file is checked, so it executes
# while that check is still red. The check is a static read, so a pass over the
# committed file establishes only that the file could be read. Run it over
# material this test supplies, built to carry the near-miss named above, and
# require the rejection to name the property this case exists to assert.
fixture="$TESTDIR/falsifying"
mkdir -p "$fixture/$(dirname "$TARGET_REL")"
printf '%s\n' "$FIXTURE" >"$fixture/$TARGET_REL"
assert_file "$fixture/$TARGET_REL" "the falsifying fixture was not written"

fixture_reason="$(check "$fixture" 2>&1)"
fixture_status=$?
if [ "$fixture_status" -eq 2 ]; then
  echo "FAIL: the fixture could not be read, so the discriminator would pass without discriminating" >&2
  exit 1
fi
if [ "$fixture_status" -eq 0 ]; then
  echo "FAIL: the check passed over material chosen to falsify it — it asserts nothing" >&2
  exit 1
fi
case "$fixture_reason" in
  *"$EXPECTED_REASON"*) ;;
  *)
    echo "FAIL: the fixture was rejected, but not on the property this case exists to assert" >&2
    echo "      (expected a reason containing: $EXPECTED_REASON). Rejection reason was:" >&2
    printf '%s\n' "$fixture_reason" >&2
    exit 1 ;;
esac

# The committed file, checked last.
check "$TOOLKIT_ROOT" || exit 1
