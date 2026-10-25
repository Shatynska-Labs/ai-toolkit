#!/usr/bin/env bash
# Scenario: none of its own; regression for the requirement Each entry's
# fields are mapped into frontmatter, and nothing is dropped (backlog-migration,
# ADDED by one-file-per-backlog-entry).
#
# SPECIFIED: a part of a field's value the mapping does not consume is kept in
# the body under the field's label, and the report names it.
# DERIVED (fixture): the shape the dry run over basis's backlog found, a date
# followed by a note, `2026-10-25 (by \`some-change\`)`, whose note the first
# implementation dropped. Written at apply, not by change-test-writer.
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

check_reader
require_migrate

work="$TESTDIR/work"
new_repo "$work" <<'BACKLOG'
# Backlog

## `noted-date`

What it is and why.

**Kind**: `change`. It owes a delta.

**Re-checked**: 2026-10-25 (by `choose-durable-data-storage`).
BACKLOG

report="$TESTDIR/report.txt"
(cd "$work" && bash "$MIGRATE") >"$report" 2>&1
assert_exit 0 "$?"
f="$work/docs/backlog/noted-date.md"
assert_file "$f"
[ "$(fm_value "$f" re_checked)" = 2026-10-25 ] || { echo "FAIL: re_checked is not the date: $(fm_value "$f" re_checked)" >&2; exit 1; }
item="$(fm_body "$f" | grep -F -- '- **Re-checked**:')"
case "$item" in
  *choose-durable-data-storage*) ;;
  *) echo "FAIL: the note after the date is not kept in the body under Re-checked" >&2; fm_body "$f" >&2; exit 1 ;;
esac
if ! grep -F 'noted-date' "$report" | grep -q -i 're-checked'; then
  echo "FAIL: the report does not name noted-date and its Re-checked among the fields kept in the body" >&2
  cat "$report" >&2
  exit 1
fi
