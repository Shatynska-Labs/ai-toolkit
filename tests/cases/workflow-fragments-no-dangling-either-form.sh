#!/usr/bin/env bash
# Scenario: A reader of a project's conventions finds no dangling reference; A fragment names only agents and skills the library ships (over the direct form, which the existing cases do not read).
# Requirement: The session obligations are published in the workflow fragment and one binding fragment
# Change: add-a-direct-workflow-variant (session-workflow, MODIFIED).
#
# SPECIFIED: neither form's body names a `rules/` path, a sibling fragment file or an import, and every `ai-toolkit:<name>` it names is an agent or skill the library ships.
# DERIVED: the file names and imports are those workflow-fragment-no-dangling-reference.sh scans, with development-workflow-direct.md added.
#
# Static read (third situation); the check runs over fixtures first. Red until task 1.1 lands (first situation: rules/development-workflow-direct.md is absent).
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
check() {  # BODY
  local bad=0 t name
  if grep -q -F -- 'rules/' "$1"; then echo "[rules-path]" >&2; bad=1; fi
  for t in development-workflow.md development-workflow-direct.md development-workflow-database.md '@~/' '@rules/' '@AGENTS.md' '@CLAUDE.md'; do
    if grep -q -F -- "$t" "$1"; then echo "[names] $t" >&2; bad=1; fi
  done
  while read -r name; do
    [ -n "$name" ] || continue
    if [ ! -f "$TOOLKIT_ROOT/agents/$name.md" ] && [ ! -f "$TOOLKIT_ROOT/skills/$name/SKILL.md" ]; then
      echo "[unshipped] ai-toolkit:$name" >&2; bad=1
    fi
  done <<< "$(grep -o -E 'ai-toolkit:[a-z0-9][a-z0-9-]*' "$1" | sed 's/^ai-toolkit://' | sort -u)"
  return "$bad"
}
fx="$TESTDIR/fx"
# shellcheck disable=SC2016 # backticks are literal markdown
printf 'Dispatch `ai-toolkit:change-test-writer`, which loads `ai-toolkit:testing`.\n' > "$fx"
check "$fx" || { echo "FAIL: discriminator — the clean fixture fails" >&2; exit 1; }
for text in 'See rules/manifest.' 'See development-workflow-direct.md.' 'Import @rules/x.md.' 'Dispatch ai-toolkit:no-such-asset-here.'; do
  printf '%s\n' "$text" > "$fx.bad"
  if check "$fx.bad" 2>/dev/null; then echo "FAIL: discriminator — passed: $text" >&2; exit 1; fi
done
assert_file "$FRAGMENT_FULL" "the promoting fragment"
[ -f "$FRAGMENT_DIRECT" ] || { echo "FAIL: target absent — rules/development-workflow-direct.md does not exist yet" >&2; exit 1; }
for f in "$FRAGMENT_FULL" "$FRAGMENT_DIRECT"; do
  frag_body "$f" > "$TESTDIR/body"
  [ -s "$TESTDIR/body" ] || { echo "FAIL: $f has an empty body" >&2; exit 1; }
  check "$TESTDIR/body" || { echo "FAIL: $f holds a dangling reference" >&2; exit 1; }
done
