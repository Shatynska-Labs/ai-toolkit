#!/usr/bin/env bash
# Scenario: A version rise carries its changelog record.
# Requirement: The fragment's version increments when its body changes.
# Change: record-what-each-version-asks (project-bootstrap, MODIFIED).
#
# SPECIFIED: for a fragment in rules/ carrying a version above 1.0.0,
# rules/changelog holds exactly one record of that fragment at that version,
# every major from 2.0.0 up to that version has a record, and every record names
# a fragment in rules/ at a version no higher than that fragment's.
# DERIVED (operationalisation): "that fragment" is rules/<name>.md and a version
# is read from its frontmatter; versions compare numerically by part.
#
# Static read (third situation); the check runs over fixture directories first.
# Red until task 1.1 lands (state 2: rules/changelog is absent).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Local arrangement (test-plan.md, Missing shared arrangement: the changelog
# readers). tests/lib.sh's fragment_version reads development-workflow.md only.
# frag_key FILE KEY: KEY's value in FILE's leading frontmatter, or nothing.
frag_key() {
  awk -v k="$2" '
    NR == 1 { if ($0 != "---") exit; next }
    $0 == "---" { exit }
    index($0, k ":") == 1 { v = substr($0, length(k) + 2); sub(/^[[:space:]]*/, "", v); sub(/[[:space:]]*$/, "", v); print v; exit }
  ' "$1" 2>/dev/null
}
# changelog_records FILE: one line "<name> <version>" per record.
changelog_records() {
  awk '
    function flush() { if (n != "" || v != "") print n " " v; n = ""; v = "" }
    /^---[[:space:]]*$/ { flush(); next }
    /^name:/ { n = $0; sub(/^name:[[:space:]]*/, "", n); sub(/[[:space:]]*$/, "", n) }
    /^version:/ { v = $0; sub(/^version:[[:space:]]*/, "", v); sub(/[[:space:]]*$/, "", v) }
    END { flush() }
  ' "$1"
}
# version_above A B: A is numerically above B.
version_above() {
  awk -v a="$1" -v b="$2" 'BEGIN {
    split(a, x, "."); split(b, y, ".")
    for (i = 1; i <= 3; i++) { if (x[i] + 0 > y[i] + 0) exit 0; if (x[i] + 0 < y[i] + 0) exit 1 }
    exit 1 }'
}

check_rules() {
  local dir="$1" f n v m recs fv
  [ -f "$dir/changelog" ] || { echo "[absent] rules/changelog is absent" >&2; return 1; }
  recs="$(changelog_records "$dir/changelog")"
  for f in "$dir"/*.md; do
    n="${f##*/}"; n="${n%.md}"
    v="$(frag_key "$f" version)"
    [ -n "$v" ] || continue
    version_above "$v" 1.0.0 || continue
    [ "$(printf '%s\n' "$recs" | grep -c -x -F "$n $v")" = 1 ] || { echo "[one-record] $n $v does not have exactly one record" >&2; return 1; }
    m=2
    while [ "$m" -le "${v%%.*}" ]; do
      printf '%s\n' "$recs" | grep -q -x -F "$n $m.0.0" || { echo "[every-major] $n has no record of $m.0.0" >&2; return 1; }
      m=$((m + 1))
    done
  done
  while read -r n v; do
    [ -n "$n" ] || continue
    fv="$(frag_key "$dir/$n.md" version)"
    [ -n "$fv" ] || { echo "[names-fragment] the record $n $v names no versioned fragment" >&2; return 1; }
    if version_above "$v" "$fv"; then echo "[no-higher] the record $n $v is above the fragment's $fv" >&2; return 1; fi
  done <<< "$recs"
  return 0
}
expect() {  # pass|TAG DIR
  local out st
  out="$(check_rules "$2" 2>&1)"; st=$?
  if [ "$1" = pass ]; then [ "$st" -eq 0 ] && return 0
  else [ "$st" -eq 1 ] && case "$out" in *"[$1]"*) return 0 ;; esac
  fi
  echo "FAIL: discriminator — fixture expected $1, check returned $st: $out" >&2
  exit 1
}
record() { printf 'name: %s\nversion: %s\nchanged: a thing\n' "$1" "$2"; }
# mkfx DIR A_VERSION: a at A_VERSION, b at 1.0.0, and no changelog.
mkfx() {
  mkdir -p "$1"
  printf '# rules\n' > "$1/README.md"
  printf -- '---\nkind: standing-constraint\nversion: %s\n---\nA.\n' "$2" > "$1/a.md"
  printf -- '---\nkind: standing-constraint\nversion: 1.0.0\n---\nB.\n' > "$1/b.md"
}
# with DIR A_VERSION NAME VERSION...: a fixture whose changelog holds those records.
with() {
  local d="$1" first=1
  mkfx "$d" "$2"
  shift 2
  : > "$d/changelog"
  while [ "$#" -gt 0 ]; do
    [ "$first" = 1 ] || printf -- '---\n' >> "$d/changelog"
    first=0
    record "$1" "$2" >> "$d/changelog"
    shift 2
  done
}
with "$TESTDIR/ok" 2.1.0 a 2.0.0 a 2.1.0; expect pass "$TESTDIR/ok"
with "$TESTDIR/floor" 1.0.0 b 1.0.0; rm "$TESTDIR/floor/changelog"; : > "$TESTDIR/floor/changelog"; expect pass "$TESTDIR/floor"
mkfx "$TESTDIR/nofile" 2.0.0; expect absent "$TESTDIR/nofile"
with "$TESTDIR/norecord" 2.2.0 a 2.0.0 a 2.1.0; expect one-record "$TESTDIR/norecord"
with "$TESTDIR/twice" 2.1.0 a 2.0.0 a 2.1.0 a 2.1.0; expect one-record "$TESTDIR/twice"
with "$TESTDIR/gap" 3.1.0 a 2.0.0 a 3.1.0; expect every-major "$TESTDIR/gap"
with "$TESTDIR/stray" 2.0.0 a 2.0.0 c 1.1.0; expect names-fragment "$TESTDIR/stray"
with "$TESTDIR/high" 1.9.0 a 1.9.0 a 1.10.0; expect no-higher "$TESTDIR/high"

check_rules "$TOOLKIT_ROOT/rules" || exit 1
