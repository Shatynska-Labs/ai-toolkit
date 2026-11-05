#!/usr/bin/env bash
# Scenario: The seeded entry shape carries the structured fields (as revised).
# Requirement: The backlog's rules are written where none exist.
# Change: report-a-tasks-kind-and-wait (project-bootstrap, MODIFIED).
#
# SPECIFIED: the seeded block's entry shape names the keys priority,
# parked_until, kind, need, waits_on, waits_for, waits_for_type, design_with,
# workstream, recorded_by and re_checked, in that order, and does not name
# Depends on.
# DERIVED (shape, as backlog-dir-seeded-structured-keys.sh read it): the entry
# shape is shown as a fenced example whose frontmatter lists keys one per line;
# the keys it carries are among the eleven and in the stated order, and it
# carries at least the eight that are not conditional (parked_until, waits_for
# and waits_for_type are "present only" on some entries, so an example may
# leave them to prose; need has a default, as priority does, and the example
# carries it, tasks.md 1.1). Every one of the eleven is named somewhere in the
# block.
#
# Executes project-init, then reads the block it seeds (third situation for the
# assertions); the check is discriminated on specimens first. Red until task
# 1.1 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime
source "$TESTLIB"

R=docs/backlog/AGENTS.md
KEYS=(priority parked_until kind need waits_on waits_for waits_for_type design_with workstream recorded_by re_checked)
REQUIRED=(priority kind need waits_on design_with workstream recorded_by re_checked)

# ---- local arrangement (test-plan.md, Missing shared arrangement: fenced_fm_keys)
# The keys of the first frontmatter block inside a fence, one per line; a line
# that is not `key: ...` is printed as `!<line>`.
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
  [ -n "$keys" ] || { echo "FAIL: no fenced example frontmatter in $file" >&2; return 1; }
  while IFS= read -r k; do
    idx=-1
    for i in "${!KEYS[@]}"; do [ "${KEYS[$i]}" = "$k" ] && idx=$i; done
    [ "$idx" -ge 0 ] || { echo "FAIL: the example carries a key the requirement does not name: $k" >&2; return 1; }
    [ "$idx" -gt "$pos" ] || { echo "FAIL: key $k is out of the stated order" >&2; return 1; }
    pos=$idx
  done <<< "$keys"
  for k in "${REQUIRED[@]}"; do
    found=0
    while IFS= read -r i; do [ "$i" = "$k" ] && found=1; done <<< "$keys"
    [ "$found" = 1 ] || { echo "FAIL: the example's frontmatter lacks $k" >&2; return 1; }
  done
  for k in "${KEYS[@]}"; do
    grep -q -F -- "\`$k\`" "$file" || grep -q -E -- "^$k:" "$file" || { echo "FAIL: the block never names $k" >&2; return 1; }
  done
  if grep -q -i 'depends on' "$file"; then echo "FAIL: the block names Depends on" >&2; return 1; fi
  return 0
}

# ---- the case
spec="$TESTDIR/specimen"
mkdir -p "$spec"
ok() {
  # shellcheck disable=SC2016 # backticks are literal text in a fixture
  printf '%s\n' 'An entry may carry `parked_until`, `waits_for` and `waits_for_type` as well.' '' '```markdown' '---' \
    'priority: normal' 'kind: change' 'need: should' 'waits_on: []' 'design_with: []' 'workstream: none' \
    'recorded_by: some-change' 're_checked: 2026-11-05' '---' '' 'What and why.' '```'
}
ok > "$spec/ok.md"
check_keys "$spec/ok.md" || { echo "FAIL: discriminator — the check rejects a conforming block" >&2; exit 1; }
ok | sed 's/^need: should$/NEED/; s/^kind: change$/need: should/; s/^NEED$/kind: change/' > "$spec/order.md"
ok | grep -v '^need:' > "$spec/no-need.md"
# shellcheck disable=SC2016 # backticks are literal text in a pattern
ok | sed 's/ and `waits_for_type`//' > "$spec/unnamed-type.md"
ok | sed 's/as well\./as well, and Depends on./' > "$spec/depends.md"
ok | sed 's/^need: should$/size: small/' > "$spec/unknown.md"
for bad in order no-need unnamed-type depends unknown; do
  if check_keys "$spec/$bad.md" 2>/dev/null; then
    echo "FAIL: discriminator — the check accepts the $bad specimen" >&2
    exit 1
  fi
done

work="$TESTDIR/work"
mkdir -p "$work"
(cd "$work" && bash "$PROJECT_INIT") > "$TESTDIR/report.txt" 2>&1
assert_file "$work/$R" "the seeded block this case reads"
check_keys "$work/$R" || exit 1
