#!/usr/bin/env bash
# Scenario: A backlog is converted (as revised).
# Requirement: The tool converts a single-file backlog's entries into the
# directory. Change: list-what-a-project-receives (backlog-migration, ADDED;
# replaces the removed "The tool converts a single-file backlog into the
# directory").
#
# SPECIFIED: run in a target whose docs/backlog.md holds three entries,
# docs/backlog/ holds exactly three entry files, each named for its entry's
# heading, and docs/backlog.md no longer exists; SUCCESS exits 0.
#
# Executes the tool. Red until task 3.1 lands (state 1: a README is written
# beside the entries).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

MIGRATE="$TOOLKIT_ROOT/scripts/backlog-migrate"

# Local arrangement (test-plan.md, Missing shared arrangement: migrate
# fixture helpers; found in backlog-migrate-converts.sh, a test module).
# require_migrate: the target-absent guard, since a missing script's 127
# would satisfy a non-zero exit vacuously.
require_migrate() {
  [ -f "$MIGRATE" ] && return 0
  echo "FAIL: target absent — $MIGRATE does not exist" >&2
  exit 1
}
# new_repo DIR: a git repository at DIR whose docs/backlog.md is stdin,
# committed together with everything already under DIR.
new_repo() {
  local dir="$1"
  mkdir -p "$dir/docs"
  cat > "$dir/docs/backlog.md"
  git -C "$dir" init -q >/dev/null 2>&1 || { echo "FAIL: git init failed in $dir" >&2; exit 1; }
  git -C "$dir" config user.email t@t.com
  git -C "$dir" config user.name t
  git -C "$dir" add -A
  git -C "$dir" commit -q -m fixture >/dev/null || { echo "FAIL: fixture commit failed in $dir" >&2; exit 1; }
}


# Local arrangement (test-plan.md, Missing shared arrangement: three_entries).
three_entries() {
  cat <<'BACKLOG'
# Backlog

A project's own rules.

## `alpha-change`

What alpha is and why.

- **Kind**: change, because it owes a delta.
- **Waits on**: nothing

## `beta-fix`

What beta is and why.

- **Kind**: fix, a one-line correction.
- **Waits on**: nothing

## `gamma-change`

What gamma is and why.

- **Kind**: change, it needs a decision.
- **Waits on**: nothing
BACKLOG
}

require_migrate
work="$TESTDIR/work"
three_entries | new_repo "$work"
(cd "$work" && bash "$MIGRATE") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?" "the conversion succeeds"
assert_file_absent "$work/docs/backlog.md" "the single file is deleted"
# shellcheck disable=SC2012 # names are the test's own fixture names, plain ASCII
listing="$(ls -A "$work/docs/backlog" | sort | tr '\n' ' ')"
[ "$listing" = "alpha-change.md beta-fix.md gamma-change.md " ] || { echo "FAIL: docs/backlog/ should hold exactly the three entry files, holds: $listing" >&2; exit 1; }
