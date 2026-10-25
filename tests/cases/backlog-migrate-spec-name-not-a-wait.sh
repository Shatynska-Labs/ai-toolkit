#!/usr/bin/env bash
# Scenario: A specification's name is not a wait.
# Requirement: Each entry's fields are mapped into frontmatter, and nothing
# is dropped. Change: one-file-per-backlog-entry (backlog-migration, ADDED).
#
# SPECIFIED: Waits on naming `project-bootstrap`, where no entry or change has
# that name, does not put project-bootstrap in waits_on; the value is kept as
# waits_for.
# DERIVED (fixture): a specification of that name exists under
# openspec/specs/, as in the projects the scenario describes, so the tool is
# shown not to count a specification as a known name.
# DERIVED (tolerance): waits_on may be absent or `[]`; only its holding the
# name fails.
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
mkdir -p "$work/openspec/specs/project-bootstrap"
echo "# project-bootstrap" > "$work/openspec/specs/project-bootstrap/spec.md"
new_repo "$work" <<'BACKLOG'
# Backlog

## `seed-a-file`

What it is and why.

- **Kind**: change, it owes a delta.
- **Waits on**: `project-bootstrap`
BACKLOG

(cd "$work" && bash "$MIGRATE") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"
f="$work/docs/backlog/seed-a-file.md"
assert_file "$f"
case "$(fm_value "$f" waits_on)" in
  *project-bootstrap*) echo "FAIL: a specification's name became a wait: $(fm_value "$f" waits_on)" >&2; exit 1 ;;
esac
case "$(fm_value "$f" waits_for)" in
  \"*project-bootstrap*\") ;;
  *) echo "FAIL: the value is not kept as a quoted waits_for: $(fm_value "$f" waits_for)" >&2; exit 1 ;;
esac
