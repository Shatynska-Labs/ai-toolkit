#!/usr/bin/env bash
# Scenario: A project without a deploy is not served by a conditional (mechanical half, per form).
# Requirement: The session obligations are published in the workflow fragment and one binding fragment
# Change: add-a-direct-workflow-variant (session-workflow, MODIFIED).
#
# SPECIFIED: work too small to be a change does not skip `ship`, whose route is merging in the direct form, merging and a promotion in the promoting form; the promoting form assumes a staging deploy triggered by merging and a production deploy triggered deliberately, the direct form that merging to the trunk deploys.
# DERIVED: each is a co-occurrence on one line, the two paragraphs being the ones the comparison allows to differ.
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
SCANS=()
need small-route 'too small to be a change' 'merging' 'promot'
need assumes-staging 'assum' 'staging' 'merg'
need assumes-production 'assum' 'production' 'deliberate'
fx="$TESTDIR/fx"
cat > "$fx" <<'FIXTURE'
Work too small to be a change does not skip ship: merging and a promotion reach production.
These rules assume a staging deploy triggered by merging.
These rules assume a production deploy triggered deliberately.
FIXTURE
discriminate_scans "$fx"
assert_file "$FRAGMENT_FULL" "the promoting fragment"
frag_body "$FRAGMENT_FULL" > "$TESTDIR/full"
scan_lines "$TESTDIR/full" || exit 1

SCANS=()
need small-route 'too small to be a change' 'merging'
need assumes-merge 'assum' 'merg' 'deploy'
fx="$TESTDIR/fxd"
cat > "$fx" <<'FIXTURE'
Work too small to be a change does not skip ship: merging reaches production.
These rules assume that merging to the trunk deploys.
FIXTURE
discriminate_scans "$fx"
[ -f "$FRAGMENT_DIRECT" ] || { echo "FAIL: target absent — rules/development-workflow-direct.md does not exist yet" >&2; exit 1; }
frag_body "$FRAGMENT_DIRECT" > "$TESTDIR/direct"
scan_lines "$TESTDIR/direct" || exit 1
