#!/usr/bin/env bash
# Scenario: A binding restates no entry rule.
# Requirement: Recording and sweeping the backlog are bound to a skill.
# Change: match-backlog-entries-to-a-workstream (session-workflow, ADDED).
#
# SPECIFIED: a binding naming `ai-toolkit:backlog` names the skill and the operation,
# and names no entry field. Both forms.
# DERIVED (operationalisation): the entry's nine frontmatter keys, as the seeded
# shape lists them, backticked; a binding is the paragraph opening with its label.
#
# Static read (third situation); every scan is discriminated by a mutant. Red at
# authoring (state 2: neither fragment holds such a paragraph); goes green as task
# 1.3 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

# Local arrangement (test-plan.md, Missing shared arrangement: check_both_forms).
# Discriminates on the fixture, then holds both fragments to the scans.
check_both_forms() {
  local rel st status=0
  line_discriminate "$1" || exit 1
  for rel in rules/development-workflow.md rules/development-workflow-direct.md; do
    line_check "$TOOLKIT_ROOT/$rel"
    st=$?
    [ "$st" -ne 2 ] || echo "FAIL: target absent — $rel has no paragraph this case reads" >&2
    [ "$st" -eq 0 ] || status=1
  done
  exit "$status"
}

line_select '^_claude code binding:_'
line_select 'ai-toolkit:backlog'
line_scan require names-operation '[*][*](record|sweep)[*][*]'
# shellcheck disable=SC2016 # backticks are literal markdown in the regex and specimen
line_scan forbid no-entry-field '`(priority|parked_until|kind|waits_on|waits_for|design_with|workstream|recorded_by|re_checked)`' 'Set its `workstream` first.'

fixture="$TESTDIR/fragment.md"
cat > "$fixture" <<'FIXTURE'
# Workflow

_Claude Code binding:_ record an entry with `ai-toolkit:backlog`'s **record**.

_Claude Code binding:_ carry out the entries' part of this re-read with `ai-toolkit:backlog`'s **sweep**.
FIXTURE

check_both_forms "$fixture"
