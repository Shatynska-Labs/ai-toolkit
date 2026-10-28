#!/usr/bin/env bash
# Scenario: An entry named agents or claude blocks.
# Requirement: Every run ends in one of three outcomes, and the exit code
# agrees. Change: list-what-a-project-receives (backlog-migration, MODIFIED).
#
# SPECIFIED: a backlog holding an entry headed `## `agents`` or `## `Claude``
# makes the tool report BLOCKED (exit 2), name the entry, and write nothing.
# DERIVED (operationalisation): "names the entry" is read as the heading's
# word, case-sensitive and whole, in the report, so AGENTS.md or CLAUDE.md
# elsewhere in it does not satisfy it.
#
# Executes the tool. Red until task 3.1 lands (state 1: both convert).
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

require_migrate
for name in agents Claude; do
  work="$TESTDIR/work-$name"
  # shellcheck disable=SC2016 # backticks and $ are literal markdown or awk, not expansions
  printf '# Backlog\n\n## `alpha-change`\n\nWhat alpha is and why.\n\n## `%s`\n\nSomething named %s.\n' "$name" "$name" | new_repo "$work"
  sum="$(md5sum "$work/docs/backlog.md" | awk '{print $1}')"
  (cd "$work" && bash "$MIGRATE") >"$TESTDIR/report-$name.txt" 2>&1
  assert_exit 2 "$?" "an entry named $name blocks"
  grep -q -w BLOCKED "$TESTDIR/report-$name.txt" || { echo "FAIL: the report does not state BLOCKED ($name)" >&2; exit 1; }
  grep -v -F 'Something named' "$TESTDIR/report-$name.txt" | grep -q -w -- "$name" || { echo "FAIL: the report does not name the entry $name" >&2; cat "$TESTDIR/report-$name.txt" >&2; exit 1; }
  assert_unchanged "$work/docs/backlog.md" "$sum" "docs/backlog.md is left ($name)"
  assert_file_absent "$work/docs/backlog" "nothing written ($name)"
  [ "$(ls -A "$work/docs")" = "backlog.md" ] || { echo "FAIL: docs/ gained a file ($name)" >&2; exit 1; }
done
