#!/usr/bin/env bash
# Scenario (mechanical half only): An adoption is not committed onto the
# trunk. (project-bootstrap: A wrapper offers the direct initial commit only
# to a repository without one, and shows what it holds.)
#
# "In the adoption mode the wrapper SHALL NOT offer to commit the tool's
# writes onto the repository's current branch, and SHALL state that they
# reach the trunk through a pull request like any other change."
#
# SPECIFIED: a paragraph about the adoption mode states that the writes reach
# the trunk through a pull request. DERIVED: the anchors `adopt` and
# `pull request` on one line.
#
# Not asserted: the negative half — that no commit is offered in an adoption.
# A prohibition and an instruction both name the commit, so no token scan
# separates them; verified by reading and by the cold run. Nor the adoption
# with no remote configured, which the requirement states but no scenario
# carries.
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
  if ! lines_with_all "$file" 'adopt' 'pull request' >/dev/null; then
    echo "FAIL: $file does not state that an adoption's writes reach the trunk through a pull request" >&2
    echo "      Without it the adoption ending is free to commit the tool's writes straight onto" >&2
    echo "      an existing trunk — the direct push the first-commit exception must not license." >&2
    return 1
  fi
  return 0
}


# Near-miss: the pre-change shape — the commit is offered in both modes.
FIXTURE='# project-init

4. In either mode, new project or adoption, offer to commit the tool'"'"'s writes on the current branch.

5. Name foundation discovery as the next step; a pull request is opened later.'
EXPECTED_REASON="reach the trunk through a pull request"

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
