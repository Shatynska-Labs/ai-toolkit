#!/usr/bin/env bash
# Scenario: Every listed fragment exists with a kind and a semantic version.
# Requirement: A project receives exactly the blocks the manifest lists.
# Change: list-what-a-project-receives (project-bootstrap, ADDED).
#
# SPECIFIED: for every record in rules/manifest, rules/<name>.md exists and its
# frontmatter carries a `kind` and a `version` of the form MAJOR.MINOR.PATCH.
# DERIVED (operationalisation): MAJOR.MINOR.PATCH is read as three dot-joined
# runs of digits and nothing else.
#
# Static read (third situation); the check runs over fixture roots first.
# Red until tasks 1.1 and 1.2 land (state 2: the manifest is absent).
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

check_root() {
  local root="$1" name _target f v k bad=0 any=0
  [ -f "$root/rules/manifest" ] || { echo "ABSENT: $root/rules/manifest" >&2; return 2; }
  while read -r name _target; do
    [ -n "$name" ] || continue
    any=1
    f="$root/rules/$name.md"
    [ -f "$f" ] || { echo "[exists] rules/$name.md is absent" >&2; bad=1; continue; }
    k="$(frag_key "$f" kind)"
    [ -n "$k" ] || { echo "[kind] rules/$name.md declares no kind" >&2; bad=1; }
    v="$(frag_key "$f" version)"
    printf '%s\n' "$v" | grep -q -E '^[0-9]+[.][0-9]+[.][0-9]+$' || { echo "[semver] rules/$name.md version is '$v'" >&2; bad=1; }
  done <<< "$(manifest_records "$root/rules/manifest")"
  [ "$any" = 1 ] || { echo "ABSENT: the manifest lists no record" >&2; return 2; }
  return "$bad"
}
expect() {  # pass|TAG ROOT
  local out st
  out="$(check_root "$2" 2>&1)"; st=$?
  if [ "$1" = pass ]; then [ "$st" -eq 0 ] && return 0
  else [ "$st" -eq 1 ] && case "$out" in *"[$1]"*) return 0 ;; esac
  fi
  echo "FAIL: discriminator — fixture expected $1, check returned $st: $out" >&2
  exit 1
}
mkroot() {  # DIR VERSION KINDLINE
  mkdir -p "$1/rules"
  printf '%s\n' 'name: alpha' 'target: AGENTS.md' '---' 'name: beta' 'target: docs/beta/AGENTS.md' > "$1/rules/manifest"
  printf -- '---\nkind: standing-constraint\nversion: 1.0.0\n---\nAlpha.\n' > "$1/rules/alpha.md"
  printf -- '---\n%s\nversion: %s\n---\nBeta.\n' "$3" "$2" > "$1/rules/beta.md"
}
mkroot "$TESTDIR/ok" 1.2.3 'kind: standing-constraint'; expect pass "$TESTDIR/ok"
mkroot "$TESTDIR/counter" 12 'kind: standing-constraint'; expect semver "$TESTDIR/counter"
mkroot "$TESTDIR/vform" v1.0.0 'kind: standing-constraint'; expect semver "$TESTDIR/vform"
mkroot "$TESTDIR/nokind" 1.0.0 'tags: none'; expect kind "$TESTDIR/nokind"
mkroot "$TESTDIR/missing" 1.0.0 'kind: standing-constraint'; rm "$TESTDIR/missing/rules/beta.md"; expect exists "$TESTDIR/missing"

check_root "$TOOLKIT_ROOT"
st=$?
[ "$st" -eq 2 ] && { echo "FAIL: target absent — rules/manifest is absent or lists nothing" >&2; exit 1; }
[ "$st" -eq 0 ] || exit 1
