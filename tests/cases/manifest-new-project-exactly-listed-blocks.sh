#!/usr/bin/env bash
# Scenario: A new project receives exactly the listed blocks.
# Requirement: A project receives exactly the blocks the manifest lists.
# Change: list-what-a-project-receives (project-bootstrap, ADDED).
#
# SPECIFIED: run in an empty directory, each target rules/manifest lists holds
# exactly one block of the listed name, and no file in the project holds a
# block of a name the manifest does not list.
# DERIVED (operationalisation): a block is counted by its opening line
# `<!-- ai-toolkit:<name> ` and its closing line `<!-- /ai-toolkit:<name> -->`;
# every file outside .git/ is searched.
#
# Executes the tool. Red until tasks 1.2 and 2.3 land (state 2: no manifest).
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
records="$(manifest_records "$manifest")"
[ -n "$records" ] || { echo "FAIL: target absent — the manifest lists no record" >&2; exit 1; }

work="$TESTDIR/work"
mkdir -p "$work"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?" "an empty directory initializes"

names=""
while read -r name target; do
  names="$names $name "
  f="$work/$target"
  assert_file "$f" "the target of $name"
  opens="$(grep -c -F "<!-- ai-toolkit:$name " "$f")"
  closes="$(grep -c -F "<!-- /ai-toolkit:$name -->" "$f")"
  if [ "$opens" -ne 1 ] || [ "$closes" -ne 1 ]; then
    echo "FAIL: $target holds $opens opening and $closes closing markers for $name, not one block" >&2
    exit 1
  fi
done <<< "$records"

found="$(cd "$work" && grep -r -o -h -E '<!-- /?ai-toolkit:[a-z0-9-]+' --exclude-dir=.git . | sed -E 's#<!-- /?ai-toolkit:##' | sort -u)"
[ -n "$found" ] || { echo "FAIL: no block found in the project at all" >&2; exit 1; }
while read -r n; do
  case "$names" in
    *" $n "*) ;;
    *) echo "FAIL: the project holds a block named $n, which the manifest does not list" >&2; exit 1 ;;
  esac
done <<< "$found"
