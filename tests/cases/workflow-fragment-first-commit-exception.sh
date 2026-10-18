#!/usr/bin/env bash
# Scenario (mechanical half only): The first commit is accounted for.
# (session-workflow: A repository's first commit is the one commit that
# reaches the trunk directly.)
#
# "The workflow fragment SHALL state, where it states that every change
# reaches the trunk through pull requests, that a repository's first commit
# reaches the trunk directly." A session reading a history that begins with a
# commit no pull request carried finds it accounted for only where the
# delivery rule it would otherwise breach is stated.
#
# SPECIFIED: the fragment's body states that the first commit reaches the
# trunk directly; the statement sits where the pull-request delivery rule is
# stated. DERIVED: "where it states" is read as within two lines of the line
# carrying the delivery rule — the same paragraph, or the paragraph beside it
# — and the delivery rule is located by the phrase "trunk through pull
# request", which the change's task 3.1 quotes from the fragment. Both bounds
# are this author's.
#
# Not asserted: that the fragment adds that no other commit reaches the trunk
# directly. That clause is in the requirement but not in this scenario's
# outcome, and an exclusive clause has no token a scan can separate from the
# exception it restricts. Verified by reading.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

TARGET_REL="rules/development-workflow.md"

# Prints the fragment's body — what the inlining tool carries into a
# project's conventions file — with the frontmatter stripped. Status 2 where
# the fragment or its body cannot be located, so a vacuous read is never
# taken for a pass or a rejection.
fragment_body() {
  local file="$1/$TARGET_REL" closing body
  if [ ! -f "$file" ]; then
    echo "FAIL: $file does not exist — the scans below would pass vacuously" >&2
    return 2
  fi
  closing="$(grep -n '^---$' "$file" | sed -n '2p' | cut -d: -f1)"
  if [ -z "$closing" ]; then
    echo "FAIL: $file has no closing frontmatter delimiter — the body cannot be located" >&2
    return 2
  fi
  body="$(tail -n "+$((closing + 1))" "$file")"
  if [ -z "$body" ]; then
    echo "FAIL: $file has an empty body — the scans below would pass vacuously" >&2
    return 2
  fi
  printf '%s\n' "$body"
}

# The exception's own statement: every sentence of the body naming the first
# commit as reaching the trunk directly. Sentences are split on '.', which
# this fragment's prose ends them with.
exception_sentences() {
  printf '%s\n' "$1" | grep -o -i -E -- '[^.]*first commit[^.]*' | grep -i -E -- 'direct'
}

check() {
  local body rule_line exc_lines line ok=""
  body="$(fragment_body "$1")" || return 2

  rule_line="$(printf '%s\n' "$body" | grep -n -i -E -- 'trunk through pull request' | head -n 1 | cut -d: -f1)"
  if [ -z "$rule_line" ]; then
    echo "FAIL: $1/$TARGET_REL states no delivery rule through pull requests — the placement scan would pass vacuously" >&2
    return 2
  fi

  exc_lines="$(printf '%s\n' "$body" | grep -n -i -E -- 'first commit' | grep -i -E -- 'direct' | cut -d: -f1)"
  if [ -z "$exc_lines" ]; then
    echo "FAIL: $1/$TARGET_REL does not state that a repository's first commit reaches the trunk directly" >&2
    echo "      A session reading a history that begins with a direct commit reads it as a breach." >&2
    return 1
  fi

  for line in $exc_lines; do
    if [ $((line - rule_line)) -le 2 ] && [ $((rule_line - line)) -le 2 ]; then
      ok=1
    fi
  done
  if [ -z "$ok" ]; then
    echo "FAIL: $1/$TARGET_REL states the first-commit exception away from the pull-request delivery rule" >&2
    echo "      (delivery rule at body line $rule_line; exception at body line(s) $(printf '%s' "$exc_lines" | tr '\n' ' '))." >&2
    echo "      The requirement places it where the delivery rule is stated, so a session reading" >&2
    echo "      that rule finds its one exception beside it." >&2
    return 1
  fi
  return 0
}


# Near-miss: the exception is stated, but in a different section from the
# delivery rule it qualifies.
FIXTURE='---
kind: standing-constraint
version: 7
---

## ship

Every change reaches the trunk through pull requests.

Each pull request is reviewed before it merges.

## record

Archiving records the change.

## history

A repository'"'"'s first commit, with no commit before it, reaches the trunk directly.'
EXPECTED_REASON="states the first-commit exception away from the pull-request delivery rule"

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
