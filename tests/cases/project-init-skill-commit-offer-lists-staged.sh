#!/usr/bin/env bash
# Scenario (mechanical half only): A file staged before the run is listed.
# (project-bootstrap: A wrapper offers the direct initial commit only to a
# repository without one, and shows what it holds.)
#
# The wrapper SHALL show "every path already staged". A listing defined over
# untracked paths alone misses a file staged before the run, because a staged
# file is no longer untracked.
#
# SPECIFIED: the skill names staged paths among what the offer lists, on the
# same paragraph as the commit it describes. DERIVED: the anchor — the word
# `staged` beside `commit` — is this author's; the requirement fixes the set.
#
# Not asserted: that a wrapper following the skill actually names the file.
# Behaviour is checked by the cold run (task 4.2).
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
  if ! lines_with_all "$file" '\bstaged\b' 'commit' >/dev/null; then
    echo "FAIL: $file does not name already-staged paths among what the commit offer lists" >&2
    echo "      A file staged before the run is not untracked, so a listing of untracked paths" >&2
    echo "      alone commits it without the operator having seen it." >&2
    return 1
  fi
  return 0
}


# Near-miss: the offer lists untracked paths only, and the word "stage"
# appears in another form.
FIXTURE='# project-init

4. Before asking, list every untracked path git does not ignore, then stage them and offer the commit.'
EXPECTED_REASON="does not name already-staged paths"

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
