#!/usr/bin/env bash
# Scenario (mechanical half only): The commit offer lists files the tool did
# not write. (project-bootstrap: A wrapper offers the direct initial commit
# only to a repository without one, and shows what it holds.)
#
# The wrapper SHALL show "every untracked path not excluded by git's standard
# exclusions — not only the paths the tool wrote". A pre-existing file of the
# project's own is reached only by a listing defined over untracked paths, so
# the skill must state the listing in those terms.
#
# SPECIFIED: the skill names untracked paths and their exclusion (ignore file
# / git's exclusions) together. DERIVED: that the two sit in one paragraph —
# the requirement fixes the set, not the wording; the stems `untracked` and
# `ignor|exclu` are this author's anchor for it.
#
# Not asserted: that the listing is shown before confirmation is asked, and
# that a wrapper following the skill actually names the file. The skill is
# prose a model follows; the behaviour is checked by the cold run (task 4.2).
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
  if ! lines_with_all "$file" 'untracked' 'ignor|exclu' >/dev/null; then
    echo "FAIL: $file states no listing of untracked paths not excluded by git" >&2
    echo "      An offer listing only what the tool wrote omits the project's own files, and a" >&2
    echo "      confirmation of 'what the tool just did' is not a confirmation of those." >&2
    return 1
  fi
  return 0
}


# Near-miss: the offer lists the tool's writes, and "untracked" appears only
# in a paragraph that says nothing of what git excludes.
FIXTURE='# project-init

4. Before asking, list the paths the tool wrote: the ignore file, the backlog and AGENTS.md.

Untracked files are left where they are.'
EXPECTED_REASON="states no listing of untracked paths not excluded by git"

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
