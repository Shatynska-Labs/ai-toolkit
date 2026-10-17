#!/usr/bin/env bash
# Scenario (mechanical half only): Entry rules are read from the backlog, not
# the fragment. Change: seed-the-backlog.
#
# SPECIFIED: the fragment states that the file carries the entry rules "and
# SHALL NOT restate them: stated in both places, they are two wordings that
# drift."
# DERIVED (operationalisation): the entry rules are recognised by the
# distinctive phrases of the seeded text (design.md) and the field labels of
# the entry shape — `kebab-case`, `carries no meaning`, `Recorded by`,
# `Depends on`, `has no entries`. None may appear in
# the fragment. A restatement in other words is not reached.
#
# Not asserted: that the fragment states the file carries the rules. That is
# prose with no fixed wording; verified by reading.
#
# Static read: currently green on the pre-change fragment (it carries none of
# these phrases), so the fixtures below are what establish the check can fail.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

restated_rules() {
  grep -n -i -E 'kebab-case|carries no meaning|recorded by\*?\*?:|depends on\*?\*?:|has no entries' "$1"
}

violating="$TESTDIR/violating.md"
cat > "$violating" <<'FIXTURE'
Record it in `docs/backlog.md`. An entry's heading is the change's name in kebab-case, and the order of entries carries no meaning.
FIXTURE
conforming="$TESTDIR/conforming.md"
cat > "$conforming" <<'FIXTURE'
Record it in `docs/backlog.md`; the backlog states itself how an entry is written and when it is deleted.
FIXTURE

if [ -z "$(restated_rules "$violating")" ]; then
  echo "FAIL: discriminator — the check passed a fixture restating the entry rules" >&2
  exit 1
fi
if [ -n "$(restated_rules "$conforming")" ]; then
  echo "FAIL: discriminator — the check rejected a fixture that defers to the file" >&2
  exit 1
fi

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"
assert_contains "$fragment" "docs/backlog.md" "the backlog rule this case reads"

hits="$(restated_rules "$fragment")"
if [ -n "$hits" ]; then
  echo "FAIL: $fragment restates the backlog's entry rules, which project-bootstrap's seeded file owns" >&2
  echo "$hits" >&2
  exit 1
fi
