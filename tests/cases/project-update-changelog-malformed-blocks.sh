#!/usr/bin/env bash
# Scenario: A malformed changelog record blocks.
# Requirement: Every run ends in one of three outcomes, and the exit code agrees.
# Change: record-what-each-version-asks (project-update, MODIFIED).
#
# SPECIFIED: a record with no kebab-case name, no changed, or a version that is
# not MAJOR.MINOR.PATCH above 1.0.0; a major with no ask; a minor or patch with
# one: BLOCKED, exit 2, the project unchanged.
# DERIVED: the bad record names a fragment the run does not cross, so it is the
# file and not the range that is checked; the stated reason names the
# changelog; the well-formed changelog of every run is a SUCCESS, so the bad
# record alone is what blocks.
#
# Executes the tool. Red until task 2.1 lands (state 1: the tool reports SUCCESS). All variants run before the case fails, so each is named.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Local arrangement (test-plan.md, Missing shared arrangement: the update
# fixture helpers and the changelog helpers). run.sh exports no variable for
# the update tool, tests/lib.sh holds no manifest reader, block builder or git
# fixture, and a test module imports from no other test module.
# shellcheck disable=SC2034 # cases running a copy of the toolkit invoke that copy's tool instead
PROJECT_UPDATE="$TOOLKIT_ROOT/scripts/project-update"
# require_update SCRIPT: the target-absent guard, so a missing tool (exit
# 127) is reported as absent and never read as any outcome.
require_update() {
  local s="$1"
  [ -f "$s" ] && return 0
  echo "FAIL: target absent — $s does not exist yet" >&2
  exit 1
}
# sha256_of: the SHA-256 digest of stdin, in lowercase hex.
sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum | awk '{print $1}'
  else
    shasum -a 256 | awk '{print $1}'
  fi
}
# frag_key FILE KEY: KEY's value in FILE's leading frontmatter, or nothing.
frag_key() {
  awk -v k="$2" '
    NR == 1 { if ($0 != "---") exit; next }
    $0 == "---" { exit }
    index($0, k ":") == 1 { v = substr($0, length(k) + 2); sub(/^[[:space:]]*/, "", v); sub(/[[:space:]]*$/, "", v); print v; exit }
  ' "$1" 2>/dev/null
}
# records [ROOT]: one line "<name> <target>" per record of ROOT's rules/manifest.
records() {
  awk '
    function flush() { if (n != "" || t != "") print n " " t; n = ""; t = "" }
    /^---[[:space:]]*$/ { flush(); next }
    /^name:/ { n = $0; sub(/^name:[[:space:]]*/, "", n); sub(/[[:space:]]*$/, "", n) }
    /^target:/ { t = $0; sub(/^target:[[:space:]]*/, "", t); sub(/[[:space:]]*$/, "", t) }
    END { flush() }
  ' "${1:-$TOOLKIT_ROOT}/rules/manifest" 2>/dev/null
}
# target_of NAME [ROOT]: NAME's target in ROOT's manifest, or nothing.
target_of() { records "${2:-$TOOLKIT_ROOT}" | awk -v n="$1" '$1 == n { print $2; exit }'; }
# fversion NAME [ROOT]: the version of ROOT's rules/NAME.md.
fversion() { frag_key "${2:-$TOOLKIT_ROOT}/rules/$1.md" version; }
# put_block_at FILE NAME VERSION TEXT: appends an untouched block to FILE.
put_block_at() {
  local f="$1" name="$2" ver="$3" text="$4" inner h
  mkdir -p "$(dirname "$f")"
  inner="$(printf '<!-- Generated. Do not edit inside this block — it is replaced on update.\n     Project-specific conventions belong outside the markers. -->\n%s' "$text")"
  h="$(printf '%s\n' "$inner" | sha256_of)"
  {
    printf '<!-- ai-toolkit:%s %s sha256:%s -->\n' "$name" "$ver" "$h"
    printf '%s\n' "$inner"
    printf '<!-- /ai-toolkit:%s -->\n' "$name"
  } >> "$f"
}
# put_block WORK NAME VERSION TEXT [ROOT]: appends to NAME's target under WORK
# a block at VERSION whose hash is the digest of what it holds (untouched).
put_block() {
  local work="$1" name="$2" ver="$3" text="$4" root="${5:-$TOOLKIT_ROOT}" t
  t="$(target_of "$name" "$root")"
  if [ -z "$t" ] || [ -z "$ver" ]; then
    echo "FAIL: fixture — no target or version for $name in $root/rules/manifest" >&2
    exit 1
  fi
  put_block_at "$work/$t" "$name" "$ver" "$text"
}
# put_others WORK ROOT SKIP...: each manifest record but those named, current.
put_others() {
  local work="$1" root="$2" n t s
  shift 2
  while read -r n t; do
    [ -n "$n" ] || continue
    for s in "$@"; do [ "$s" = "$n" ] && continue 2; done
    put_block "$work" "$n" "$(fversion "$n" "$root")" "current text of $n" "$root"
  done <<< "$(records "$root")"
}
# tree_sum DIR: every file and link under DIR, .git excluded, with its content
# or link target, so two calls compare the whole tree byte for byte.
tree_sum() {
  (cd "$1" && find . -path ./.git -prune -o \( -type f -o -type l \) -print | LC_ALL=C sort | while read -r f; do
    if [ -L "$f" ]; then printf 'L %s %s\n' "$f" "$(readlink "$f")"
    else printf 'F %s %s\n' "$f" "$(md5sum < "$f" | cut -d' ' -f1)"; fi
  done)
}
# assert_outcome REPORT CODE STATUS OUTCOME: the exit code and the stated outcome agree.
assert_outcome() {
  assert_exit "$2" "$3" "$4"
  grep -q -w -- "$4" "$1" || { echo "FAIL: the report does not state $4" >&2; cat "$1" >&2; exit 1; }
}
# git_fixture DIR: DIR is a repository with everything under it committed.
git_fixture() {
  git -C "$1" init -q >/dev/null 2>&1 || { echo "FAIL: fixture — git init failed in $1" >&2; exit 1; }
  git -C "$1" config user.email t@t.com
  git -C "$1" config user.name t
  git -C "$1" config commit.gpgsign false
  git -C "$1" add -A
  git -C "$1" commit -q -m fixture >/dev/null || { echo "FAIL: fixture — commit failed in $1" >&2; exit 1; }
}
# toolkit_copy DIR: rules/ and scripts/ of the toolkit under test, copied.
toolkit_copy() {
  mkdir -p "$1"
  cp -R "$TOOLKIT_ROOT/rules" "$1/rules" || exit 1
  cp -R "$TOOLKIT_ROOT/scripts" "$1/scripts" || exit 1
}
# set_version FILE VERSION: rewrites the `version:` in FILE's frontmatter.
set_version() {
  awk -v v="$2" 'NR == 1 && $0 == "---" { fm = 1; print; next } fm && $0 == "---" { fm = 0; print; next } fm && /^version:/ { print "version: " v; next } { print }' "$1" > "$1.new" && mv "$1.new" "$1"
  [ "$(frag_key "$1" version)" = "$2" ] || { echo "FAIL: fixture — the version of $1 was not set" >&2; exit 1; }
}
# Local arrangement for record-what-each-version-asks (test-plan.md, Missing
# shared arrangement: the changelog helpers).
# changelog_copy DIR: a toolkit copy whose rules/changelog is stdin, so the
# case depends on no shipped record.
changelog_copy() {
  toolkit_copy "$1"
  require_update "$1/scripts/project-update"
  cat > "$1/rules/changelog"
}
# beneath REPORT NAME: the indented lines directly beneath NAME's line, with
# their indentation taken off.
beneath() {
  awk -v n="$2:" '
    f { if ($0 !~ /^[[:space:]]/) exit; sub(/^[[:space:]]+/, ""); print; next }
    index($0, n) == 1 { f = 1 }
  ' "$1"
}
# assert_beneath REPORT NAME EXPECTED: NAME has a line, and the lines beneath
# it are exactly EXPECTED, which is empty where none is owed.
assert_beneath() {
  local got
  grep -q -E "^$2:" "$1" || { echo "FAIL: the report has no line for $2" >&2; cat "$1" >&2; exit 1; }
  got="$(beneath "$1" "$2")"
  if [ "$got" != "$3" ]; then
    echo "FAIL: beneath $2's line, expected:" >&2
    printf '%s\n' "$3" >&2
    echo "--- got:" >&2
    printf '%s\n' "$got" >&2
    echo "--- report:" >&2
    cat "$1" >&2
    exit 1
  fi
}
# refuse_text REPORT TEXT: the report nowhere holds TEXT.
refuse_text() {
  if grep -q -F -- "$2" "$1"; then
    echo "FAIL: the report holds '$2'" >&2
    cat "$1" >&2
    exit 1
  fi
}
# assert_tree DIR BEFORE MSG: DIR's tree_sum is BEFORE.
assert_tree() {
  local now
  now="$(tree_sum "$1")"
  if [ "$now" != "$2" ]; then
    echo "FAIL: $3 — the tree under $1 changed" >&2
    diff <(printf '%s\n' "$2") <(printf '%s\n' "$now") >&2
    exit 1
  fi
}
good='name: workstreams
version: 1.1.0
changed: a good record'

copy="$TESTDIR/copy"
printf '%s\n' "$good" | changelog_copy "$copy"
set_version "$copy/rules/workstreams.md" 1.1.0
n=0
failures=""

# variant LABEL RECORD: a run whose changelog holds the good record and RECORD.
variant() {
  local label="$1" record="$2" work before report status
  n=$((n + 1))
  work="$TESTDIR/work$n"
  report="$TESTDIR/report$n.txt"
  mkdir -p "$work"
  put_others "$work" "$copy" workstreams
  put_block "$work" workstreams 1.0.0 "an older text" "$copy"
  printf '%s\n---\n%s\n' "$good" "$record" > "$copy/rules/changelog"
  before="$(tree_sum "$work")"
  (cd "$work" && bash "$copy/scripts/project-update") >"$report" 2>&1
  status=$?
  if [ "$status" != 2 ] || ! grep -q -w BLOCKED "$report"; then
    failures="$failures  $label: exit $status, not BLOCKED"$'\n'
  elif [ "$(tree_sum "$work")" != "$before" ]; then
    failures="$failures  $label: the project changed"$'\n'
  elif ! grep -E '^Reason:' "$report" | grep -q -F 'changelog'; then
    failures="$failures  $label: the reason does not name the changelog"$'\n'
  fi
}

variant 'no name' 'version: 1.2.0
changed: a thing'
variant 'name not kebab-case' 'name: Not_Kebab
version: 1.2.0
changed: a thing'
variant 'no version' 'name: backlog
changed: a thing'
variant 'version 12' 'name: backlog
version: 12
changed: a thing'
variant 'version 1.2' 'name: backlog
version: 1.2
changed: a thing'
variant 'version v1.2.0' 'name: backlog
version: v1.2.0
changed: a thing'
variant 'version 1.0.0, not above it' 'name: backlog
version: 1.0.0
changed: a thing
ask: a step'
variant 'version 0.9.0, below it' 'name: backlog
version: 0.9.0
changed: a thing'
variant 'no changed' 'name: backlog
version: 1.2.0'
variant 'a major with no ask' 'name: backlog
version: 2.0.0
changed: a thing'
variant 'a minor with an ask' 'name: backlog
version: 1.2.0
changed: a thing
ask: a step'
variant 'a patch with an ask' 'name: backlog
version: 1.2.1
changed: a thing
ask: a step'

if [ -n "$failures" ]; then
  echo "FAIL: a malformed record did not block:" >&2
  printf '%s' "$failures" >&2
  exit 1
fi

printf '%s\n' "$good" > "$copy/rules/changelog"
control="$TESTDIR/control"
mkdir -p "$control"
put_others "$control" "$copy" workstreams
put_block "$control" workstreams 1.0.0 "an older text" "$copy"
(cd "$control" && bash "$copy/scripts/project-update") >"$TESTDIR/control.txt" 2>&1
assert_outcome "$TESTDIR/control.txt" 0 "$?" SUCCESS
assert_beneath "$TESTDIR/control.txt" workstreams '1.1.0: a good record'
