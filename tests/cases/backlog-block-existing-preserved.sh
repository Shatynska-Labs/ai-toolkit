#!/usr/bin/env bash
# Scenario: An existing backlog is preserved exactly.
# Requirement: The backlog's rules are written where none exist.
# Change: list-what-a-project-receives (project-bootstrap, ADDED).
#
# SPECIFIED: where docs/backlog/AGENTS.md holds a backlog block, it and every
# file beside it are left byte-for-byte unchanged and the report states the
# backlog already present, with the versions a block already present
# requires: the carried version among them.
# DERIVED (fixture): the block is the one a first run wrote, an entry file
# then added beside it. DERIVED (token): a `backlog:` line saying `already
# present` (tests/README.md) and naming rules/backlog.md's version.
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
assert_file "$work/docs/backlog/AGENTS.md" "target absent — the first run wrote no docs/backlog/AGENTS.md"
printf -- '---\npriority: normal\nkind: fix\n---\n\nAn entry.\n' > "$work/docs/backlog/some-entry.md"
# shellcheck disable=SC2012 # names are the test's own fixture names, plain ASCII
before="$(cd "$work/docs/backlog" && ls -A | sort | xargs md5sum)"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"
# shellcheck disable=SC2012 # names are the test's own fixture names, plain ASCII
after="$(cd "$work/docs/backlog" && ls -A | sort | xargs md5sum)"
[ "$before" = "$after" ] || { echo "FAIL: docs/backlog/ changed:" >&2; diff <(echo "$before") <(echo "$after") >&2; exit 1; }
line="$(grep -E '^backlog:' "$TESTDIR/report.txt")"
case "$line" in *"already present"*) ;; *) echo "FAIL: the backlog line does not state it already present: $line" >&2; exit 1 ;; esac
v="$(frag_key "$TOOLKIT_ROOT/rules/backlog.md" version)"
[ -n "$v" ] || { echo "FAIL: target absent — rules/backlog.md carries no version" >&2; exit 1; }
case "$line" in *"$v"*) ;; *) echo "FAIL: the backlog line does not state the carried version $v: $line" >&2; exit 1 ;; esac
