#!/usr/bin/env bash
# Scenario: A converted backlog receives the seeded rules.
# Requirement: The tool converts a single-file backlog's entries into the
# directory. Change: list-what-a-project-receives (backlog-migration, ADDED).
#
# SPECIFIED: scripts/project-init, run in a target backlog-migrate has just
# converted, writes the backlog's block into docs/backlog/AGENTS.md beside
# the entries and reports the rules written beside existing entries.
# DERIVED (token): a `backlog:` line saying `beside` (tests/README.md).
# DERIVED: the entries are byte-for-byte unchanged by project-init (files
# the project owns are never overwritten).
#
# Executes both tools. Red until tasks 2.3 and 3.1 land.
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

# Local arrangement (test-plan.md, Missing shared arrangement: block readers).
# block_body FILE NAME: the lines strictly between NAME's opening and closing
# markers, each with its newline.
block_body() {
  awk -v n="$2" '
    index($0, "<!-- /ai-toolkit:" n " -->") == 1 { exit }
    f { print }
    index($0, "<!-- ai-toolkit:" n " ") == 1 { f = 1 }
  ' "$1"
}
# marker_line FILE NAME: NAME's opening line in the form
# `<!-- ai-toolkit:NAME MAJOR.MINOR.PATCH sha256:<64 hex> -->`, or nothing.
marker_line() {
  grep -E "^<!-- ai-toolkit:$2 [0-9]+[.][0-9]+[.][0-9]+ sha256:[0-9a-f]{64} -->\$" "$1" 2>/dev/null
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
(cd "$work" && bash "$MIGRATE") >"$TESTDIR/report-migrate.txt" 2>&1
assert_exit 0 "$?" "the conversion"
# shellcheck disable=SC2012 # names are the test's own fixture names, plain ASCII
before="$(cd "$work/docs/backlog" && ls -A | sort | xargs md5sum)"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?" "project-init after the conversion"
[ -n "$(marker_line "$work/docs/backlog/AGENTS.md" backlog)" ] || { echo "FAIL: no backlog block in docs/backlog/AGENTS.md" >&2; exit 1; }
for f in alpha-change.md beta-fix.md gamma-change.md; do
  printf '%s\n' "$before" | grep -q -F "$(cd "$work/docs/backlog" && md5sum "$f")" || { echo "FAIL: $f changed" >&2; exit 1; }
done
grep -E '^backlog:' "$TESTDIR/report.txt" | grep -q 'beside' || { echo "FAIL: the backlog line does not state the rules written beside existing entries" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
