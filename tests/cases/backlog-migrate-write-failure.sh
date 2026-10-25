#!/usr/bin/env bash
# Scenario: A failed write leaves the old file.
# Requirement: Every run ends in one of three outcomes, and the exit code
# agrees. Change: one-file-per-backlog-entry (backlog-migration, ADDED).
#
# SPECIFIED: where a write fails, the tool reports ERROR, exits non-zero and
# distinct from BLOCKED (1, project-init's code), leaves no docs/backlog/ and
# no temporary directory, and docs/backlog.md is unchanged.
# DERIVED (mechanism): the failure is induced by making docs/ unwritable after
# the fixture is committed, so every precondition holds and the first write
# (the temporary directory "in docs/") fails. That is a failure at the first
# write rather than partway; no mechanism this suite controls fails a later
# write without knowing the temporary name. Recorded in test-plan.md.
# Cannot be induced as root, where permissions do not bind; the case fails
# rather than passing vacuously there.
#
# Executes the tool; red until task 2.1 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

MIGRATE="$TOOLKIT_ROOT/scripts/backlog-migrate"

# Local arrangement (test-plan.md, Missing shared arrangement: the migrate
# fixture helpers). tests/lib.sh holds no git fixture and no frontmatter
# reader, and a test module imports from no other test module.
#
# require_migrate: the target-absent guard. A BLOCKED case asserts a non-zero
# exit, which a missing script (127) would satisfy vacuously.
require_migrate() {
  [ -f "$MIGRATE" ] && return 0
  echo "FAIL: target absent — $MIGRATE does not exist yet" >&2
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
# fm_value FILE KEY: the value of KEY in FILE's leading frontmatter, or nothing.
fm_value() {
  awk -v key="$2" '
    NR == 1 { if ($0 != "---") exit; next }
    $0 == "---" { exit }
    index($0, key ":") == 1 { v = substr($0, length(key) + 2); sub(/^ /, "", v); print v; exit }
  ' "$1"
}
# fm_keys FILE: the keys of FILE's leading frontmatter, one per line.
fm_keys() {
  awk 'NR == 1 { if ($0 != "---") exit; next } $0 == "---" { exit } { k = $0; sub(/:.*/, "", k); print k }' "$1"
}
# fm_body FILE: everything after FILE's leading frontmatter.
fm_body() {
  awk 'NR == 1 && $0 == "---" { infm = 1; next } infm { if ($0 == "---") infm = 0; next } { print }' "$1"
}
# The reader is checked on a specimen first, so a pass cannot come from a
# reader that reads nothing.
check_reader() {
  local s="$TESTDIR/reader-specimen.md"
  printf '%s\n' '---' 'priority: normal' 'waits_on: [a, b]' '---' 'kind: change' 'Body text.' > "$s"
  if [ "$(fm_value "$s" waits_on)" = "[a, b]" ] && [ -z "$(fm_value "$s" kind)" ] \
    && [ "$(fm_keys "$s" | tr '\n' ' ')" = "priority waits_on " ] \
    && [ "$(fm_body "$s" | head -n 1)" = "kind: change" ]; then
    return 0
  fi
  echo "FAIL: discriminator — the local frontmatter reader misreads its specimen" >&2
  exit 1
}
# assert_untouched WORK SUM: docs/backlog.md as it was, and nothing beside it.
assert_untouched() {
  local work="$1" sum="$2" listing
  assert_unchanged "$work/docs/backlog.md" "$sum" "docs/backlog.md is left as it was"
  assert_file_absent "$work/docs/backlog" "no docs/backlog/ is written"
  listing="$(ls -A "$work/docs")"
  if [ "$listing" != "backlog.md" ]; then
    echo "FAIL: docs/ holds more than backlog.md after the run:" >&2
    printf '%s\n' "$listing" >&2
    exit 1
  fi
}

require_migrate
if [ "$(id -u)" = 0 ]; then
  echo "FAIL: running as root, an unwritable docs/ cannot be arranged; this case cannot establish anything here" >&2
  exit 1
fi

work="$TESTDIR/work"
new_repo "$work" <<'BACKLOG'
# Backlog

## `alpha-change`

What alpha is and why.

- **Kind**: change, because it owes a delta.
BACKLOG
sum="$(md5sum "$work/docs/backlog.md" | awk '{print $1}')"
chmod 555 "$work/docs"
trap 'chmod 755 "$work/docs"' EXIT

report="$TESTDIR/report.txt"
(cd "$work" && bash "$MIGRATE") >"$report" 2>&1
status=$?
chmod 755 "$work/docs"

assert_exit 1 "$status" "a failed write ends in ERROR"
grep -q -w ERROR "$report" || { echo "FAIL: the report does not state ERROR" >&2; cat "$report" >&2; exit 1; }
assert_untouched "$work" "$sum"
