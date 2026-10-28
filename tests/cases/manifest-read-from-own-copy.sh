#!/usr/bin/env bash
# Scenario: Fragments come from the copy the script belongs to (as revised).
# Requirement: The running script locates its own resources.
# Change: list-what-a-project-receives (project-bootstrap, MODIFIED: the
# script reads the manifest beside the fragments, from the same copy).
#
# SPECIFIED: run from the toolkit under test while AI_TOOLKIT_ROOT and
# CLAUDE_PLUGIN_ROOT name a decoy copy, the script reads the manifest and the
# fragments of its own copy: the decoy manifest's extra record is not
# written, and the version stamped is the real fragment's.
# DERIVED (fixture): the decoy carries a manifest listing a decoy-rules block
# into docs/decoy/AGENTS.md and a workflow fragment at 9.9.9.
#
# Executes the tool. Red until tasks 1.2 and 2.2 land (state 1: no marker in
# the new form).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Local arrangement (test-plan.md, Missing shared arrangement: block readers).
# block_body FILE NAME: the lines strictly between NAME's opening and closing
# markers, each with its newline.
block_body() {
  awk -v n="$2" '
    index($0, "<!-- /ai-toolkit:" n " -->") == 1 { exit }
    f { print }
    index($0, "<!-- ai-toolkit:" n " ") == 1 { f = 1 }
  ' "$1"
}
# marker_line FILE NAME: NAME's opening line in the form
# `<!-- ai-toolkit:NAME MAJOR.MINOR.PATCH sha256:<64 hex> -->`, or nothing.
marker_line() {
  grep -E "^<!-- ai-toolkit:$2 [0-9]+[.][0-9]+[.][0-9]+ sha256:[0-9a-f]{64} -->\$" "$1" 2>/dev/null
}

# Local arrangement (test-plan.md, Missing shared arrangement: fragment
# readers). tests/lib.sh's fragment_version reads development-workflow.md
# only; these read any fragment.
# frag_key FILE KEY: KEY's value in FILE's leading frontmatter, or nothing.
frag_key() {
  awk -v k="$2" '
    NR == 1 { if ($0 != "---") exit; next }
    $0 == "---" { exit }
    index($0, k ":") == 1 { v = substr($0, length(k) + 2); sub(/^[[:space:]]*/, "", v); sub(/[[:space:]]*$/, "", v); print v; exit }
  ' "$1" 2>/dev/null
}
# frag_body FILE: everything after the frontmatter's closing line.
frag_body() {
  awk 'NR == 1 && $0 == "---" { f = 1; next } f == 1 && $0 == "---" { f = 2; next } f == 2 { print }' "$1"
}

decoy="$TESTDIR/decoy"
mkdir -p "$decoy/rules"
printf '%s\n' 'name: development-workflow' 'target: AGENTS.md' '---' 'name: decoy-rules' 'target: docs/decoy/AGENTS.md' > "$decoy/rules/manifest"
printf -- '---\nkind: standing-constraint\nversion: 9.9.9\n---\nDecoy workflow.\n' > "$decoy/rules/development-workflow.md"
printf -- '---\nkind: standing-constraint\nversion: 9.9.9\n---\nDecoy rules.\n' > "$decoy/rules/decoy-rules.md"

work="$TESTDIR/work"
mkdir -p "$work"
(cd "$work" && AI_TOOLKIT_ROOT="$decoy" CLAUDE_PLUGIN_ROOT="$decoy" bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"
assert_file_absent "$work/docs/decoy" "the decoy manifest's record is not written"
if grep -q -F '9.9.9' "$TESTDIR/report.txt" "$work/AGENTS.md"; then
  echo "FAIL: the decoy's version reached the report or the block" >&2; exit 1
fi
line="$(marker_line "$work/AGENTS.md" development-workflow)"
want="$(frag_key "$TOOLKIT_ROOT/rules/development-workflow.md" version)"
if [ -z "$line" ] || [ "$(printf '%s\n' "$line" | awk '{print $3}')" != "$want" ]; then
  echo "FAIL: the workflow marker does not carry the real fragment's version '$want': $line" >&2; exit 1
fi
