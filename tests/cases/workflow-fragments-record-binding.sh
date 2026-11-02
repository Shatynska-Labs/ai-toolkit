#!/usr/bin/env bash
# Scenario (first half): Both bindings name a shipped skill: the binding at *A
# second change surfacing*.
# Requirement: Recording and sweeping the backlog are bound to a skill.
# Change: match-backlog-entries-to-a-workstream (session-workflow, ADDED).
#
# SPECIFIED: both forms carry, under *A second change surfacing*, a Claude Code
# binding naming `ai-toolkit:backlog`'s **record** as what a session uses to record
# an entry, and the library ships skills/backlog/SKILL.md.
# DERIVED (wording, design.md decision 5): the paragraph is selected by the binding
# label, the skill and "record an entry".
# DERIVED (placement): "under" is read as after the paragraph opening `**A second
# change surfacing`, with no bold-led paragraph or heading between.
#
# Not asserted: that a session uses the skill. Conduct.
#
# Static read (third situation); every scan and the placement check are
# discriminated. Red at authoring (state 2 for the paragraph: neither fragment holds
# it); goes green as task 1.3 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

ANCHOR='^[*][*]A second change surfacing'
BINDING='^_Claude Code binding:_.*ai-toolkit:backlog.*[*][*]record[*][*]'

# Local arrangement (test-plan.md, Missing shared arrangement: binding_under,
# check_both_forms).
# binding_under FILE ANCHOR BINDING: 0 where a line matching BINDING follows a line
# matching ANCHOR before the next bold-led paragraph or heading.
binding_under() {
  awk -v a="$2" -v b="$3" '
    $0 ~ a { open = 1; next }
    open && $0 ~ b { found = 1; exit }
    open && /^(\*\*|#)/ { open = 0 }
    END { exit found ? 0 : 1 }
  ' "$1"
}
# check_both_forms FIXTURE: discriminates on the fixture, then holds both fragments
# to the scans and the placement.
check_both_forms() {
  local rel st status=0
  line_discriminate "$1" || exit 1
  for rel in rules/development-workflow.md rules/development-workflow-direct.md; do
    line_check "$TOOLKIT_ROOT/$rel"
    st=$?
    [ "$st" -ne 2 ] || echo "FAIL: target absent — $rel has no paragraph this case reads" >&2
    [ "$st" -eq 0 ] || status=1
    binding_under "$TOOLKIT_ROOT/$rel" "$ANCHOR" "$BINDING" || { echo "FAIL: [placement] $rel carries no record binding under A second change surfacing" >&2; status=1; }
  done
  exit "$status"
}

line_select '^_claude code binding:_'
line_select 'ai-toolkit:backlog'
line_select 'record an entry'
line_scan require names-record '[*][*]record[*][*]'

fixture="$TESTDIR/fragment.md"
cat > "$fixture" <<'FIXTURE'
# Workflow

**A second change surfacing.** Record it before doing anything else about it.

- Where it **does**: record the dependency.
- Where it **does not**: record it in `docs/backlog/`.

_Claude Code binding:_ record an entry with `ai-toolkit:backlog`'s **record**.

**Next rule.** Something else.
FIXTURE

binding_under "$fixture" "$ANCHOR" "$BINDING" || { echo "FAIL: discriminator — the placement check rejected the conforming fixture" >&2; exit 1; }
misplaced="$TESTDIR/misplaced.md"
awk '/^_Claude Code binding:_/ { held = $0; next } { print } END { print ""; print held }' "$fixture" > "$misplaced"
if binding_under "$misplaced" "$ANCHOR" "$BINDING"; then
  echo "FAIL: discriminator — the placement check accepted a binding under another paragraph" >&2
  exit 1
fi

assert_file "$TOOLKIT_ROOT/skills/backlog/SKILL.md" "the skill the binding names"
check_both_forms "$fixture"
