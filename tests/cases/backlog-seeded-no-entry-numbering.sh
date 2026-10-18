#!/usr/bin/env bash
# Scenario: The seeded file carries no numbering — as the MODIFIED requirement
# now stands, with the brevity statement it adds. Change: add-backlog-skill.
#
# SPECIFIED: no heading begins with a number; no sentence refers to an
# entry's number.
# DERIVED (operationalisation): every occurrence of `number` in any form must
# be part of `line number(s)`, the brevity statement the revised requirement
# obliges ("without line numbers"). This replaces backlog-seeded-no-numbering.sh's
# stricter reading — `number` nowhere at all — which the revised requirement
# makes unsatisfiable; that case is in test-plan.md's obsolete list.
#
# Executes the tool; no fixture owed.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
bash "$PROJECT_INIT" >/dev/null 2>&1

backlog="$work/docs/backlog.md"
assert_file "$backlog" "the seeded file this case reads"

if ! grep -q -E '^#' "$backlog"; then
  echo "FAIL: $backlog carries no heading; the numbering scan would assert nothing" >&2
  exit 1
fi

numbered="$(grep -n -E '^#+[[:space:]]*[`*_[(]*[0-9]' "$backlog")"
if [ -n "$numbered" ]; then
  echo "FAIL: a heading in the seeded backlog begins with a number" >&2
  echo "$numbered" >&2
  exit 1
fi

mentions="$(sed -E 's/[Ll]ine numbers?//g' "$backlog" | grep -n -i 'number')"
if [ -n "$mentions" ]; then
  echo "FAIL: the seeded backlog refers to a number other than line numbers" >&2
  echo "$mentions" >&2
  exit 1
fi
