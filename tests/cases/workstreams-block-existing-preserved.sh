#!/usr/bin/env bash
# Scenario: An existing workstream register is preserved exactly.
# Requirement: A workstream register is seeded where none exists.
# Change: list-what-a-project-receives (project-bootstrap, MODIFIED).
#
# SPECIFIED: where docs/workstreams/AGENTS.md holds a workstreams block, it
# and every file beside it are left byte-for-byte unchanged, and the report
# states the register already present, with the carried version.
# DERIVED (fixture): the block a first run wrote, a workstream file added
# beside it. DERIVED (token): a `workstreams:` line saying `already present`
# and naming rules/workstreams.md's version.
#
# Executes the tool. Red until tasks 1.1 and 2.3 land (state 2).
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
(cd "$work" && bash "$PROJECT_INIT") >/dev/null 2>&1
assert_file "$work/docs/workstreams/AGENTS.md" "target absent — the first run wrote no docs/workstreams/AGENTS.md"
printf '# some-goal\n\nA goal.\n' > "$work/docs/workstreams/some-goal.md"
# shellcheck disable=SC2012 # names are the test's own fixture names, plain ASCII
before="$(cd "$work/docs/workstreams" && ls -A | sort | xargs md5sum)"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"
# shellcheck disable=SC2012 # names are the test's own fixture names, plain ASCII
after="$(cd "$work/docs/workstreams" && ls -A | sort | xargs md5sum)"
[ "$before" = "$after" ] || { echo "FAIL: docs/workstreams/ changed" >&2; exit 1; }
line="$(grep -E '^workstreams:' "$TESTDIR/report.txt")"
case "$line" in *"already present"*) ;; *) echo "FAIL: the workstreams line does not state it already present: $line" >&2; exit 1 ;; esac
v="$(frag_key "$TOOLKIT_ROOT/rules/workstreams.md" version)"
[ -n "$v" ] || { echo "FAIL: target absent — rules/workstreams.md carries no version" >&2; exit 1; }
case "$line" in *"$v"*) ;; *) echo "FAIL: the workstreams line does not state the carried version $v: $line" >&2; exit 1 ;; esac
