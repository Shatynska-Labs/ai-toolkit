#!/usr/bin/env bash
# Scenario: An old block blocks until chosen.
# Requirement: A project states its workflow where its block predates the choice
# Change: add-a-direct-workflow-variant (project-update, ADDED).
#
# SPECIFIED: no --workflow, development-workflow at 1.0.0: BLOCKED, the report names --workflow full and --workflow direct, and no file changes, including a stale backlog block.
# DERIVED: workstreams is seeded current; what each flag does is not asserted (test-plan.md, deliberately untested).
#
# Executes the tool. Red until the variants land (state 2: rules/development-workflow-direct.md and the manifest's alternative are absent, so require_variants stops the case and its assertions are not yet exercised).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Local arrangement (test-plan.md, Missing shared arrangement: PROJECT_UPDATE
# and the update fixture helpers). run.sh exports no variable for the update
# tool, tests/lib.sh holds no manifest reader, block builder or git fixture,
# and a test module imports from no other test module.
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
# frag_body FILE: everything after the frontmatter's closing line.
frag_body() {
  awk 'NR == 1 && $0 == "---" { f = 1; next } f == 1 && $0 == "---" { f = 2; next } f == 2 { print }' "$1"
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
# lower_version V: a MAJOR.MINOR.PATCH numerically below V.
lower_version() {
  printf '%s\n' "$1" | awk -F. '{
    if ($3 > 0) print $1 "." $2 "." ($3 - 1)
    else if ($2 > 0) print $1 "." ($2 - 1) ".0"
    else if ($1 > 0) print ($1 - 1) ".9.0"
    else exit 1 }'
}
# block_body FILE NAME: the lines strictly between NAME's opening and closing
# markers, each with its newline.
block_body() {
  awk -v n="$2" '
    index($0, "<!-- /ai-toolkit:" n " -->") == 1 { exit }
    f { print }
    index($0, "<!-- ai-toolkit:" n " ") == 1 { f = 1 }
  ' "$1"
}
# block_lines FILE NAME: NAME's lines from opening to closing marker, both included.
block_lines() {
  awk -v n="$2" '
    index($0, "<!-- ai-toolkit:" n " ") == 1 { f = 1 }
    f { print }
    f && index($0, "<!-- /ai-toolkit:" n " -->") == 1 { exit }
  ' "$1"
}
# marker_line FILE NAME: NAME's opening line in the hashed form, or nothing.
marker_line() {
  grep -E "^<!-- ai-toolkit:$2 [0-9]+[.][0-9]+[.][0-9]+ sha256:[0-9a-f]{64} -->\$" "$1" 2>/dev/null
}
# marker_version FILE NAME: the version NAME's hashed marker carries, or nothing.
marker_version() { marker_line "$1" "$2" | head -n 1 | awk '{print $3}'; }
# hash_ok FILE NAME: NAME's marker hash equals the digest of its body.
hash_ok() {
  local line want got
  line="$(marker_line "$1" "$2")"
  [ -n "$line" ] || return 1
  want="$(printf '%s\n' "$line" | sed -E 's/.* sha256:([0-9a-f]{64}) -->$/\1/')"
  got="$(block_body "$1" "$2" | sha256_of)"
  [ "$want" = "$got" ]
}
# put_block WORK NAME VERSION TEXT [ROOT]: appends to NAME's target under WORK
# a block at VERSION whose hash is the digest of what it holds (untouched).
put_block() {
  local work="$1" name="$2" ver="$3" text="$4" root="${5:-$TOOLKIT_ROOT}" t f inner h
  t="$(target_of "$name" "$root")"
  if [ -z "$t" ] || [ -z "$ver" ]; then
    echo "FAIL: fixture — no target or version for $name in $root/rules/manifest" >&2
    exit 1
  fi
  f="$work/$t"
  mkdir -p "$(dirname "$f")"
  inner="$(printf '<!-- Generated. Do not edit inside this block — it is replaced on update.\n     Project-specific conventions belong outside the markers. -->\n%s' "$text")"
  h="$(printf '%s\n' "$inner" | sha256_of)"
  {
    printf '<!-- ai-toolkit:%s %s sha256:%s -->\n' "$name" "$ver" "$h"
    printf '%s\n' "$inner"
    printf '<!-- /ai-toolkit:%s -->\n' "$name"
  } >> "$f"
}
# seed_all WORK current|stale [ROOT]: every manifest record's block, untouched,
# at its fragment's version or below it.
seed_all() {
  local work="$1" mode="$2" root="${3:-$TOOLKIT_ROOT}" n t v count=0
  while read -r n t; do
    [ -n "$n" ] || continue
    v="$(fversion "$n" "$root")"
    if [ "$mode" = stale ]; then
      v="$(lower_version "$v")" || { echo "FAIL: fixture — no version below $n's" >&2; exit 1; }
    fi
    put_block "$work" "$n" "$v" "the $mode text of $n" "$root"
    count=$((count + 1))
  done <<< "$(records "$root")"
  [ "$count" -gt 0 ] || { echo "FAIL: target absent — $root/rules/manifest lists no record" >&2; exit 1; }
}
# edit_inside FILE NAME NEW: replaces the last line inside NAME's block with NEW.
edit_inside() {
  awk -v n="$2" -v new="$3" '
    { lines[NR] = $0 }
    index($0, "<!-- /ai-toolkit:" n " -->") == 1 && !c { c = NR }
    END { for (i = 1; i <= NR; i++) print (i == c - 1 ? new : lines[i]) }
  ' "$1" > "$1.edit" && cat "$1.edit" > "$1" && rm -f "$1.edit"
}
# rline REPORT NAME: the report's line for record NAME.
rline() { grep -E "^$2:" "$1" | head -n 1; }
# expect_line REPORT NAME WORD...: NAME's line states each WORD (any case).
expect_line() {
  local report="$1" name="$2" line w
  shift 2
  line="$(rline "$report" "$name")"
  [ -n "$line" ] || { echo "FAIL: the report has no line for $name" >&2; cat "$report" >&2; exit 1; }
  for w in "$@"; do
    printf '%s\n' "$line" | grep -q -i -F -- "$w" || { echo "FAIL: the $name line does not state '$w': $line" >&2; exit 1; }
  done
}
# refuse_line REPORT NAME WORD: NAME's line does not state WORD (any case).
refuse_line() {
  if rline "$1" "$2" | grep -q -i -F -- "$3"; then
    echo "FAIL: the $2 line states '$3': $(rline "$1" "$2")" >&2
    exit 1
  fi
}
# tree_sum DIR: every file and link under DIR, .git excluded, with its content
# or link target, so two calls compare the whole tree byte for byte.
tree_sum() {
  (cd "$1" && find . -path ./.git -prune -o \( -type f -o -type l \) -print | LC_ALL=C sort | while read -r f; do
    if [ -L "$f" ]; then printf 'L %s %s\n' "$f" "$(readlink "$f")"
    else printf 'F %s %s\n' "$f" "$(md5sum < "$f" | cut -d' ' -f1)"; fi
  done)
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
# shellcheck disable=SC2034 # read by the legacy cases only
# V12_BLOCK: the workflow block a project adopted before 1.0.0.
V12_BLOCK='<!-- ai-toolkit:development-workflow v12 -->
<!-- Generated. Do not edit inside this block — it is replaced on update.
     Project-specific conventions belong below the closing marker. -->
the text a project adopted at v12
<!-- /ai-toolkit:development-workflow -->'
# Local arrangement for add-a-direct-workflow-variant (test-plan.md, Missing
# shared arrangement: the variant helpers).
# shellcheck disable=SC2034 # each case reads the names it needs
FULL=development-workflow
# shellcheck disable=SC2034 # each case reads the names it needs
DIRECT=development-workflow-direct
# require_variants: the target-absent guard for the second fragment and
# the manifest's `alternative`, so a toolkit without them reads as absent.
require_variants() {
  local root="$TOOLKIT_ROOT"
  [ -f "$root/rules/$DIRECT.md" ] || { echo "FAIL: target absent — rules/$DIRECT.md does not exist yet" >&2; exit 1; }
  grep -q -E "^alternative:[[:space:]]*${DIRECT}[[:space:]]*\$" "$root/rules/manifest" || { echo "FAIL: target absent — rules/manifest names no alternative $DIRECT" >&2; exit 1; }
}
# put_block_at FILE NAME VERSION TEXT: appends an untouched block to FILE; for
# the alternative, which no manifest record's name reaches through put_block.
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
# put_others WORK [ROOT]: the backlog and workstreams blocks, current.
put_others() {
  put_block "$1" backlog "$(fversion backlog "${2:-$TOOLKIT_ROOT}")" "current" "${2:-$TOOLKIT_ROOT}"
  put_block "$1" workstreams "$(fversion workstreams "${2:-$TOOLKIT_ROOT}")" "current" "${2:-$TOOLKIT_ROOT}"
}
# open_count FILE NAME: how many opening markers of exactly NAME FILE holds.
open_count() { grep -c -F "<!-- ai-toolkit:$2 " "$1"; }
# assert_block_is FILE NAME [ROOT]: FILE holds one NAME block at the fragment's
# version, its hash the digest of its lines, ending with the fragment's body.
assert_block_is() {
  local f="$1" name="$2" root="${3:-$TOOLKIT_ROOT}" n
  [ "$(open_count "$f" "$name")" = 1 ] || { echo "FAIL: $f does not hold exactly one $name block" >&2; cat "$f" >&2; exit 1; }
  [ "$(marker_version "$f" "$name")" = "$(fversion "$name" "$root")" ] || { echo "FAIL: $name's marker does not carry $(fversion "$name" "$root")" >&2; exit 1; }
  hash_ok "$f" "$name" || { echo "FAIL: $name's hash is not the digest of its lines" >&2; exit 1; }
  frag_body "$root/rules/$name.md" > "$TESTDIR/expected.body"
  block_body "$f" "$name" > "$TESTDIR/actual.block"
  n="$(grep -c '' "$TESTDIR/expected.body")"
  [ "$n" -gt 0 ] || { echo "FAIL: the fragment $name has an empty body" >&2; exit 1; }
  tail -n "$n" "$TESTDIR/actual.block" > "$TESTDIR/actual.body"
  cmp -s "$TESTDIR/expected.body" "$TESTDIR/actual.body" || { echo "FAIL: $name's block does not end with its fragment's body" >&2; exit 1; }
}
# assert_absent_block FILE NAME: FILE holds no opening marker of exactly NAME.
assert_absent_block() {
  [ "$(open_count "$1" "$2")" = 0 ] || { echo "FAIL: $1 holds a $2 block" >&2; exit 1; }
}
# variant_line REPORT: the first line naming either variant as its record.
variant_line() { grep -E "^($FULL|$DIRECT):" "$1" | head -n 1; }
# assert_names_both LINE: LINE names both variants. The direct name holds the
# full name as a prefix, so the full name is looked for with the direct one
# taken out.
assert_names_both() {
  case "$1" in *"$DIRECT"*) ;; *) echo "FAIL: the line does not name $DIRECT: $1" >&2; exit 1 ;; esac
  case "${1//$DIRECT/}" in *"$FULL"*) ;; *) echo "FAIL: the line does not name $FULL: $1" >&2; exit 1 ;; esac
}
# outside_block FILE NAME: every line before NAME's opening marker, a
# separator, and every line after its closing marker.
outside_block() {
  local o c
  o="$(grep -n -F "<!-- ai-toolkit:$2 " "$1" | head -n 1 | cut -d: -f1)"
  c="$(grep -n -F "<!-- /ai-toolkit:$2 -->" "$1" | head -n 1 | cut -d: -f1)"
  head -n $((o - 1)) "$1"
  printf '=== between ===\n'
  tail -n +$((c + 1)) "$1"
}
# assert_names_choice REPORT: the report names both values of --workflow.
assert_names_choice() {
  assert_contains "$1" "--workflow full" "the report names the choice of full"
  assert_contains "$1" "--workflow direct" "the report names the choice of direct"
}
# higher_major V: a version one major above V.
higher_major() { printf '%s\n' "$1" | awk -F. '{ print ($1 + 1) ".0.0" }'; }
require_variants
work="$TESTDIR/work"
mkdir -p "$work"
put_block "$work" "$FULL" 1.0.0 "the text at 1.0.0"
put_block "$work" backlog "$(lower_version "$(fversion backlog)")" "an older backlog"
put_block "$work" workstreams "$(fversion workstreams)" "current"
before="$(tree_sum "$work")"
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
assert_outcome "$TESTDIR/report.txt" 2 "$?" BLOCKED
assert_names_choice "$TESTDIR/report.txt"
assert_tree "$work" "$before" "an owed choice"
