#!/usr/bin/env bash
# Scenario: The seeded entry shape carries the structured fields.
# Requirement: A backlog is seeded where none exists.
# Change: one-file-per-backlog-entry (project-bootstrap, MODIFIED).
#
# SPECIFIED: the seeded README's entry shape names the keys priority,
# parked_until, kind, waits_on, waits_for, design_with, workstream,
# recorded_by and re_checked, in that order, and does not name Depends on.
# DERIVED (shape, unresolved question Q1): the entry shape is shown as a
# fenced example whose frontmatter lists the keys one per line; the keys it
# carries are in the stated order, and it carries at least the seven that are
# not conditional (parked_until and waits_for are "present only" on some
# entries, so an example may leave them to prose). Every one of the nine is
# named somewhere in the README.
#
# Executes the tool; the local parser is checked on specimens first. Red until
# tasks 1.1 and 1.2 land (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

R=docs/backlog/README.md

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
    echo "FAIL: target absent — project-init seeded no docs/backlog/README.md" >&2
  fi
  [ "$st" -eq 0 ] || exit 1
}

KEYS=(priority parked_until kind waits_on waits_for design_with workstream recorded_by re_checked)
REQUIRED=(priority kind waits_on design_with workstream recorded_by re_checked)

# Local arrangement (test-plan.md, Missing shared arrangement): the keys of the
# first frontmatter block inside a fence, one per line; a line that is not
# `key: ...` is printed as `!<line>`.
fenced_fm_keys() {
  awk '
    /^[[:space:]]*(```|~~~)/ { infence = !infence; if (!infence && infm) exit; next }
    !infence { next }
    !started && $0 == "---" { started = 1; infm = 1; next }
    infm && $0 == "---" { exit }
    infm { if (match($0, /^[a-z_]+:/)) print substr($0, 1, RLENGTH - 1); else print "!" $0 }
  ' "$1"
}

check_keys() {
  local file="$1" keys pos=-1 k i found idx
  keys="$(fenced_fm_keys "$file" | grep -v '^!')"
  if [ -z "$keys" ]; then echo "FAIL: no fenced example frontmatter in $file" >&2; return 1; fi
  while IFS= read -r k; do
    idx=-1
    for i in "${!KEYS[@]}"; do [ "${KEYS[$i]}" = "$k" ] && idx=$i; done
    if [ "$idx" -lt 0 ]; then echo "FAIL: the example carries a key the requirement does not name: $k" >&2; return 1; fi
    if [ "$idx" -le "$pos" ]; then echo "FAIL: key $k is out of the stated order" >&2; return 1; fi
    pos=$idx
  done <<< "$keys"
  for k in "${REQUIRED[@]}"; do
    found=0
    while IFS= read -r i; do [ "$i" = "$k" ] && found=1; done <<< "$keys"
    [ "$found" = 1 ] || { echo "FAIL: the example's frontmatter lacks $k" >&2; return 1; }
  done
  for k in "${KEYS[@]}"; do
    grep -q -F -- "$k" "$file" || { echo "FAIL: the README never names $k" >&2; return 1; }
  done
  if grep -q -i 'depends on' "$file"; then echo "FAIL: the README names Depends on" >&2; return 1; fi
  return 0
}

spec="$TESTDIR/specimen"
mkdir -p "$spec"
ok() {
  # shellcheck disable=SC2016 # backticks and $ are literal text in a pattern or fixture
  printf '%s\n' 'An entry may carry `parked_until` and `waits_for` as well.' '' '```markdown' '---' \
    'priority: normal' 'kind: change' 'waits_on: []' 'design_with: []' 'workstream: none' \
    'recorded_by: some-change' 're_checked: 2026-10-25' '---' '' 'What and why.' '```'
}
ok > "$spec/ok.md"
check_keys "$spec/ok.md" || { echo "FAIL: discriminator — the check rejects a conforming README" >&2; exit 1; }
ok | sed 's/^kind: change$/KIND/; s/^priority: normal$/kind: change/; s/^KIND$/priority: normal/' > "$spec/order.md"
ok | grep -v '^re_checked:' > "$spec/missing.md"
ok | sed 's/as well\./as well, and Depends on./' > "$spec/depends.md"
# shellcheck disable=SC2016 # backticks and $ are literal text in a pattern or fixture
ok | sed 's/`waits_for` //' > "$spec/unnamed.md"
for bad in order missing depends unnamed; do
  if check_keys "$spec/$bad.md" 2>/dev/null; then
    echo "FAIL: discriminator — the check accepts the $bad specimen" >&2
    exit 1
  fi
done

work="$TESTDIR/work"
mkdir -p "$work"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
assert_file "$work/$R" "the seeded README this case reads"
check_keys "$work/$R" || exit 1
