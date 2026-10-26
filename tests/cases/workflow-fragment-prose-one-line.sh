#!/usr/bin/env bash
# Scenario (mechanical half only): A session writing prose keeps a paragraph
# on one line.
# Requirement: Fragment prose is not hard-wrapped.
# Change: reconcile-commit-rule-with-spec (session-workflow, ADDED).
#
# SPECIFIED: the fragment directs that Markdown prose is not hard-wrapped, each
# paragraph kept on a single line ("the fragment has told it so").
# DERIVED (lexical proxies, Q1 in test-plan.md): the rule is read from the
# fragment's lines naming Markdown prose or hard-wrapping; a negation ("not", "never", "no",
# "don't", "do not") before "hard-wrap" is the direction, "single line" or
# "one line" the paragraph's form.
#
# Not asserted: that a session keeps its paragraphs on one line; that the
# direction is phrased as an imperative (no lexical test separates "do not
# hard-wrap" from "prose is not hard-wrapped" reliably).
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
line_scan require negated '(not|never|no|don.t) (be )?hard[- ]?wrap'
line_scan require one-line '(single|one) line'

fixture="$TESTDIR/fragment.md"
cat > "$fixture" <<'FIXTURE'
# Workflow

## Throughout

**Markdown prose.** Do not hard-wrap Markdown prose: keep each paragraph on a single line whatever its length, and break a line only where Markdown's own structure requires one.
FIXTURE

line_run "$fixture" "$F"
