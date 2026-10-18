#!/usr/bin/env bash
# Scenario (mechanical half only): An existing remote is left alone.
# (project-bootstrap: A wrapper connects a remote only from a URL the operator
# supplies.)
#
# "Where a remote is already configured, the wrapper SHALL leave it unchanged
# and SHALL NOT ask for one."
#
# SPECIFIED: a paragraph covering an already-configured remote states that it
# is left as it is or that no URL is asked for. DERIVED: the anchors —
# `already` and `remote` beside one of `unchanged|leave|left|alone|not ask|
# skip`.
#
# Not asserted: that the configured remote is in fact unchanged — the
# behaviour of a wrapper following the prose. Checked by reading.
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
  if ! lines_with_all "$file" 'already' 'remote' '(unchanged|leave|left|alone|not ask|skip)' >/dev/null; then
    echo "FAIL: $file does not state that an already-configured remote is left unchanged and not asked for" >&2
    echo "      A wrapper with no such case asks for a URL in a repository that has one, and an" >&2
    echo "      operator answering it replaces or duplicates a remote that was working." >&2
    return 1
  fi
  return 0
}


# Near-miss: an existing remote is noticed, and then replaced.
# shellcheck disable=SC2016 # the backticks are literal markdown in the fixture, not an expansion
FIXTURE='# project-init

5. If a remote is already configured, ask for the new URL and run `git remote set-url origin <url>`.'
EXPECTED_REASON="already-configured remote is left unchanged"

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
