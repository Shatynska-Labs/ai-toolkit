#!/usr/bin/env bash
# Scenario (mechanical half only): A rejected push is reported, not forced.
# (project-bootstrap: A wrapper connects a remote only from a URL the operator
# supplies.)
#
# "Where the push fails ... the wrapper SHALL report the failure as git
# stated it, SHALL state that `origin` now names the supplied URL, and stop.
# It SHALL NOT force the push, and SHALL NOT fetch, merge or rebase the
# remote's content to make the push succeed."
#
# SPECIFIED: a paragraph covering a failed or rejected push names `origin`;
# forcing is stated as prohibited; merging or rebasing is stated as
# prohibited. DERIVED: the anchors — `(reject|fail)` beside `origin`; `force`
# beside a negation (`not|never|no|without`); `merge|rebase` beside a
# negation. A negation on the same paragraph is the closest a token scan
# comes to a prohibition, and it is weaker than one: a paragraph saying
# "never stop; force the push" would satisfy it. Verified by reading.
#
# Not asserted: that the wrapper stops, and that it reports git's own words.
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
  if ! lines_with_all "$file" '\bpush' '(reject|fail)' '\borigin\b' >/dev/null; then
    problems="$problems
  the skill does not state, for a failed push, that origin names the supplied URL"
  fi
  if ! lines_with_all "$file" 'force' '\b(not|never|no|without)\b' >/dev/null; then
    problems="$problems
  the skill does not state that a rejected push is not forced"
  fi
  if ! lines_with_all "$file" '\b(merg|rebas)' '\b(not|never|no|without)\b' >/dev/null; then
    problems="$problems
  the skill does not state that the remote's history is not merged or rebased"
  fi
  if [ -n "$problems" ]; then
    echo "FAIL: $file$problems" >&2
    return 1
  fi
  return 0
}


# Near-miss: the failure is reported with origin named, and merging is
# ruled out — but the remedy offered, in the next paragraph, is a force push.
# shellcheck disable=SC2016 # the backticks are literal markdown in the fixture, not an expansion
FIXTURE='# project-init

5. If the push is rejected, report the rejection and say that `origin` now names the URL. Never merge the remote history.

Then retry the push with `git push --force`.'
EXPECTED_REASON="does not state that a rejected push is not forced"

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
