#!/usr/bin/env bash
# Scenario: The named project-init is the tool's own copy's.
# Requirement: The tool runs from its own copy where project-init runs.
# Change: list-what-a-project-receives (backlog-migration, ADDED; replaces
# the removed "The tool locates its resources itself and runs where
# project-init runs").
#
# SPECIFIED: run from one copy of the library while AI_TOOLKIT_ROOT and
# CLAUDE_PLUGIN_ROOT name another, the project-init its report names is the
# one in the copy it was invoked from.
# SPECIFIED (requirement text of the MODIFIED outcomes requirement): the
# seeded README is no longer a precondition — each copy holds scripts/ alone,
# without scripts/seed/ or rules/, and the conversion succeeds.
# DERIVED (operationalisation): the report names project-init by a path
# under the invoked copy, and never names the other copy.
#
# Executes the tool. Red until task 3.1 lands.
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
copy_a="$TESTDIR/copy-a"
copy_b="$TESTDIR/copy-b"
for c in "$copy_a" "$copy_b"; do
  mkdir -p "$c"
  cp -R "$TOOLKIT_ROOT/scripts" "$c/scripts" || exit 1
  rm -rf "$c/scripts/seed"
done
work="$TESTDIR/work"
new_repo "$work" <<'BACKLOG'
# Backlog

## `alpha-change`

What alpha is and why.

- **Kind**: change, because it owes a delta.
BACKLOG
(cd "$work" && AI_TOOLKIT_ROOT="$copy_b" CLAUDE_PLUGIN_ROOT="$copy_b" bash "$copy_a/scripts/backlog-migrate") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?" "the conversion needs no text from the library"
a_real="$(cd "$copy_a" && pwd -P)"
grep -q -F -e "$copy_a/scripts/project-init" -e "$a_real/scripts/project-init" "$TESTDIR/report.txt" \
  || { echo "FAIL: the report does not name the invoked copy's project-init" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
if grep -q -F "$copy_b" "$TESTDIR/report.txt"; then echo "FAIL: the report names the other copy" >&2; exit 1; fi
