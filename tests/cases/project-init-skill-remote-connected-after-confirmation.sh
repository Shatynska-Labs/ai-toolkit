#!/usr/bin/env bash
# Scenario (mechanical half only): A supplied URL is connected and pushed
# after confirmation. (project-bootstrap: A wrapper connects a remote only
# from a URL the operator supplies.)
#
# "Where the operator supplies a URL and confirms, the wrapper SHALL add it
# as the remote `origin` and push the current branch to it with its upstream
# set."
#
# SPECIFIED: the skill names the remote `origin`; it directs a push with the
# upstream set; it asks the operator for a URL and for confirmation. DERIVED:
# the anchors — `origin` as a word; `push` beside `upstream`, `-u` or
# `--set-upstream`; `URL` beside `confirm` on one paragraph.
#
# Not asserted: that the push waits for the confirmation, and that the skill
# never creates a hosted repository or chooses its forge, owner, name or
# visibility (requirement text no scenario carries). Ordering and a
# prohibition are prose; verified by reading and by the cold run (task 4.2),
# which checks `origin` is set and the trunk pushed with upstream.
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
  local problems=""
  if ! lines_with_all "$file" '\borigin\b' >/dev/null; then
    problems="$problems
  the skill does not name the remote origin"
  fi
  if ! lines_with_all "$file" '\bpush' '(upstream|--set-upstream|(^|[^a-z0-9-])-u\b)' >/dev/null; then
    problems="$problems
  the skill does not direct a push with the upstream set"
  fi
  if ! lines_with_all "$file" '\bURL\b' 'confirm' >/dev/null; then
    problems="$problems
  the skill does not ask the operator for a URL and a confirmation together"
  fi
  if [ -n "$problems" ]; then
    echo "FAIL: $file$problems" >&2
    return 1
  fi
  return 0
}


# Near-miss: origin is added on confirmation and pushed, but without the
# upstream — the branch would have no tracking reference.
# shellcheck disable=SC2016 # the backticks are literal markdown in the fixture, not an expansion
FIXTURE='# project-init

5. Ask for the URL of a hosted repository the operator created. On confirmation, run `git remote add origin <url>`, then `git push origin HEAD`.'
EXPECTED_REASON="does not direct a push with the upstream set"

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
