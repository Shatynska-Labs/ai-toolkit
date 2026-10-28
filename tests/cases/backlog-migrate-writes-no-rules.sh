#!/usr/bin/env bash
# Scenario: The rules are left to project-init.
# Requirement: The tool converts a single-file backlog's entries into the
# directory. Change: list-what-a-project-receives (backlog-migration, ADDED).
#
# SPECIFIED: converting a backlog with a preamble, the tool writes no
# README.md, AGENTS.md or CLAUDE.md, and the report states that the old
# preamble was not carried over and that scripts/project-init writes the
# backlog's rules, into docs/backlog/AGENTS.md.
# DERIVED (token): the report contains `preamble`, `project-init` and
# `docs/backlog/AGENTS.md`.
#
# Executes the tool. Red until task 3.1 lands (state 1).
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
assert_exit 0 "$?"
for f in README.md AGENTS.md CLAUDE.md; do
  assert_file_absent "$work/docs/backlog/$f" "the tool writes no $f"
done
for w in preamble project-init docs/backlog/AGENTS.md; do
  grep -q -i -F -- "$w" "$TESTDIR/report.txt" || { echo "FAIL: the report does not say '$w'" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
done
