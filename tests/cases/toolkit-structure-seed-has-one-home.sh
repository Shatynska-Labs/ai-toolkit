#!/usr/bin/env bash
# Scenario: A text two tools write has one home.
# Requirement: Documentation separation of concerns.
# Change: one-file-per-backlog-entry (toolkit-structure, MODIFIED).
#
# SPECIFIED: AGENTS.md places the text scripts/project-init and
# scripts/backlog-migrate both write as a project's docs/backlog/README.md
# under scripts/seed/, and states why it is not a rules/ fragment: a fragment
# carries `kind` frontmatter and is read as instructions, whereas a seed is
# written byte for byte as a file the project then owns.
# DERIVED (operationalisation): the paragraph naming `scripts/seed/` names
# the backlog's README, `rules/`, frontmatter, and writing verbatim or byte
# for byte.
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# until task 1.0 lands (state 2: no paragraph names scripts/seed/).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select 'scripts/seed/'
line_scan require names-backlog-readme 'backlog'
line_scan require not-rules 'rules/'
line_scan require frontmatter 'frontmatter'
line_scan require verbatim 'verbatim|byte for byte|byte-for-byte'

fixture="$TESTDIR/AGENTS.md"
cat > "$fixture" <<'FIXTURE'
# conventions

`scripts/seed/` holds the texts the shipped tools write into a project verbatim, such as the backlog's README. It is not `rules/`: a fragment carries `kind` frontmatter and is read as instructions, whereas a seed is written byte for byte as a file the project then owns.
FIXTURE

line_run "$fixture" AGENTS.md
