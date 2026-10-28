#!/usr/bin/env bash
# Scenario: The marker's hash is the hash of what lies between the markers.
# Requirement: A block's opening marker records its version and a hash of
# what was written. Change: list-what-a-project-receives (project-bootstrap,
# ADDED).
#
# SPECIFIED: for every block the tool writes, the SHA-256 digest of the lines
# strictly between its opening and closing lines, each with its newline,
# equals the 64-hex-digit hash its opening line carries.
# DERIVED (scope): every record of rules/manifest, written into an empty
# directory, is checked.
#
# Executes the tool; the local readers are checked on a specimen block first,
# so a pass cannot come from a reader that reads nothing. Red until task 2.2
# lands (state 1: the marker carries no hash).
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

# Local arrangement (test-plan.md, Missing shared arrangement: sha256_of).
# sha256_of: the SHA-256 digest of stdin, in lowercase hex.
sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum | awk '{print $1}'
  else
    shasum -a 256 | awk '{print $1}'
  fi
}

hash_ok() {  # FILE NAME: the marker's hash equals the digest of the body
  local line want got
  line="$(marker_line "$1" "$2")"
  [ -n "$line" ] || { echo "no marker for $2 with a version and hash in $1" >&2; return 1; }
  want="$(printf '%s\n' "$line" | sed -E 's/.* sha256:([0-9a-f]{64}) -->$/\1/')"
  got="$(block_body "$1" "$2" | sha256_of)"
  [ "$want" = "$got" ] || { echo "$2: marker hash $want, digest of the lines between the markers $got" >&2; return 1; }
}
spec="$TESTDIR/specimen.md"
inner="$(printf 'notice line\nbody line one\nbody line two\n' | sha256_of)"
printf 'before\n<!-- ai-toolkit:demo 1.0.0 sha256:%s -->\nnotice line\nbody line one\nbody line two\n<!-- /ai-toolkit:demo -->\nafter\n' "$inner" > "$spec"
hash_ok "$spec" demo || { echo "FAIL: discriminator — the readers reject a correct specimen" >&2; exit 1; }
sed 's/^body line two$/body line 2/' "$spec" > "$spec.bad"
if hash_ok "$spec.bad" demo 2>/dev/null; then echo "FAIL: discriminator — the readers accept an edited specimen" >&2; exit 1; fi

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
  hash_ok "$work/$target" "$name" || { echo "FAIL: the block $name in $target" >&2; exit 1; }
done <<< "$(manifest_records "$manifest")"
[ "$n" -gt 0 ] || { echo "FAIL: target absent — the manifest lists no record" >&2; exit 1; }
