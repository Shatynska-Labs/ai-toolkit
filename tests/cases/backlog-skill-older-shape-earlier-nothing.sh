#!/usr/bin/env bash
# Scenario (mechanical half only): An earlier absent value is read as the
# current one.
# Requirement: Entries in an older shape are reported, not rewritten.
# Change: list-the-entry-fields (backlog-maintenance, MODIFIED).
#
# SPECIFIED: where an entry gives Design with or Workstream the absent value
# an earlier shape used, `nothing`, the skill reads it as the file's absent
# value, and does not report it as a name, as unplaced or as unclassified.
# DERIVED (operationalisation): a paragraph (line) of SKILL.md carrying
# `nothing` and `earlier` or `older` also carries "absent value" or `none`,
# names `workstream`, and states it is not unclassified, unplaced or a name.
# Read from the whole file, as backlog-skill-older-shape-unclassified.sh
# reads `unclassified`: design.md decision 4 places it under *Entries in an
# older shape*, but no case has established that heading exists.
#
# Not asserted: that pick or the workstreams operation reads such an entry as
# naming no workstream. Conduct; verified by reading.
#
# Static read (third situation): red until task 2.1 lands; every scan is
# discriminated by a mutant in line_discriminate.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

# shellcheck disable=SC2016 # backticks are literal markdown in the regex
line_select '`nothing`'
line_select 'earlier|older'
# shellcheck disable=SC2016 # backticks are literal markdown in the regex
line_scan require read-as-absent 'absent value|`none`'
line_scan require names-workstream 'workstream'
line_scan require not-unclassified 'unclassified|unplaced|as a name'

fixture="$TESTDIR/SKILL.md"
cat > "$fixture" <<'FIXTURE'
# backlog

## Entries in an older shape

An entry missing Kind or Waits on is listed as unclassified.
Where Design with or Workstream gives `nothing`, the absent value an earlier shape used, read it as the file's absent value: never as a name, as unplaced or as unclassified.
FIXTURE

line_run "$fixture" skills/backlog/SKILL.md
