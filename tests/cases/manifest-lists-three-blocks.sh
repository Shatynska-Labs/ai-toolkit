#!/usr/bin/env bash
# Scenario: The manifest lists the three blocks.
# Requirement: A project receives exactly the blocks the manifest lists.
# Change: list-what-a-project-receives (project-bootstrap, ADDED).
#
# SPECIFIED: rules/manifest's first three records are development-workflow ->
# AGENTS.md, backlog -> docs/backlog/AGENTS.md, workstreams ->
# docs/workstreams/AGENTS.md, in that order; records are separated by a line
# `---`; each carries the two keys name and target; no record carries a
# version.
# DERIVED (operationalisation): "two keys" is read as every non-blank line
# other than a separator being `name:` or `target:`, and each record holding
# exactly one of each.
#
# Static read (third situation); the check is run over a conforming fixture
# and one violating fixture per property first. Red until task 1.2 lands
# (state 2: rules/manifest is absent).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Local arrangement (test-plan.md, Missing shared arrangement:
# manifest_records). manifest_records FILE: one line "<name> <target>" per
# record of a manifest in the flat form design.md decision 1 shows.
manifest_records() {
  awk '
    function flush() { if (n != "" || t != "") print n " " t; n = ""; t = "" }
    /^---[[:space:]]*$/ { flush(); next }
    /^name:/ { n = $0; sub(/^name:[[:space:]]*/, "", n); sub(/[[:space:]]*$/, "", n) }
    /^target:/ { t = $0; sub(/^target:[[:space:]]*/, "", t); sub(/[[:space:]]*$/, "", t) }
    END { flush() }
  ' "$1"
}

check_manifest() {
  local f="$1" recs stray
  [ -f "$f" ] || { echo "ABSENT: $f" >&2; return 2; }
  if grep -q -E '^version:' "$f"; then echo "[no-version] a record carries a version" >&2; return 1; fi
  stray="$(grep -v -E '^(name|target):|^---[[:space:]]*$|^[[:space:]]*$' "$f")"
  if [ -n "$stray" ]; then echo "[two-keys] a line is neither name, target nor a separator: $stray" >&2; return 1; fi
  if awk '/^---/ { if (n != 1 || t != 1) bad = 1; n = 0; t = 0; next } /^name:/ { n++ } /^target:/ { t++ } END { if (n != 1 || t != 1) bad = 1; exit !bad }' "$f"; then
    echo "[one-each] a record does not hold exactly one name and one target" >&2; return 1
  fi
  recs="$(manifest_records "$f" | head -n 3 | tr '\n' '|')"
  if [ "$recs" != "development-workflow AGENTS.md|backlog docs/backlog/AGENTS.md|workstreams docs/workstreams/AGENTS.md|" ]; then
    echo "[first-three] the first three records are: $recs" >&2; return 1
  fi
  return 0
}
expect() {  # pass|TAG FILE
  local out st
  out="$(check_manifest "$2" 2>&1)"; st=$?
  if [ "$1" = pass ]; then [ "$st" -eq 0 ] && return 0
  else [ "$st" -eq 1 ] && case "$out" in *"[$1]"*) return 0 ;; esac
  fi
  echo "FAIL: discriminator — fixture expected $1, check returned $st: $out" >&2
  exit 1
}
fx="$TESTDIR/fx"
mkdir -p "$fx"
ok() { printf '%s\n' 'name: development-workflow' 'target: AGENTS.md' '---' 'name: backlog' 'target: docs/backlog/AGENTS.md' '---' 'name: workstreams' 'target: docs/workstreams/AGENTS.md'; }
ok > "$fx/ok"; expect pass "$fx/ok"
{ ok; printf '%s\n' '---' 'name: later' 'target: docs/later/AGENTS.md'; } > "$fx/later"; expect pass "$fx/later"
ok | sed 's/^name: backlog$/name: workstreams-x/; s/^name: workstreams$/name: backlog/; s/^name: workstreams-x$/name: workstreams/' > "$fx/order"; expect first-three "$fx/order"
ok | sed 's#^target: docs/backlog/AGENTS.md$#target: docs/backlog/README.md#' > "$fx/target"; expect first-three "$fx/target"
{ ok; echo 'version: 1.0.0'; } > "$fx/version"; expect no-version "$fx/version"
ok | sed '/^---$/d' > "$fx/joined"; expect one-each "$fx/joined"
{ ok; echo 'path: rules/x.md'; } > "$fx/stray"; expect two-keys "$fx/stray"

check_manifest "$TOOLKIT_ROOT/rules/manifest"
st=$?
[ "$st" -eq 2 ] && { echo "FAIL: target absent — rules/manifest does not exist" >&2; exit 1; }
[ "$st" -eq 0 ] || exit 1
