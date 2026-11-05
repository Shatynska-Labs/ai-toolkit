#!/usr/bin/env bash
# Scenario: The seeded entry's fields are a list (its requirement revised).
# Requirement: The backlog's rules are written where none exist.
# Change: report-a-tasks-kind-and-wait (project-bootstrap, MODIFIED).
#
# SPECIFIED: the entry shape gives the values as frontmatter keys, one per line,
# and the reasons as one Markdown list in the body, with no blank line between
# its items; the requirement's body now lists the reasons Kind, Need, Priority,
# Recorded by, in that order.
# DERIVED (shape, as backlog-dir-seeded-fields-are-a-list.sh read it): the
# shape is a fenced example; its frontmatter holds nothing but `key: value`
# lines; the four items sit on four adjacent lines in that order, inside the
# same fence (tasks.md 1.1 adds **Need** to the example's list).
#
# Executes project-init, then reads the block it seeds; the check is
# discriminated on specimens first. Red until task 1.1 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime
source "$TESTLIB"

R=docs/backlog/AGENTS.md

# ---- local arrangement (test-plan.md, Missing shared arrangement: fenced_fm_keys, fenced_item_line)
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
  local file="$1" fm k n p r
  fm="$(fenced_fm_keys "$file")"
  [ -n "$fm" ] || { echo "FAIL: no fenced example frontmatter" >&2; return 1; }
  if printf '%s\n' "$fm" | grep -q '^!'; then
    echo "FAIL: the example frontmatter holds a line that is not one key and its value" >&2
    return 1
  fi
  k="$(fenced_item_line "$file" Kind)"; n="$(fenced_item_line "$file" Need)"
  p="$(fenced_item_line "$file" Priority)"; r="$(fenced_item_line "$file" "Recorded by")"
  if [ -z "$k" ] || [ -z "$n" ] || [ -z "$p" ] || [ -z "$r" ]; then
    echo "FAIL: the example body lacks one of - **Kind**, - **Need**, - **Priority**, - **Recorded by**" >&2
    return 1
  fi
  if [ "$n" -ne $((k + 1)) ] || [ "$p" -ne $((n + 1)) ] || [ "$r" -ne $((p + 1)) ]; then
    echo "FAIL: the reasons are not one list of adjacent items in the order Kind, Need, Priority, Recorded by (lines $k, $n, $p, $r)" >&2
    return 1
  fi
  return 0
}

# ---- the case
spec="$TESTDIR/specimen"
mkdir -p "$spec"
ok() {
  printf '%s\n' '```markdown' '---' 'priority: normal' 'kind: change' 'need: should' 'waits_on: []' '---' '' 'What and why.' '' \
    '- **Kind**: k' '- **Need**: n' '- **Priority**: p' '- **Recorded by**: r' '```'
}
ok > "$spec/ok.md"
check_list "$spec/ok.md" || { echo "FAIL: discriminator — the check rejects a conforming shape" >&2; exit 1; }
ok | grep -v '^- \*\*Need\*\*' > "$spec/no-need.md"
ok | awk '/^- \*\*Need\*\*/ { held = $0; next } { print } /^- \*\*Priority\*\*/ { print held }' > "$spec/need-after-priority.md"
ok | awk '{ print } /^- \*\*Need\*\*/ { print "" }' > "$spec/blank-list.md"
ok | awk '/^waits_on: \[\]$/ { print "waits_on:"; print "  - a"; next } { print }' > "$spec/nested.md"
for bad in no-need need-after-priority blank-list nested; do
  if check_list "$spec/$bad.md" 2>/dev/null; then
    echo "FAIL: discriminator — the check accepts the $bad specimen" >&2
    exit 1
  fi
done

work="$TESTDIR/work"
mkdir -p "$work"
(cd "$work" && bash "$PROJECT_INIT") > "$TESTDIR/report.txt" 2>&1
assert_file "$work/$R" "the seeded block this case reads"
check_list "$work/$R" || exit 1
