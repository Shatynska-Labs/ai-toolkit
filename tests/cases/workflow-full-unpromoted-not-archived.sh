#!/usr/bin/env bash
# Scenario: A change confirmed and never promoted is not archived.
# Requirement: The default workflow reaches production by promotion
# Change: add-a-direct-workflow-variant (session-workflow, ADDED).
#
# SPECIFIED: within `### ship`, a change is archived only once confirmed or its gate waived and it is in production; a change deliberately not going to production is archived on the operator's word as a waiver of `promote`, distinct from a confirmation waiver.
# DERIVED: the scans are co-occurrences on one line, this repository writing a paragraph per line; the wording of 'distinct' is not fixed, so several forms satisfy it.
#
# Static read (third situation); every scan is discriminated over fixtures first. Red on real content until task 1.2 lands (state 1: the property is absent from rules/development-workflow.md).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Local arrangement (test-plan.md, Missing shared arrangement: the static
# readers). frag_body FILE: everything after the frontmatter's closing line.
frag_body() {
  awk 'NR == 1 && $0 == "---" { f = 1; next } f == 1 && $0 == "---" { f = 2; next } f == 2 { print }' "$1"
}
# frag_key FILE KEY: KEY's value in FILE's leading frontmatter, or nothing.
frag_key() {
  awk -v k="$2" '
    NR == 1 { if ($0 != "---") exit; next }
    $0 == "---" { exit }
    index($0, k ":") == 1 { v = substr($0, length(k) + 2); sub(/^[[:space:]]*/, "", v); sub(/[[:space:]]*$/, "", v); print v; exit }
  ' "$1" 2>/dev/null
}
# split_ship FILE ship|rest: the body's `### ship` section, heading included,
# or everything else. The section ends at the next heading of level three or
# higher outside a fence.
split_ship() {
  frag_body "$1" | awk -v mode="$2" '
    /^(```|~~~)/ { fence = !fence }
    !fence && /^##?#? / { in_ship = ($0 == "### ship") }
    (mode == "ship") == (in_ship == 1) { print }
  '
}
# shellcheck disable=SC2034 # each case reads the fragments it needs
FRAGMENT_FULL="$TOOLKIT_ROOT/rules/development-workflow.md"
# shellcheck disable=SC2034 # each case reads the fragments it needs
FRAGMENT_DIRECT="$TOOLKIT_ROOT/rules/development-workflow-direct.md"
# need TAG REGEX...: a scan; one line of what is scanned must match every
# REGEX, an extended expression matched without regard to case.
SCANS=()
need() { local IFS=$'\t'; SCANS+=("$*"); }
# scan_lines TEXTFILE: 0 where every scan holds; each failure prints [TAG].
scan_lines() {
  local spec tag re lines bad=0
  local -a parts
  for spec in "${SCANS[@]}"; do
    IFS=$'\t' read -r -a parts <<< "$spec"
    tag="${parts[0]}"
    lines="$(cat "$1")"
    for re in "${parts[@]:1}"; do
      lines="$(printf '%s\n' "$lines" | grep -i -E -- "$re")"
    done
    [ -n "$lines" ] || { echo "[$tag] no line states this" >&2; bad=1; }
  done
  return "$bad"
}
# discriminate_scans FIXTURE: the fixture passes, and each scan fails with its
# own tag once the lines its first expression selects are removed.
discriminate_scans() {
  local fixture="$1" spec tag out st
  local -a parts
  out="$(scan_lines "$fixture" 2>&1)" || { echo "FAIL: discriminator — the conforming fixture fails: $out" >&2; exit 1; }
  for spec in "${SCANS[@]}"; do
    IFS=$'\t' read -r -a parts <<< "$spec"
    tag="${parts[0]}"
    grep -v -i -E -- "${parts[1]}" "$fixture" > "$fixture.mutant"
    out="$(scan_lines "$fixture.mutant" 2>&1)"; st=$?
    [ "$st" -eq 1 ] && case "$out" in *"[$tag]"*) continue ;; esac
    echo "FAIL: discriminator — removing what [$tag] reads did not fail it (status $st): $out" >&2
    exit 1
  done
}
need archive-gate '^\*\*archive\*\*' 'in production'
need not-archived 'never promoted' 'not archived'
need promote-waiver 'waiv' 'promot'
need waiver-distinct 'waiv' 'promot' 'distinct|separate|different|not the same'
fx="$TESTDIR/fx"
cat > "$fx" <<'FIXTURE'
**archive** — once it is confirmed and the change is in production.
A change confirmed and never promoted is not archived.
A change not going further is recorded on a waiver of `promote`, which is distinct from a confirmation waiver.
FIXTURE
discriminate_scans "$fx"
printf 'A waiver of promote is recorded.\nArchived once in production.\n' > "$fx.same"
if scan_lines "$fx.same" 2>/dev/null; then echo "FAIL: discriminator — a promote waiver not told from the confirmation waiver passed" >&2; exit 1; fi

assert_file "$FRAGMENT_FULL" "the promoting fragment"
split_ship "$FRAGMENT_FULL" ship > "$TESTDIR/ship"
[ -s "$TESTDIR/ship" ] || { echo "FAIL: no ### ship section" >&2; exit 1; }
scan_lines "$TESTDIR/ship" || exit 1
