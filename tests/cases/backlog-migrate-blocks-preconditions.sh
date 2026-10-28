#!/usr/bin/env bash
# Requirement text, not a scenario of its own: the BLOCKED preconditions the
# scenarios do not name — the target not inside a git repository;
# docs/backlog.md absent, not a regular file (a symbolic link), or not
# tracked; two entries carrying one name. Accounted under the requirement Every run ends in one of
# three outcomes, and the exit code agrees.
# Change: one-file-per-backlog-entry (backlog-migration, ADDED).
#
# SPECIFIED: each reports BLOCKED, exits 2, and writes nothing.
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

backlog_text() {
  cat <<'BACKLOG'
# Backlog

## `alpha-change`

What alpha is and why.
BACKLOG
}

# expect_blocked LABEL WORK [TOOL]
expect_blocked() {
  local label="$1" work="$2" tool="${3:-$MIGRATE}" report="$TESTDIR/report-$1.txt" status
  (cd "$work" && bash "$tool") >"$report" 2>&1
  status=$?
  assert_exit 2 "$status" "$label blocks"
  grep -q -w BLOCKED "$report" || { echo "FAIL: the report does not state BLOCKED ($label)" >&2; cat "$report" >&2; exit 1; }
  assert_file_absent "$work/docs/backlog" "nothing written ($label)"
}

# Not inside a git repository.
work="$TESTDIR/no-git"
mkdir -p "$work/docs"
backlog_text > "$work/docs/backlog.md"
expect_blocked not-a-repository "$work"
[ "$(ls -A "$work/docs")" = backlog.md ] || { echo "FAIL: docs/ changed outside a repository" >&2; exit 1; }

# docs/backlog.md absent.
work="$TESTDIR/absent"
mkdir -p "$work"
printf 'x\n' > "$work/other.txt"
git -C "$work" init -q >/dev/null 2>&1
git -C "$work" -c user.email=t@t.com -c user.name=t add -A
git -C "$work" -c user.email=t@t.com -c user.name=t commit -q -m fixture
expect_blocked absent "$work"

# Untracked.
work="$TESTDIR/untracked"
mkdir -p "$work/docs"
printf 'x\n' > "$work/other.txt"
git -C "$work" init -q >/dev/null 2>&1
git -C "$work" -c user.email=t@t.com -c user.name=t add other.txt
git -C "$work" -c user.email=t@t.com -c user.name=t commit -q -m fixture
backlog_text > "$work/docs/backlog.md"
sum="$(md5sum "$work/docs/backlog.md" | awk '{print $1}')"
expect_blocked untracked "$work"
assert_untouched "$work" "$sum"

# Not a regular file: a committed symbolic link to the backlog text.
work="$TESTDIR/link"
mkdir -p "$work/docs"
backlog_text > "$work/real-backlog.md"
ln -s ../real-backlog.md "$work/docs/backlog.md"
git -C "$work" init -q >/dev/null 2>&1
git -C "$work" -c user.email=t@t.com -c user.name=t add -A
git -C "$work" -c user.email=t@t.com -c user.name=t commit -q -m fixture
expect_blocked symbolic-link "$work"
[ -L "$work/docs/backlog.md" ] || { echo "FAIL: the link at docs/backlog.md was replaced" >&2; exit 1; }

# Two entries carrying one name.
work="$TESTDIR/duplicate"
new_repo "$work" <<'BACKLOG'
# Backlog

## `alpha-change`

The first.

## `alpha-change`

The second.
BACKLOG
sum="$(md5sum "$work/docs/backlog.md" | awk '{print $1}')"
expect_blocked duplicate-name "$work"
assert_untouched "$work" "$sum"

