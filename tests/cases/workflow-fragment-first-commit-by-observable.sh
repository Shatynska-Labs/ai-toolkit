#!/usr/bin/env bash
# Scenario: A later commit cannot claim the exception. (session-workflow: A
# repository's first commit is the one commit that reaches the trunk
# directly.)
#
# "The fragment SHALL identify that commit by the observable that defines it
# — the repository has no commit before it — and SHALL NOT name it by a class
# a later commit could claim, such as setup, initialization, bootstrap or
# tooling commits."
#
# SPECIFIED: the exception's statement identifies the commit by there being
# no commit before it; it names none of setup, initialization, bootstrap or
# tooling. The four class words are the scenario's own list. DERIVED: the
# exception's statement is taken to be each sentence naming the first commit
# as reaching the trunk directly — so a class word elsewhere in the same
# paragraph, about something else, does not fail the case — and the
# observable is matched as "no commit ... before" or "no earlier / prior /
# previous / preceding commit". "initialization" is matched by its stem, both
# spellings.
#
# Not asserted: that no other class word a later commit could claim is used.
# The scenario enumerates four; another is a judgment, verified by reading.
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
  local body sentences problems="" hits
  body="$(fragment_body "$1")" || return 2

  sentences="$(exception_sentences "$body")"
  if [ -z "$sentences" ]; then
    echo "FAIL: $1/$TARGET_REL states no first-commit exception — the scans below would pass vacuously" >&2
    return 1
  fi

  if ! printf '%s\n' "$sentences" | grep -q -i -E -- 'no commit[^.]*before|no (earlier|prior|previous|preceding) commit'; then
    problems="$problems
  the exception does not identify the commit by there being no commit before it"
  fi

  hits="$(printf '%s\n' "$sentences" | grep -i -E -- 'set-?up|initiali[sz]|bootstrap|tooling')"
  if [ -n "$hits" ]; then
    problems="$problems
  the exception names a class of commit a later commit could claim:
$hits"
  fi

  if [ -n "$problems" ]; then
    echo "FAIL: $1/$TARGET_REL$problems" >&2
    return 1
  fi
  return 0
}


# Near-miss: the observable is stated, and so is a class — the shape the
# delta rejects, since a later "initialization" commit could claim it.
FIXTURE='---
kind: standing-constraint
version: 7
---

## ship

Every change reaches the trunk through pull requests. The first commit, the initialization commit with no commit before it, reaches the trunk directly.'
EXPECTED_REASON="names a class of commit a later commit could claim"

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
