#!/usr/bin/env bash
# Scenario (mechanical half only): The backlog does not yet exist — as
# revised by seed-the-backlog: the fragment does not direct creating it.
#
# SPECIFIED: "The fragment SHALL NOT direct creating the backlog where it is
# absent."
# DERIVED (operationalisation): a line (paragraph) mentioning `backlog` that
# also carries an absence condition — `if absent`, `where absent`, `if it is
# absent`, `if it does not exist`, `if missing` — or a creation verb applied
# to "that file" / "the backlog" / "it" counts as the direction. A
# differently worded direction is not reached; verified by reading.
#
# The half not asserted here — running the tool creates the file — is
# backlog-seeded-new-project.sh and backlog-seeded-adoption.sh.
#
# Static read: the check runs over a violating and a conforming fixture first.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

create_directions() {
  grep -n -i -E 'backlog' "$1" \
    | grep -i -E '(if|where|when) (it is |that file is |the file is |the backlog is )?(absent|missing)|(if|where) (it|that file|the file|the backlog) (does not|doesn.t) exist|creat(e|ing) (that file|the file|it|the backlog)'
}

violating="$TESTDIR/violating.md"
cat > "$violating" <<'FIXTURE'
- Out-of-scope work: record it in `docs/backlog.md`, creating that file if absent, or open the identified change.
FIXTURE
conforming="$TESTDIR/conforming.md"
cat > "$conforming" <<'FIXTURE'
- Out-of-scope work: record it in `docs/backlog.md`, or open the identified change.

The backlog states itself how an entry is written and when it is deleted.
FIXTURE

if [ -z "$(create_directions "$violating")" ]; then
  echo "FAIL: discriminator — the check passed a fixture that directs creating the backlog" >&2
  exit 1
fi
if [ -n "$(create_directions "$conforming")" ]; then
  echo "FAIL: discriminator — the check rejected a fixture that directs no creation" >&2
  exit 1
fi

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"
assert_contains "$fragment" "docs/backlog.md" "the routing rule naming the backlog path is kept"

hits="$(create_directions "$fragment")"
if [ -n "$hits" ]; then
  echo "FAIL: $fragment directs creating the backlog where it is absent" >&2
  echo "      Creating it is project-bootstrap's; the fragment carries no one-time setup step." >&2
  echo "$hits" >&2
  exit 1
fi
