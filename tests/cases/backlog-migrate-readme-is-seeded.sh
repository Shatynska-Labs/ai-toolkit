#!/usr/bin/env bash
# Scenario: The README is the seeded one.
# Requirement: The tool converts a single-file backlog into the directory.
# Change: one-file-per-backlog-entry (backlog-migration, ADDED).
#
# SPECIFIED: converting a backlog whose preamble differs from the seeded one,
# the README written is byte-for-byte the one scripts/project-init seeds, and
# the report states the old preamble was not carried over.
# SPECIFIED (project-bootstrap, A backlog is seeded where none exists): both
# tools write from scripts/seed/backlog-README.md, so the README also equals
# that file.
# DERIVED (operationalisation): "states the preamble was not carried over" is
# read as the report naming the preamble (`preamble`, any case).
#
# Executes both tools; red until tasks 1.1, 1.2 and 2.1 land (state 2).
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

work="$TESTDIR/work"
new_repo "$work" <<'BACKLOG'
# Our backlog

Rules of our own that the seeded README does not carry.

## How we use this file

We keep it tidy.

## `alpha-change`

What alpha is and why.

- **Kind**: change, because it owes a delta.
- **Waits on**: nothing
BACKLOG

report="$TESTDIR/report.txt"
(cd "$work" && bash "$MIGRATE") >"$report" 2>&1
assert_exit 0 "$?"

fresh="$TESTDIR/fresh"
mkdir -p "$fresh"
(cd "$fresh" && bash "$PROJECT_INIT") >"$TESTDIR/init-report.txt" 2>&1
seeded="$fresh/docs/backlog/README.md"
assert_file "$seeded" "the README project-init seeds, compared against"

written="$work/docs/backlog/README.md"
assert_file "$written" "the README the tool writes"
if ! cmp -s "$seeded" "$written"; then
  echo "FAIL: the converted README differs from the one project-init seeds" >&2
  diff "$seeded" "$written" >&2
  exit 1
fi
seed="$TOOLKIT_ROOT/scripts/seed/backlog-README.md"
assert_file "$seed" "the shared seed"
cmp -s "$seed" "$written" || { echo "FAIL: the converted README is not the seed file byte for byte" >&2; exit 1; }
if grep -q -F "Rules of our own" "$written"; then
  echo "FAIL: the old preamble was carried into the README" >&2
  exit 1
fi
grep -q -i 'preamble' "$report" || { echo "FAIL: the report does not say the old preamble was not carried over" >&2; cat "$report" >&2; exit 1; }
