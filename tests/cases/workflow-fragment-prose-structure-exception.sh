#!/usr/bin/env bash
# Scenario (mechanical half only): Markdown structure still takes its own line
# breaks.
# Requirement: Fragment prose is not hard-wrapped.
# Change: reconcile-commit-rule-with-spec (session-workflow, ADDED).
#
# SPECIFIED: the direction excepts the line breaks Markdown's own structure
# requires, so a list, heading, table or fenced block is not forbidden its
# breaks; and it "SHALL NOT enumerate the structures it leaves alone beyond
# Markdown's own line structure".
# DERIVED (lexical proxies, Q1 in test-plan.md): the rule is read from the
# fragment's lines naming Markdown prose or hard-wrapping; "markdown's own structure" (or "own
# line structure") is the exception, quoted in design.md decision 3; an
# enumeration is detected by "frontmatter", "code block", "fenced" or "table"
# as whole words on those lines.
#
# Not asserted: that a session breaks lines where a structure requires.
#
# Static read (third situation): the fragment already carries the rule
# (design.md, Context), so green at authoring; every scan is discriminated by
# a mutant of the conforming fixture below. A failing scan reports its tag
# only, never the fragment's text.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

F=rules/development-workflow.md
line_select 'markdown prose|hard[- ]?wrap'
line_scan require structure-exception 'markdown.?.?s own (line )?structure'
line_scan forbid no-enumeration '(^|[^a-z])(front ?matter|code blocks?|fenced|tables?)([^a-z]|$)' \
  'Do not hard-wrap prose; frontmatter, code blocks and tables are left as they are.'

fixture="$TESTDIR/fragment.md"
cat > "$fixture" <<'FIXTURE'
# Workflow

## Throughout

**Markdown prose.** Do not hard-wrap Markdown prose: keep each paragraph on a single line whatever its length, and break a line only where Markdown's own structure requires one.
FIXTURE

line_run "$fixture" "$F"
