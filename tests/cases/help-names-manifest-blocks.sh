#!/usr/bin/env bash
# DERIVED from tasks.md task 2.4, not a scenario: "verify --help names every
# block the manifest lists".
# Change: list-what-a-project-receives (project-bootstrap).
#
# SPECIFIED (task 2.4): `project-init --help` names, for every record of
# rules/manifest, its target; --help still makes no filesystem change.
# DERIVED (operationalisation): a block is named by its target path, which
# the root's AGENTS.md satisfies trivially.
#
# Executes the tool. Red until tasks 1.2 and 2.4 land.
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

manifest="$TOOLKIT_ROOT/rules/manifest"
assert_file "$manifest" "target absent — rules/manifest"
work="$TESTDIR/work"
mkdir -p "$work"
(cd "$work" && bash "$PROJECT_INIT" --help) >"$TESTDIR/help.txt" 2>&1
assert_exit 0 "$?"
n=0
while read -r name target; do
  [ -n "$name" ] || continue
  n=$((n + 1))
  assert_contains "$TESTDIR/help.txt" "$target" "--help names the $name block's target"
done <<< "$(manifest_records "$manifest")"
[ "$n" -gt 0 ] || { echo "FAIL: target absent — the manifest lists no record" >&2; exit 1; }
[ -z "$(ls -A "$work")" ] || { echo "FAIL: --help wrote into the directory" >&2; exit 1; }
