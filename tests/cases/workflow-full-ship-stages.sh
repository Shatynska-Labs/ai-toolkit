#!/usr/bin/env bash
# Scenario: Merging does not reach production.
# Requirement: The default workflow reaches production by promotion
# Change: add-a-direct-workflow-variant (session-workflow, ADDED).
#
# SPECIFIED: the `ship` stage line reads `ship:   open pr · merge · deploy staging · confirm · promote · deploy production · smoke · archive`, which puts deploy staging, promote, deploy production and smoke in that order between merge and archive, and confirm before promote; `### ship` itself states the four stages.
# DERIVED: the line is matched whole, in the form the vocabulary requirement gives it; the section is read for each stage's words without regard to case.
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
want='ship:   open pr · merge · deploy staging · confirm · promote · deploy production · smoke · archive'
check() {  # BODYFILE SHIPFILE
  grep -q -x -F -- "$want" "$1" || { echo "[stage-line] the stage list does not read: $want" >&2; return 1; }
  [ -s "$2" ] || { echo "[no-ship] no ### ship section" >&2; return 1; }
  scan_lines "$2"
}
need deploy-staging 'deploy staging'
need promote 'promot'
need deploy-production 'deploy production'
need smoke 'smoke'

fx="$TESTDIR/fx"
mkdir -p "$fx"
cat > "$fx/ship" <<'FIXTURE'
### ship
After merge, deploy staging runs.
A person triggers the promotion.
Then deploy production runs.
The smoke check runs.
FIXTURE
printf '%s\n' "$want" > "$fx/ok"
check "$fx/ok" "$fx/ship" 2>/dev/null || { echo "FAIL: discriminator — the conforming fixture fails" >&2; exit 1; }
discriminate_scans "$fx/ship"
sed 's/confirm · promote/promote · confirm/' "$fx/ok" > "$fx/order"
if check "$fx/order" "$fx/ship" 2>/dev/null; then echo "FAIL: discriminator — promote before confirm passed" >&2; exit 1; fi
printf '%s\n' 'ship:   open pr · merge · deploy · confirm · archive' > "$fx/one-deploy"
if check "$fx/one-deploy" "$fx/ship" 2>/dev/null; then echo "FAIL: discriminator — the one-deploy line passed" >&2; exit 1; fi
: > "$fx/empty"
if check "$fx/ok" "$fx/empty" 2>/dev/null; then echo "FAIL: discriminator — an absent section passed" >&2; exit 1; fi

assert_file "$FRAGMENT_FULL" "the promoting fragment"
frag_body "$FRAGMENT_FULL" > "$TESTDIR/body"
split_ship "$FRAGMENT_FULL" ship > "$TESTDIR/ship"
check "$TESTDIR/body" "$TESTDIR/ship" || exit 1
