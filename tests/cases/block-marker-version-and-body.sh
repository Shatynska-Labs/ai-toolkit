#!/usr/bin/env bash
# Scenarios: The marker's version is the fragment's; A project's adopted
# version is readable (as revised).
# Requirements: A block's opening marker records its version and a hash of
# what was written (ADDED); Workflow rules reach a project as a versioned
# managed block (MODIFIED). Change: list-what-a-project-receives
# (project-bootstrap).
#
# SPECIFIED: for every block written, the version its opening line carries is
# the `version` in rules/<name>.md's frontmatter; the lines after the notice
# are that fragment's body, without frontmatter, byte for byte; the first
# lines inside are the notice stating the contents are generated and replaced
# on update and that project-specific text belongs outside the markers.
# DERIVED (operationalisation): the body is located as the last lines of the
# block, as many as the fragment's body has, and the notice as the lines
# before them, which must be non-empty and contain `generated`, `replaced`
# and `outside the markers` (case-insensitive) — the last from design.md
# decision 2's revised notice.
#
# Executes the tool. Red until tasks 1.1, 1.2 and 2.2 land.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Local arrangement (test-plan.md, Missing shared arrangement:
# manifest_records). manifest_records FILE: one line "<name> <target>" per
# record of a manifest in the flat form design.md decision 1 shows.
manifest_records() {
  awk '
    function flush() { if (n != "" || t != "") print n " " t; n = ""; t = "" }
    /^---[[:space:]]*$/ { flush(); next }
    /^name:/ { n = $0; sub(/^name:[[:space:]]*/, "", n); sub(/[[:space:]]*$/, "", n) }
    /^target:/ { t = $0; sub(/^target:[[:space:]]*/, "", t); sub(/[[:space:]]*$/, "", t) }
    END { flush() }
  ' "$1"
}

# Local arrangement (test-plan.md, Missing shared arrangement: block readers).
# block_body FILE NAME: the lines strictly between NAME's opening and closing
# markers, each with its newline.
block_body() {
  awk -v n="$2" '
    index($0, "<!-- /ai-toolkit:" n " -->") == 1 { exit }
    f { print }
    index($0, "<!-- ai-toolkit:" n " ") == 1 { f = 1 }
  ' "$1"
}
# marker_line FILE NAME: NAME's opening line in the form
# `<!-- ai-toolkit:NAME MAJOR.MINOR.PATCH sha256:<64 hex> -->`, or nothing.
marker_line() {
  grep -E "^<!-- ai-toolkit:$2 [0-9]+[.][0-9]+[.][0-9]+ sha256:[0-9a-f]{64} -->\$" "$1" 2>/dev/null
}

# Local arrangement (test-plan.md, Missing shared arrangement: fragment
# readers). tests/lib.sh's fragment_version reads development-workflow.md
# only; these read any fragment.
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

manifest="$TOOLKIT_ROOT/rules/manifest"
assert_file "$manifest" "target absent — rules/manifest"
work="$TESTDIR/work"
mkdir -p "$work"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"
n=0
while read -r name target; do
  [ -n "$name" ] || continue
  n=$((n + 1))
  frag="$TOOLKIT_ROOT/rules/$name.md"
  f="$work/$target"
  assert_file "$frag" "the fragment $name"
  line="$(marker_line "$f" "$name")"
  [ -n "$line" ] || { echo "FAIL: $target has no $name marker with a version and hash" >&2; exit 1; }
  want="$(frag_key "$frag" version)"
  got="$(printf '%s\n' "$line" | awk '{print $3}')"
  if [ -z "$want" ] || [ "$want" != "$got" ]; then
    echo "FAIL: $name's marker carries '$got', the fragment's version is '$want'" >&2; exit 1
  fi
  frag_body "$frag" > "$TESTDIR/$name.expected"
  block_body "$f" "$name" > "$TESTDIR/$name.block"
  bl="$(grep -c '' "$TESTDIR/$name.expected")"
  al="$(grep -c '' "$TESTDIR/$name.block")"
  [ "$bl" -gt 0 ] || { echo "FAIL: the fragment $name has an empty body; the comparison would be vacuous" >&2; exit 1; }
  [ "$al" -gt "$bl" ] || { echo "FAIL: $name's block has no notice before the body ($al lines, body $bl)" >&2; exit 1; }
  tail -n "$bl" "$TESTDIR/$name.block" > "$TESTDIR/$name.actual"
  if ! cmp -s "$TESTDIR/$name.expected" "$TESTDIR/$name.actual"; then
    echo "FAIL: $name's block does not end with the fragment's body byte for byte" >&2
    diff "$TESTDIR/$name.expected" "$TESTDIR/$name.actual" | head -n 20 >&2
    exit 1
  fi
  head -n $((al - bl)) "$TESTDIR/$name.block" > "$TESTDIR/$name.notice"
  for w in generated replaced 'outside the markers'; do
    grep -q -i -F -- "$w" "$TESTDIR/$name.notice" || { echo "FAIL: $name's notice does not say '$w':" >&2; cat "$TESTDIR/$name.notice" >&2; exit 1; }
  done
done <<< "$(manifest_records "$manifest")"
[ "$n" -gt 0 ] || { echo "FAIL: target absent — the manifest lists no record" >&2; exit 1; }
