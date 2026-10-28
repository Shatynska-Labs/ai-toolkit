#!/usr/bin/env bash
# DERIVED from requirement text, not a scenario: The fragment's version
# increments when its body changes (project-bootstrap, MODIFIED) — "Every
# fragment carrying a version ... SHALL be at least 1.0.0", in the form
# MAJOR.MINOR.PATCH; and One directory level for every asset type
# (toolkit-structure, MODIFIED) — `version: 1.0.0  # inlined fragments only:
# MAJOR.MINOR.PATCH`. design.md decision 3 names the fragments that carry
# one: development-workflow, development-workflow-database, test-plan,
# backlog and workstreams.
#
# SPECIFIED: every rules/*.md whose frontmatter carries `version` carries
# three dot-joined runs of digits with MAJOR at least 1; the five named
# fragments carry one.
#
# Static read (third situation); the check is run over fixture directories
# first. Red until tasks 1.1 and 1.2 land (state 1: versions are counters).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

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

check_dir() {
  local dir="$1" f v bad=0 n
  for n in $2; do
    [ -n "$(frag_key "$dir/$n.md" version)" ] || { echo "[carries] rules/$n.md carries no version" >&2; bad=1; }
  done
  for f in "$dir"/*.md; do
    [ -f "$f" ] || continue
    v="$(frag_key "$f" version)"
    [ -n "$v" ] || continue
    if ! printf '%s\n' "$v" | grep -q -E '^[0-9]+[.][0-9]+[.][0-9]+$'; then
      echo "[semver] ${f##*/} version '$v' is not MAJOR.MINOR.PATCH" >&2; bad=1
    elif [ "${v%%.*}" -lt 1 ]; then
      echo "[at-least-1] ${f##*/} version '$v' is below 1.0.0" >&2; bad=1
    fi
  done
  return "$bad"
}
expect() {  # pass|TAG DIR NAMES
  local out st
  out="$(check_dir "$2" "$3" 2>&1)"; st=$?
  if [ "$1" = pass ]; then [ "$st" -eq 0 ] && return 0
  else [ "$st" -eq 1 ] && case "$out" in *"[$1]"*) return 0 ;; esac
  fi
  echo "FAIL: discriminator — fixture expected $1, check returned $st: $out" >&2
  exit 1
}
mkfx() {  # DIR VERSION
  mkdir -p "$1"
  printf -- '---\nkind: standing-constraint\nversion: 1.0.0\n---\nA.\n' > "$1/a.md"
  printf -- '---\nkind: standing-constraint\nversion: %s\n---\nB.\n' "$2" > "$1/b.md"
  printf -- '---\nkind: procedural-checklist\n---\nC.\n' > "$1/c.md"
  printf '# rules\n' > "$1/README.md"
}
mkfx "$TESTDIR/ok" 2.1.0; expect pass "$TESTDIR/ok" "a b"
mkfx "$TESTDIR/counter" 12; expect semver "$TESTDIR/counter" "a b"
mkfx "$TESTDIR/zero" 0.2.0; expect at-least-1 "$TESTDIR/zero" "a b"
mkfx "$TESTDIR/unversioned" 1.0.0; expect carries "$TESTDIR/unversioned" "a b c"

check_dir "$TOOLKIT_ROOT/rules" "development-workflow development-workflow-database test-plan backlog workstreams" || exit 1
