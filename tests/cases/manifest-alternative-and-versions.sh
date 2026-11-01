#!/usr/bin/env bash
# Scenario: The manifest lists the three blocks; Every listed fragment exists with a kind and a semantic version (as revised: a record may name an alternative).
# Requirement: A project receives exactly the blocks the manifest lists
# Change: add-a-direct-workflow-variant (project-bootstrap, MODIFIED).
#
# SPECIFIED: rules/manifest's first three records are development-workflow, backlog and workstreams; the first carries `alternative: development-workflow-direct`; alternative adds no record, so no record is named development-workflow-direct; no record carries a version. rules/development-workflow-direct.md carries a kind and version 1.0.0; rules/development-workflow.md carries version 2.0.0 and alternative_since: 2.0.0.
# DERIVED: records are read by the `---` separators in the file; `name`, `target` and `alternative` are the only keys.
#
# Static read (third situation); one mutant per property over a fixture root. Red until tasks 1.1 to 1.3 land (state 1 on the manifest's missing alternative).
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
check() {  # ROOT
  local root="$1" m="$1/rules/manifest" first
  [ -f "$m" ] || { echo "[manifest] absent" >&2; return 1; }
  if grep -q -E '^version:' "$m"; then echo "[no-version]" >&2; return 1; fi
  if grep -v -E '^(name|target|alternative):|^---[[:space:]]*$|^[[:space:]]*$' "$m" | grep -q .; then echo "[keys]" >&2; return 1; fi
  [ "$(grep -E '^name:' "$m" | head -n 3 | awk '{print $2}' | tr '\n' ' ')" = "development-workflow backlog workstreams " ] || { echo "[first-three]" >&2; return 1; }
  first="$(awk '/^---[[:space:]]*$/ { exit } { print }' "$m")"
  printf '%s\n' "$first" | grep -q -E '^alternative:[[:space:]]*development-workflow-direct[[:space:]]*$' || { echo "[alternative]" >&2; return 1; }
  if grep -q -E '^name:[[:space:]]*development-workflow-direct' "$m"; then echo "[no-record]" >&2; return 1; fi
  [ -n "$(frag_key "$root/rules/development-workflow-direct.md" kind)" ] || { echo "[direct-kind]" >&2; return 1; }
  [ "$(frag_key "$root/rules/development-workflow-direct.md" version)" = 1.0.0 ] || { echo "[direct-version]" >&2; return 1; }
  [ "$(frag_key "$root/rules/development-workflow.md" version)" = 2.0.0 ] || { echo "[full-version]" >&2; return 1; }
  [ "$(frag_key "$root/rules/development-workflow.md" alternative_since)" = 2.0.0 ] || { echo "[since]" >&2; return 1; }
}
mkroot() {
  mkdir -p "$1/rules"
  printf '%s\n' 'name: development-workflow' 'target: AGENTS.md' 'alternative: development-workflow-direct' '---' 'name: backlog' 'target: docs/backlog/AGENTS.md' '---' 'name: workstreams' 'target: docs/workstreams/AGENTS.md' > "$1/rules/manifest"
  printf -- '---\nkind: standing-constraint\nversion: 2.0.0\nalternative_since: 2.0.0\n---\nFull.\n' > "$1/rules/development-workflow.md"
  printf -- '---\nkind: standing-constraint\nversion: 1.0.0\n---\nDirect.\n' > "$1/rules/development-workflow-direct.md"
}
expect() {  # TAG ROOT
  local out st
  out="$(check "$2" 2>&1)"; st=$?
  [ "$st" -ne 0 ] && case "$out" in *"[$1]"*) return 0 ;; esac
  echo "FAIL: discriminator — expected [$1], status $st: $out" >&2
  exit 1
}
mutate() {  # NAME TAG SED-EXPRESSION FILE
  local r="$TESTDIR/$1"
  mkroot "$r"
  sed "$3" "$r/rules/$4" > "$r/rules/$4.new" && mv "$r/rules/$4.new" "$r/rules/$4"
  expect "$2" "$r"
}
mkroot "$TESTDIR/ok"
check "$TESTDIR/ok" || { echo "FAIL: discriminator — the conforming root fails" >&2; exit 1; }
mutate a alternative '/^alternative:/d' manifest
mutate b alternative 's/^alternative: .*/alternative: other/' manifest
mutate c no-version "\$a version: 1.0.0" manifest
mutate d keys "\$a path: x" manifest
mutate e first-three 's/^name: backlog$/name: later/' manifest
mutate f no-record "\$a ---\nname: development-workflow-direct\ntarget: AGENTS.md" manifest
mutate g direct-kind '/^kind:/d' development-workflow-direct.md
mutate h direct-version 's/^version: .*/version: 1.1.0/' development-workflow-direct.md
mutate i full-version 's/^version: .*/version: 1.9.0/' development-workflow.md
mutate j since '/^alternative_since:/d' development-workflow.md

check "$TOOLKIT_ROOT" || exit 1
