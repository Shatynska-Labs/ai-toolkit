#!/usr/bin/env bash
# Scenario: The manifest is the one file in rules/ that is not a fragment.
# Requirement: One directory level for every asset type.
# Change: record-what-each-version-asks (toolkit-structure, MODIFIED).
#
# SPECIFIED: listing rules/, every .md file other than README.md is a fragment
# declaring its `kind`, and `manifest` and `changelog` are the only files that
# are neither: no frontmatter, no .md extension.
# DERIVED (operationalisation): "neither" is read as rules/ holding exactly
# these two entries that are not .md files, each a regular file whose first
# line is not `---`, as rules-manifest-only-non-fragment.sh reads it.
#
# Static read (third situation); the check runs over fixture directories first.
# Red until task 1.1 lands (state 2: rules/changelog is absent).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Local arrangement (test-plan.md, Missing shared arrangement: the changelog
# readers). frag_key is declared here: rules-manifest-only-non-fragment.sh holds
# one, and a test module imports from no other test module.
# frag_key FILE KEY: KEY's value in FILE's leading frontmatter, or nothing.
frag_key() {
  awk -v k="$2" '
    NR == 1 { if ($0 != "---") exit; next }
    $0 == "---" { exit }
    index($0, k ":") == 1 { v = substr($0, length(k) + 2); sub(/^[[:space:]]*/, "", v); sub(/[[:space:]]*$/, "", v); print v; exit }
  ' "$1" 2>/dev/null
}

check_rules() {
  local dir="$1" f n others
  for n in manifest changelog; do
    [ -f "$dir/$n" ] || { echo "[present] rules/$n is absent" >&2; return 1; }
    [ "$(head -n 1 "$dir/$n")" != "---" ] || { echo "[no-frontmatter] rules/$n opens with frontmatter" >&2; return 1; }
  done
  others="$(cd "$dir" && for n in * .*; do case "$n" in .|..|'*'|'.*'|*.md|manifest|changelog) ;; *) printf '%s ' "$n" ;; esac; done)"
  [ -z "$others" ] || { echo "[only-two] rules/ holds another non-.md entry: $others" >&2; return 1; }
  for f in "$dir"/*.md; do
    [ "${f##*/}" = README.md ] && continue
    [ -n "$(frag_key "$f" kind)" ] || { echo "[kind] ${f##*/} declares no kind" >&2; return 1; }
  done
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
mkfx() {
  mkdir -p "$1"
  printf '# rules\n' > "$1/README.md"
  printf -- '---\nkind: standing-constraint\nversion: 1.0.0\n---\nA.\n' > "$1/a.md"
  printf 'name: a\ntarget: AGENTS.md\n' > "$1/manifest"
  printf 'name: a\nversion: 1.1.0\nchanged: a thing\n' > "$1/changelog"
}
mkfx "$TESTDIR/ok"; expect pass "$TESTDIR/ok"
mkfx "$TESTDIR/nochangelog"; rm "$TESTDIR/nochangelog/changelog"; expect present "$TESTDIR/nochangelog"
mkfx "$TESTDIR/nomanifest"; rm "$TESTDIR/nomanifest/manifest"; expect present "$TESTDIR/nomanifest"
mkfx "$TESTDIR/fm"; printf -- '---\nkind: list\n---\nname: a\n' > "$TESTDIR/fm/changelog"; expect no-frontmatter "$TESTDIR/fm"
mkfx "$TESTDIR/extra"; printf 'x\n' > "$TESTDIR/extra/index.txt"; expect only-two "$TESTDIR/extra"
mkfx "$TESTDIR/nokind"; printf '# B\n' > "$TESTDIR/nokind/b.md"; expect kind "$TESTDIR/nokind"

check_rules "$TOOLKIT_ROOT/rules" || exit 1
