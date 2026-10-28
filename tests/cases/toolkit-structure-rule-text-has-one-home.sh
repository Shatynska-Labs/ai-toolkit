#!/usr/bin/env bash
# Scenario: A text two tools write has one home (as revised).
# Requirement: Documentation separation of concerns.
# Change: list-what-a-project-receives (toolkit-structure, MODIFIED).
#
# SPECIFIED: AGENTS.md places the text written as the block in a project's
# docs/backlog/AGENTS.md in rules/, as the fragment the manifest names, and
# no copy of it exists under scripts/; AGENTS.md states that every rule text
# a shipped tool writes into a project is a rules/ fragment and that
# rules/manifest lists which and where; scripts/seed/ is removed.
# DERIVED (operationalisation): AGENTS.md names `rules/manifest`, has a line
# naming a rule text and a fragment, and no longer names scripts/seed/; no
# scripts/seed/ exists; no file under scripts/ holds rules/backlog.md's
# longest body line verbatim.
#
# Static read (third situation); the scans are discriminated on a fixture.
# Red until tasks 1.4 and 3.4 land (state 1: AGENTS.md names scripts/seed/).
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

# Local arrangement (test-plan.md, Missing shared arrangement: text scans).
# tests/cases/lib/static-scan.sh and line-scan.sh do this for files under a
# root; they are test modules, not a dispatched shared arrangement, so the
# scans are declared here.
#
#   scan_add MODE TAG REGEX [SPECIMEN]
#     MODE require | forbid; REGEX a lowercase ERE matched against the
#     lowercased text, where " && " joins parts that must all match one line;
#     SPECIMEN, forbid only, a line the discriminator appends to trip it.
# scan_text FILE returns 0 (every scan holds), 1 (a scan failed, printed as
# [TAG] on stderr) or 2 (FILE absent or empty: the target-absent state).
# scan_discriminate FIXTURE requires the fixture to pass, then one mutant per
# scan — a require scan's matching lines removed, a forbid scan's specimen
# appended — to be rejected with status 1 and that scan's own [TAG].
SC_MODE=()
SC_TAG=()
SC_RE=()
SC_SPEC=()
scan_add() { SC_MODE+=("$1"); SC_TAG+=("$2"); SC_RE+=("$3"); SC_SPEC+=("${4:-}"); }
scan_hits() {  # FILE REGEX: the lines of FILE matching every part of REGEX
  awk -v re="$2" '
    BEGIN { n = split(re, p, / && /) }
    { l = tolower($0); ok = 1; for (i = 1; i <= n; i++) if (l !~ p[i]) { ok = 0; break }; if (ok) print }
  ' "$1"
}
scan_text() {
  local f="$1" i st=0
  [ -s "$f" ] || return 2
  for i in "${!SC_TAG[@]}"; do
    if [ -n "$(scan_hits "$f" "${SC_RE[$i]}")" ]; then
      [ "${SC_MODE[$i]}" = forbid ] && { echo "[${SC_TAG[$i]}] forbidden text present: $(scan_hits "$f" "${SC_RE[$i]}" | head -n 1)" >&2; st=1; }
    else
      [ "${SC_MODE[$i]}" = require ] && { echo "[${SC_TAG[$i]}] required text absent" >&2; st=1; }
    fi
  done
  return "$st"
}
scan_discriminate() {
  local fx="$1" i m="$TESTDIR/scan-mutant.txt" out st
  if ! scan_text "$fx" 2>/dev/null; then
    echo "FAIL: discriminator — the conforming fixture is rejected:" >&2
    scan_text "$fx"
    exit 1
  fi
  for i in "${!SC_TAG[@]}"; do
    if [ "${SC_MODE[$i]}" = require ]; then
      awk -v re="${SC_RE[$i]}" '
        BEGIN { n = split(re, p, / && /) }
        { l = tolower($0); ok = 1; for (j = 1; j <= n; j++) if (l !~ p[j]) { ok = 0; break }; if (!ok) print }
      ' "$fx" > "$m"
      printf 'filler line\n' >> "$m"
    else
      { cat "$fx"; printf '%s\n' "${SC_SPEC[$i]}"; } > "$m"
    fi
    out="$(scan_text "$m" 2>&1)"
    st=$?
    if [ "$st" -ne 1 ] || ! printf '%s\n' "$out" | grep -q -F "[${SC_TAG[$i]}]"; then
      echo "FAIL: discriminator — scan [${SC_TAG[$i]}] does not reject its mutant (status $st)" >&2
      exit 1
    fi
  done
}
# scan_target FILE LABEL: holds FILE to the scans, failing the case on any.
scan_target() {
  local st
  scan_text "$1"
  st=$?
  [ "$st" -eq 2 ] && { echo "FAIL: target absent — $2 ($1) is absent or empty" >&2; exit 1; }
  [ "$st" -eq 0 ] || { echo "FAIL: $2 ($1) fails the scans above" >&2; exit 1; }
}

scan_add require names-manifest 'rules/manifest'
scan_add require rule-text-is-fragment 'rule text && fragment'
# shellcheck disable=SC2016 # backticks and $ are literal markdown or awk, not expansions
scan_add forbid no-seed 'scripts/seed' '`scripts/seed/` holds the texts the shipped tools write into a project verbatim.'
fx="$TESTDIR/AGENTS.md"
cat > "$fx" <<'FIXTURE'
# conventions

Every rule text a shipped tool writes into a project is a `rules/` fragment, written as a managed block without its frontmatter; `rules/manifest` lists which fragments are written and where.
FIXTURE
scan_discriminate "$fx"
scan_target "$TOOLKIT_ROOT/AGENTS.md" "AGENTS.md"

assert_file_absent "$TOOLKIT_ROOT/scripts/seed" "scripts/seed/ is removed"
frag="$TOOLKIT_ROOT/rules/backlog.md"
assert_file "$frag" "target absent — the fragment the manifest names for the backlog"
probe="$(frag_body "$frag" | awk '{ if (length($0) > length(best)) best = $0 } END { print best }')"
[ "${#probe}" -ge 40 ] || { echo "FAIL: rules/backlog.md has no body line long enough to probe for a copy" >&2; exit 1; }
if grep -r -l -F -- "$probe" "$TOOLKIT_ROOT/scripts" >&2; then
  echo "FAIL: a file under scripts/ holds a copy of the backlog's rule text" >&2
  exit 1
fi
