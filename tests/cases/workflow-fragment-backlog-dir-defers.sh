#!/usr/bin/env bash
# Scenarios (mechanical half only): Entry rules are read from the backlog,
# not the fragment; The backlog does not yet exist; A backlog entry is cited
# by name (no entry numbers).
# Requirement: A second change surfacing in a session is recorded in the
# backlog. Change: one-file-per-backlog-entry (session-workflow, MODIFIED).
#
# SPECIFIED: the fragment names `docs/backlog/`, restates none of the entry
# rules the README carries, mentions no entry number, and does not direct
# creating the backlog where it is absent.
# DERIVED (carried from the superseded workflow-fragment-backlog-rules-not-
# restated.sh, -backlog-no-entry-numbers.sh and -backlog-not-created-by-
# fragment.sh, their anchor revised to the directory): the same three scans,
# extended with the new shape's terms (`<name>.md`, `waits_on:`,
# `re_checked:`, "only identifier").
#
# Static read (third situation); each check is run on a violating and a
# conforming fixture first. Red until task 3.1 lands (the anchor is absent).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

restated_rules() {
  grep -n -i -E 'kebab-case|carries no meaning|no order|only identifier|<name>[.]md|recorded by\*?\*?:|depends on\*?\*?:|waits_on:|re_checked:|has no entries|no entries' "$1"
}
number_mentions() {
  grep -n -i -E 'backlog|entry|entries' "$1" | grep -i -E 'number'
}
create_directions() {
  grep -n -i -E 'backlog' "$1" \
    | grep -i -E '(if|where|when) (it is |that file is |the file is |the backlog is |the directory is )?(absent|missing)|(if|where) (it|that file|the file|the backlog|the directory) (does not|doesn.t) exist|creat(e|ing) (that file|the file|it|the backlog|the directory|its readme)'
}

conforming="$TESTDIR/conforming.md"
cat > "$conforming" <<'FIXTURE'
- Out-of-scope work: record it in `docs/backlog/`, or open the identified change.

`docs/backlog/` holds identified changes. Its README states how an entry is written and when it is deleted.

This version number is unrelated to anything above.
FIXTURE
for f in restated_rules number_mentions create_directions; do
  if [ -n "$("$f" "$conforming")" ]; then
    echo "FAIL: discriminator — $f rejects a conforming fragment" >&2; exit 1
  fi
done
expect_hit() {
  printf '%s\n' "$2" > "$TESTDIR/violating.md"
  [ -n "$("$1" "$TESTDIR/violating.md")" ] || { echo "FAIL: discriminator — $1 passes: $2" >&2; exit 1; }
}
# shellcheck disable=SC2016 # backticks are literal markdown in the fixtures
expect_hit restated_rules 'Record it in `docs/backlog/` as `<name>.md`, the entry'"'"'s only identifier.'
# shellcheck disable=SC2016
expect_hit restated_rules 'Set `re_checked:` to today.'
# shellcheck disable=SC2016
expect_hit number_mentions 'Cite a backlog entry by name, never by its number.'
# shellcheck disable=SC2016
expect_hit create_directions 'Record it in `docs/backlog/`, creating the directory if absent.'

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"
assert_contains "$fragment" "docs/backlog/" "target absent — the backlog rule this case reads names the directory"
for f in restated_rules number_mentions create_directions; do
  hits="$("$f" "$fragment")"
  if [ -n "$hits" ]; then
    echo "FAIL: [$f] $fragment states what the README owns or project-bootstrap does:" >&2
    echo "$hits" >&2
    exit 1
  fi
done
