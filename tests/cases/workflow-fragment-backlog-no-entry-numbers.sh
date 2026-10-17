#!/usr/bin/env bash
# Scenarios (mechanical half only): Entry rules are read from the backlog, not
# the fragment ("with no rule about entry numbers stated in either"); A
# backlog entry is cited by name (fragment half). Change: seed-the-backlog.
#
# SPECIFIED: "The fragment SHALL NOT mention entry numbers."
# DERIVED (operationalisation): the fragment is one paragraph per line, so a
# paragraph about the backlog or its entries is a line mentioning `backlog`,
# `entry` or `entries`. No such line may carry `number` in any form. A
# paragraph mentioning numbers without either word is not reached — that gap
# is recorded in test-plan.md.
#
# Static read: the assertion never executes anything, so a pass on the real
# fragment establishes nothing alone. The check is a function run first over
# fixtures this case supplies — one violating, one conforming — and must
# discriminate between them before its verdict on the fragment is read.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Prints every backlog/entry paragraph that mentions a number; empty if none.
number_mentions() {
  grep -n -i -E 'backlog|entry|entries' "$1" | grep -i -E 'number'
}

violating="$TESTDIR/violating.md"
cat > "$violating" <<'FIXTURE'
Record it in `docs/backlog.md`.

An entry's number is an identifier, not a priority, and is not stable: cite an entry by name, never by number.
FIXTURE
conforming="$TESTDIR/conforming.md"
cat > "$conforming" <<'FIXTURE'
Record it in `docs/backlog.md`.

The backlog states itself how an entry is written and when it is deleted.

This version number is unrelated to anything above.
FIXTURE

if [ -z "$(number_mentions "$violating")" ]; then
  echo "FAIL: discriminator — the check passed a fixture that mentions entry numbers; it asserts nothing" >&2
  exit 1
fi
if [ -n "$(number_mentions "$conforming")" ]; then
  echo "FAIL: discriminator — the check rejected a fixture that mentions no entry number" >&2
  exit 1
fi

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"
# Vacuity guard: with no backlog paragraph there is nothing for the scan to read.
assert_contains "$fragment" "docs/backlog.md" "the backlog rule this case reads"

hits="$(number_mentions "$fragment")"
if [ -n "$hits" ]; then
  echo "FAIL: $fragment mentions entry numbers in a backlog paragraph" >&2
  echo "      An entry is named, not numbered; a rule explaining a number presumes it exists." >&2
  echo "$hits" >&2
  exit 1
fi
