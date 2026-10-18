#!/usr/bin/env bash
# Scenario (mechanical half only): Declining leaves the gap stated.
# (project-bootstrap: A wrapper connects a remote only from a URL the operator
# supplies.)
#
# "Where the operator declines or supplies no URL, the wrapper SHALL state
# that the workflow's first pull request needs a remote with the trunk pushed
# to it, and continue to naming the next step."
#
# SPECIFIED: a paragraph covering a declined or absent URL states that the
# pull request needs a remote with the trunk pushed to it. DERIVED: the
# anchors — `URL`, a decline (`declin|no URL|supplies no|without a URL`),
# `pull request`, `remote` and `push` on one line. `URL` is what separates
# this paragraph from the declined-commit one, which names a remote too.
#
# Not asserted: that no remote is configured afterwards, and that the wrapper
# continues to the next step. Behaviour; checked by reading and the cold run.
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
  if ! lines_with_all "$file" '\bURL\b' '(declin|no URL|supplies no|without a URL)' 'pull request' 'remote' '\bpush' >/dev/null; then
    echo "FAIL: $file does not state, where no URL is supplied, that the first pull request needs a remote with the trunk pushed to it" >&2
    echo "      A decline that is passed over silently leaves foundation's first pull request" >&2
    echo "      to discover the missing remote." >&2
    return 1
  fi
  return 0
}


# Near-miss: the decline is acknowledged, but the gap it leaves is not named.
FIXTURE='# project-init

5. If the operator declines to give a URL, skip this step and push nothing; name foundation discovery as the next step.'
EXPECTED_REASON="first pull request needs a remote with the trunk pushed to it"

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
