#!/usr/bin/env bash
# Scenario: An earlier marker is read.
# Requirement: A block's opening marker records its version and a hash of
# what was written. Change: list-what-a-project-receives (project-bootstrap,
# ADDED).
#
# SPECIFIED: where AGENTS.md holds `<!-- ai-toolkit:development-workflow v12 -->`,
# the tool reports the block present at version `v12` beside the version it
# carries, and rewrites nothing.
# DERIVED (token): both versions are read on the report's `conventions file:`
# line (tests/README.md's report contract); the carried version is read from
# rules/development-workflow.md's frontmatter.
#
# Executes the tool. Red until tasks 1.2 and 2.2 land (state 1: the report
# states `existing version 12`, not `v12`, and the carried version is not
# semantic).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

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

work="$TESTDIR/work"
mkdir -p "$work"
cat > "$work/AGENTS.md" <<'BLOCK'
<!-- ai-toolkit:development-workflow v12 -->
<!-- Generated. Do not edit inside this block — it is replaced on update.
     Project-specific conventions belong below the closing marker. -->
the text a project adopted at v12
<!-- /ai-toolkit:development-workflow -->
BLOCK
sum="$(md5sum "$work/AGENTS.md" | awk '{print $1}')"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"
assert_unchanged "$work/AGENTS.md" "$sum" "the earlier block is not rewritten"
carried="$(frag_key "$TOOLKIT_ROOT/rules/development-workflow.md" version)"
printf '%s\n' "$carried" | grep -q -E '^[0-9]+[.][0-9]+[.][0-9]+$' || { echo "FAIL: the workflow fragment's version is not MAJOR.MINOR.PATCH: '$carried'" >&2; exit 1; }
line="$(grep -E '^conventions file:' "$TESTDIR/report.txt")"
case "$line" in *v12*) ;; *) echo "FAIL: the conventions file line does not state v12: $line" >&2; exit 1 ;; esac
case "$line" in *"$carried"*) ;; *) echo "FAIL: the conventions file line does not state the carried version $carried: $line" >&2; exit 1 ;; esac
