#!/usr/bin/env bash
# Scenario: A block not written prints no record.
# Requirement: A run says what each version it crossed asks.
# Change: record-what-each-version-asks (project-update, ADDED).
#
# SPECIFIED: a block below a recorded major version that is edited, ahead,
# malformed or current has no changelog line; the Attention: line is unchanged
# by the lines printed for another block.
# DERIVED: `below a recorded major` with `ahead` and `current` is arranged with
# the record above the fragment's own version, the only way the two can hold
# together; an absent block is added from the requirement's "a block it did not
# replace or convert"; a control block in each run prints, so the silence
# belongs to the block left and not to a tool that prints nothing.
#
# Executes the tool. Red until task 2.2 lands (state 1, on the control).
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
# edit_inside FILE NAME NEW: replaces the last line inside NAME's block with NEW.
edit_inside() {
  awk -v n="$2" -v new="$3" '
    { lines[NR] = $0 }
    index($0, "<!-- /ai-toolkit:" n " -->") == 1 && !c { c = NR }
    END { for (i = 1; i <= NR; i++) print (i == c - 1 ? new : lines[i]) }
  ' "$1" > "$1.edit" && cat "$1.edit" > "$1" && rm -f "$1.edit"
}
copy="$TESTDIR/copy"
changelog_copy "$copy" <<'EOF'
name: workstreams
version: 2.0.0
changed: THE-RECORD
ask: THE-STEP
---
name: backlog
version: 1.1.0
changed: the control minor
EOF
set_version "$copy/rules/backlog.md" 1.1.0

# arrange STATE FRAGMENT_VERSION: a project whose backlog is the control and
# whose workstreams block is left in STATE; prints the project's path.
arrange() {
  local work="$TESTDIR/$1"
  set_version "$copy/rules/workstreams.md" "$2"
  mkdir -p "$work"
  put_others "$work" "$copy" workstreams backlog
  put_block "$work" backlog 1.0.0 "an older text" "$copy"
  printf '%s\n' "$work"
}
check() {  # WORK STATE
  local report="$TESTDIR/$2.txt"
  (cd "$1" && bash "$copy/scripts/project-update") >"$report" 2>&1
  assert_outcome "$report" 0 "$?" SUCCESS
  refuse_text "$report" "THE-RECORD"
  refuse_text "$report" "THE-STEP"
  assert_beneath "$report" backlog '1.1.0: the control minor'
}

work="$(arrange edited 2.0.0)"
put_block "$work" workstreams 1.0.0 "an older text" "$copy"
edit_inside "$work/$(target_of workstreams "$copy")" workstreams "a line the project changed"
check "$work" edited
[ "$(grep -E '^Attention:' "$TESTDIR/edited.txt")" = "Attention: workstreams" ] || { echo "FAIL: expected one line 'Attention: workstreams'" >&2; cat "$TESTDIR/edited.txt" >&2; exit 1; }

work="$(arrange malformed 2.0.0)"
put_block "$work" workstreams 1.0.0 "first" "$copy"
put_block "$work" workstreams 1.0.0 "second" "$copy"
check "$work" malformed

work="$(arrange ahead 1.0.0)"
put_block "$work" workstreams 1.5.0 "a newer text" "$copy"
check "$work" ahead

work="$(arrange current 1.5.0)"
put_block "$work" workstreams 1.5.0 "the text" "$copy"
check "$work" current

work="$(arrange absent 2.0.0)"
check "$work" absent
