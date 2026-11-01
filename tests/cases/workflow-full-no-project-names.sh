#!/usr/bin/env bash
# Scenario: No project's name reaches the fragment.
# Requirement: The default workflow reaches production by promotion
# Change: add-a-direct-workflow-variant (session-workflow, ADDED).
#
# SPECIFIED: neither promote.yml nor publish-prompts appears in rules/development-workflow.md.
# DERIVED: `commerce-ops` and `gh workflow run` are forbidden as well: the requirement bars naming any file, job or service of one project, and design decision 6 drops the second by name.
#
# Static read (third situation); discriminated over fixtures first. Guarded on the promoting stage line so a pass on today's one-deploy fragment, which cannot have gained a project's name, is not read as coverage (state 2 until task 1.2).
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
check() {  # FILE
  local bad=0 t
  for t in promote.yml publish-prompts commerce-ops 'gh workflow run'; do
    if grep -q -F -- "$t" "$1"; then echo "[names] $t" >&2; bad=1; fi
  done
  return "$bad"
}
fx="$TESTDIR/fx"
printf 'A person triggers the promotion.\n' > "$fx"
check "$fx" || { echo "FAIL: discriminator — the clean fixture fails" >&2; exit 1; }
for t in promote.yml publish-prompts commerce-ops 'gh workflow run'; do
  printf 'Run %s to promote.\n' "$t" > "$fx.bad"
  if check "$fx.bad" 2>/dev/null; then echo "FAIL: discriminator — $t passed" >&2; exit 1; fi
done

assert_file "$FRAGMENT_FULL" "the promoting fragment"
grep -q -E '^ship:.*deploy staging' "$FRAGMENT_FULL" || { echo "FAIL: target absent — rules/development-workflow.md does not yet state the promoting ship" >&2; exit 1; }
check "$FRAGMENT_FULL" || exit 1
