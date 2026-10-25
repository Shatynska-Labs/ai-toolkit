#!/usr/bin/env bash
# Scenario: A listed and a paragraph entry convert alike.
# Requirement: Each entry's fields are mapped into frontmatter, and nothing
# is dropped. Change: one-file-per-backlog-entry (backlog-migration, ADDED).
#
# SPECIFIED: one entry giving its fields as list items and another giving the
# same fields as paragraphs convert to files carrying the same keys with the
# same values.
# DERIVED (operationalisation): with the key order fixed by the seeded README,
# "same keys, same values" is the two frontmatter blocks being identical. The
# values are chosen so that each field maps (known names from an open and an
# archived change), so the comparison is not of two empty blocks.
#
# Executes the tool; red until task 2.2 lands (state 2).
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
mkdir -p "$work/openspec/changes/open-change" "$work/openspec/changes/archive/2026-09-01-seed-change"
echo "schema: spec-driven" > "$work/openspec/changes/open-change/.openspec.yaml"
echo "schema: spec-driven" > "$work/openspec/changes/archive/2026-09-01-seed-change/.openspec.yaml"
new_repo "$work" <<'BACKLOG'
# Backlog

## `listed-entry`

What the listed entry is and why.

- **Priority**: normal
- **Kind**: change, because it owes a delta.
- **Waits on**: `open-change`
- **Design with**: none
- **Workstream**: `some-goal`
- **Recorded by**: `seed-change`, found while seeding.
- **Re-checked**: 2026-10-01

## `paragraph-entry`

What the paragraph entry is and why.

**Priority**: normal

**Kind**: change, because it owes a delta.

**Waits on**: `open-change`

**Design with**: none

**Workstream**: `some-goal`

**Recorded by**: `seed-change`, found while seeding.

**Re-checked**: 2026-10-01
BACKLOG

(cd "$work" && bash "$MIGRATE") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"
listed="$work/docs/backlog/listed-entry.md"
para="$work/docs/backlog/paragraph-entry.md"
assert_file "$listed"
assert_file "$para"

[ "$(fm_value "$listed" priority)" = normal ] || { echo "FAIL: the listed entry's priority did not map; the comparison would be of nothing" >&2; head -n 12 "$listed" >&2; exit 1; }
[ "$(fm_value "$listed" waits_on)" = "[open-change]" ] || { echo "FAIL: the listed entry's waits_on is not [open-change]" >&2; head -n 12 "$listed" >&2; exit 1; }
a="$(awk 'NR == 1 { next } $0 == "---" { exit } { print }' "$listed")"
b="$(awk 'NR == 1 { next } $0 == "---" { exit } { print }' "$para")"
if [ "$a" != "$b" ]; then
  echo "FAIL: the two layouts convert to different frontmatter" >&2
  diff <(printf '%s\n' "$a") <(printf '%s\n' "$b") >&2
  exit 1
fi
