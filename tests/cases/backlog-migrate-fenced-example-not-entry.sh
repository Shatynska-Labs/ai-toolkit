#!/usr/bin/env bash
# Scenario: The seeded preamble's example is not an entry.
# Requirement: The tool converts a single-file backlog into the directory.
# Change: one-file-per-backlog-entry (backlog-migration, ADDED).
#
# SPECIFIED: a preamble showing the example entry `## `change-name`` inside a
# fence, followed by two entries, converts to the README and exactly two
# entry files, and no change-name.md.
# DERIVED (fixture): the preamble is written here in the shape the seeded
# file had before this change (a fenced example with list fields and a
# `high` Priority), not taken from that file, which this pass cannot read.
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
assert_file_absent "$work/docs/backlog/change-name.md" "the fenced example is not an entry"
# shellcheck disable=SC2012 # names are the test's own fixture names, plain ASCII
listing="$(ls -A "$work/docs/backlog" | sort | tr '\n' ' ')"
if [ "$listing" != "README.md first-entry.md second-entry.md " ]; then
  echo "FAIL: docs/backlog/ should hold the README and exactly two entries, holds: $listing" >&2
  exit 1
fi
