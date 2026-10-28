#!/usr/bin/env bash
# Scenario: The seeded preamble's example is not an entry (as revised).
# Requirement: Every run ends in one of three outcomes, and the exit code
# agrees. Change: list-what-a-project-receives (backlog-migration, MODIFIED).
#
# SPECIFIED: converting a backlog whose preamble is the one project-init
# seeded before this change, with its fenced example `## `change-name``,
# followed by two entries, docs/backlog/ holds exactly two entry files and
# no change-name.md.
# DERIVED (fixture): the preamble is backlog-migrate-fenced-example-not-entry.sh's.
#
# Executes the tool. Red until task 3.1 lands (state 1: a README is written).
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
work="$TESTDIR/work"
new_repo "$work" <<'BACKLOG'
# Backlog

Changes this project has identified and not yet archived.

An entry looks like this:

```markdown
## `change-name`

What the change is and why.

- **Priority**: high, with the evidence of harm happening now.
- **Kind**: change, with the reason.
- **Waits on**: nothing
- **Design with**: none
- **Workstream**: none
- **Recorded by**: the change that found it.
- **Re-checked**: 2026-01-01
```

## `first-entry`

What the first is and why.

- **Kind**: fix, a small correction.
- **Waits on**: nothing

## `second-entry`

What the second is and why.

- **Kind**: change, it owes a delta.
- **Waits on**: nothing
BACKLOG
(cd "$work" && bash "$MIGRATE") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?" "a fenced example does not block the conversion"
# shellcheck disable=SC2012 # names are the test's own fixture names, plain ASCII
listing="$(ls -A "$work/docs/backlog" | sort | tr '\n' ' ')"
[ "$listing" = "first-entry.md second-entry.md " ] || { echo "FAIL: docs/backlog/ should hold exactly the two entries, holds: $listing" >&2; exit 1; }
