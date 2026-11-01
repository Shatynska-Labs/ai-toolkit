#!/usr/bin/env bash
# Scenario: none: requirement text, The default workflow reaches production by promotion; also Production is not reached from a local machine (revised).
# Requirement: The default workflow reaches production by promotion
# Change: add-a-direct-workflow-variant (session-workflow, ADDED).
#
# SPECIFIED: each obligation the requirement lists, within `### ship`: a merge reaches staging and nothing else; a person triggers a promotion, a session proposes it and never triggers it silently; the deploy command is never run locally against either host; confirm happens on staging and does not establish production; production's gate is the smoke check, not a second confirm; a failed smoke leaves production on the promoted image and re-enters at build's review gate, promoting the previous commit being the operator's remedy; production behind the trunk is the pipeline working, not drift; `ship:confirmed` means confirmed on staging.
# DERIVED: each scan is a co-occurrence on one line; the tokens are the requirement's own nouns and fix no sentence.
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
need merge-staging 'merg' 'staging'
need person-triggers 'promot' 'person|operator'
need never-silently 'promot' 'silent'
need either-host 'locally' 'either host|staging'
# shellcheck disable=SC2016 # backticks are literal markdown
need confirm-staging '`?ship:confirmed`?' 'staging'
need not-production 'confirm' 'does not establish|not establish|says nothing|not show'
need smoke-gate 'smoke' 'gate'
need smoke-fails 'smoke' 'fail' 'promoted image'
need previous-commit 'previous commit' 'operator'
need lag 'trunk' 'behind|lag' 'drift'
fx="$TESTDIR/fx"
cat > "$fx" <<'FIXTURE'
A merge reaches staging and nothing else.
A person triggers each promotion.
A session proposes a promotion and never triggers it silently.
The deploy command is never run locally against either host.
`ship:confirmed` means the effect was confirmed on staging.
A confirmed effect does not establish that production received it.
Production's gate is the smoke check.
A smoke check that fails leaves production on the promoted image.
Promoting the previous commit is the operator's remedy.
Production runs behind the trunk, which is not drift.
FIXTURE
discriminate_scans "$fx"

assert_file "$FRAGMENT_FULL" "the promoting fragment"
split_ship "$FRAGMENT_FULL" ship > "$TESTDIR/ship"
[ -s "$TESTDIR/ship" ] || { echo "FAIL: no ### ship section" >&2; exit 1; }
scan_lines "$TESTDIR/ship" || exit 1
