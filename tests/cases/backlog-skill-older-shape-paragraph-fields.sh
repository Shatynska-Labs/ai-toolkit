#!/usr/bin/env bash
# Requirement text, not a scenario: "Fields written as paragraphs rather than
# as a list are read the same as listed ones." Accounted under the
# requirement's scenario An earlier absent value is read as the current one,
# which is the requirement this sentence was added to.
# Requirement: Entries in an older shape are reported, not rewritten.
# Change: list-the-entry-fields (backlog-maintenance, MODIFIED).
#
# SPECIFIED (requirement text): the skill reads paragraph fields the same as
# listed ones.
# DERIVED (operationalisation): a paragraph (line) of SKILL.md naming
# `paragraph` and `list` also carries `same`, `alike` or `either`.
#
# Not asserted: that an operation reads a paragraph entry correctly.
# Conduct; verified by reading.
#
# Static read (third situation): red until task 2.1 lands; every scan is
# discriminated by a mutant in line_discriminate.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select 'paragraph'
line_select 'list'
line_scan require read-alike 'same|alike|either'

fixture="$TESTDIR/SKILL.md"
cat > "$fixture" <<'FIXTURE'
# backlog

## Entries in an older shape

Fields written as paragraphs rather than as a list are read the same as listed ones.
FIXTURE

line_run "$fixture" skills/backlog/SKILL.md
