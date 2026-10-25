#!/usr/bin/env bash
# Scenario: A missing seed blocks only an outstanding backlog.
# Requirement: A backlog is seeded where none exists.
# Change: one-file-per-backlog-entry (project-bootstrap, MODIFIED).
#
# SPECIFIED: run from a copy of the library without
# scripts/seed/backlog-README.md, once in a target with no backlog — BLOCKED
# (exit 2, tests/README.md) before any write, the target left empty — and
# once in a target whose docs/backlog/README.md exists, where it does not
# block on it.
# DERIVED (fixture): the copy carries rules/ and scripts/ from the toolkit
# under test with the seed removed; the real toolkit must carry the seed, so
# the copy differs from it in that file alone. The second run is asserted to
# succeed (exit 0), the outcome every other concern reaches in an empty
# target.
#
# Executes the tool; red until tasks 1.1 and 1.2 land (state 2: the real seed
# is absent).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

assert_file "$TOOLKIT_ROOT/scripts/seed/backlog-README.md" "target absent — the toolkit's seed, which the copy omits"

copy="$TESTDIR/copy"
mkdir -p "$copy"
cp -R "$TOOLKIT_ROOT/rules" "$copy/rules" || exit 1
cp -R "$TOOLKIT_ROOT/scripts" "$copy/scripts" || exit 1
rm -f "$copy/scripts/seed/backlog-README.md"

outstanding="$TESTDIR/outstanding"
mkdir -p "$outstanding"
report="$TESTDIR/report-outstanding.txt"
(cd "$outstanding" && bash "$copy/scripts/project-init") >"$report" 2>&1
assert_exit 2 "$?" "a missing seed blocks an outstanding backlog"
assert_contains "$report" "Outcome: BLOCKED"
[ -z "$(ls -A "$outstanding")" ] || { echo "FAIL: the blocked run wrote into the target:" >&2; ls -A "$outstanding" >&2; exit 1; }

satisfied="$TESTDIR/satisfied"
mkdir -p "$satisfied/docs/backlog"
printf '# Our backlog\n' > "$satisfied/docs/backlog/README.md"
sum="$(md5sum "$satisfied/docs/backlog/README.md" | awk '{print $1}')"
report="$TESTDIR/report-satisfied.txt"
(cd "$satisfied" && bash "$copy/scripts/project-init") >"$report" 2>&1
assert_exit 0 "$?" "a missing seed does not block a satisfied backlog"
if grep -q 'Outcome: BLOCKED' "$report"; then
  echo "FAIL: the satisfied run blocked" >&2; cat "$report" >&2; exit 1
fi
assert_unchanged "$satisfied/docs/backlog/README.md" "$sum" "the existing README is left"
