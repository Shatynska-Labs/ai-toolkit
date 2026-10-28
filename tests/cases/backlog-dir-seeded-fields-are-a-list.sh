#!/usr/bin/env bash
# Scenario: The seeded entry's fields are a list.
# Requirement: A backlog is seeded where none exists.
# Change: one-file-per-backlog-entry (project-bootstrap, MODIFIED).
#
# SPECIFIED: the entry shape gives the values as frontmatter keys, one per
# line, and the reasons as one Markdown list in the body — `- **Kind**: …`,
# `- **Priority**: …`, `- **Recorded by**: …` — with no blank line between
# them.
# DERIVED (shape, unresolved question Q1): the shape is a fenced example; its
# frontmatter holds nothing but `key: value` lines between its `---`
# delimiters; the three items sit on three adjacent lines in that order after
# the frontmatter, inside the same fence. Key order is
# backlog-dir-seeded-structured-keys.sh's.
#
# Executes the tool; the local parser is checked on specimens first. Red until
# tasks 1.1 and 1.2 land (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

R=docs/backlog/AGENTS.md

# Local arrangement (test-plan.md, Missing shared arrangement: seeded-output
# scan wrappers). static-scan.sh's scan_run checks $TOOLKIT_ROOT only; these
# point the same scans at the tree project-init writes.
#
# fixture_readme: writes stdin as the fixture tree's README.
fixture_readme() {
  mkdir -p "$TESTDIR/fixture/docs/backlog"
  cat > "$TESTDIR/fixture/$R"
}
# seed_and_check: discriminates every scan on the fixture, runs project-init
# in a fresh directory, then holds the seeded README to the scans.
seed_and_check() {
  local work="$TESTDIR/work" st
  scan_discriminate "$TESTDIR/fixture" || exit 1
  mkdir -p "$work"
  (cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
  scan_check "$work"
  st=$?
  if [ "$st" -eq 2 ]; then
    echo "FAIL: target absent — project-init seeded no docs/backlog/AGENTS.md" >&2
  fi
  [ "$st" -eq 0 ] || exit 1
}

# Local arrangement (test-plan.md, Missing shared arrangement), as in
# backlog-dir-seeded-structured-keys.sh, declared here because a test module
# imports from no other.
fenced_fm_keys() {
  awk '
    /^[[:space:]]*(```|~~~)/ { infence = !infence; if (!infence && infm) exit; next }
    !infence { next }
    !started && $0 == "---" { started = 1; infm = 1; next }
    infm && $0 == "---" { exit }
    infm { if (match($0, /^[a-z_]+:/)) print substr($0, 1, RLENGTH - 1); else print "!" $0 }
  ' "$1"
}
# Line number of the first fenced line beginning `- **<label>**`.
fenced_item_line() {
  awk -v label="$2" '
    /^[[:space:]]*(```|~~~)/ { infence = !infence; next }
    infence && index($0, "- **" label "**") == 1 { print NR; exit }
  ' "$1"
}

check_list() {
  local file="$1" fm k p r
  fm="$(fenced_fm_keys "$file")"
  [ -n "$fm" ] || { echo "FAIL: no fenced example frontmatter" >&2; return 1; }
  if printf '%s\n' "$fm" | grep -q '^!'; then
    echo "FAIL: the example frontmatter holds a line that is not one key and its value:" >&2
    printf '%s\n' "$fm" | grep '^!' >&2
    return 1
  fi
  k="$(fenced_item_line "$file" Kind)"; p="$(fenced_item_line "$file" Priority)"; r="$(fenced_item_line "$file" "Recorded by")"
  if [ -z "$k" ] || [ -z "$p" ] || [ -z "$r" ]; then
    echo "FAIL: the example body lacks one of - **Kind**, - **Priority**, - **Recorded by**" >&2
    return 1
  fi
  if [ "$p" -ne $((k + 1)) ] || [ "$r" -ne $((p + 1)) ]; then
    echo "FAIL: the reasons are not one list of adjacent items in the order Kind, Priority, Recorded by (lines $k, $p, $r)" >&2
    return 1
  fi
  return 0
}

spec="$TESTDIR/specimen"
mkdir -p "$spec"
ok() {
  printf '%s\n' '```markdown' '---' 'priority: normal' 'kind: change' 'waits_on: []' '---' '' 'What and why.' '' \
    '- **Kind**: k' '- **Priority**: p' '- **Recorded by**: r' '```'
}
ok > "$spec/ok.md"
check_list "$spec/ok.md" || { echo "FAIL: discriminator — the check rejects a conforming shape" >&2; exit 1; }
ok | awk '{ print } /^kind: change$/ { print "" }' > "$spec/blank-fm.md"
ok | awk '{ print } /^- \*\*Kind\*\*/ { print "" }' > "$spec/blank-list.md"
ok | sed 's/^- \*\*Priority\*\*: p$/**Priority**: p/' > "$spec/paragraph.md"
ok | awk '/^waits_on: \[\]$/ { print "waits_on:"; print "  - a"; next } { print }' > "$spec/nested.md"
for bad in blank-fm blank-list paragraph nested; do
  if check_list "$spec/$bad.md" 2>/dev/null; then
    echo "FAIL: discriminator — the check accepts the $bad specimen" >&2
    exit 1
  fi
done

work="$TESTDIR/work"
mkdir -p "$work"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
assert_file "$work/$R" "the seeded README this case reads"
check_list "$work/$R" || exit 1
