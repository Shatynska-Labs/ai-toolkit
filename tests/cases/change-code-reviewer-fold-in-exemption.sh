#!/usr/bin/env bash
# Scenarios (mechanical half only): A folded-in edit made as the conventions
# direct; A folded-in edit outside the change's files; No fold-in rule in the
# project.
# Requirement: Out-of-scope edits are reported as scope.
# Change: fold-small-work-in (change-code-review, MODIFIED).
#
# SPECIFIED: an edit the project's conventions let a change fold in, made as
# they direct, is not `scope`, and one falling short of their conditions is;
# the conditions come from the project's conventions and the reviewer SHALL
# NOT state them itself — a project whose conventions name no fold-in rule
# has none; the conditions are judged from the range's commits as well as
# its diff.
# DERIVED (operationalisation, Q1/Q3): the agent is one paragraph per line, so
# "fold" and "convention" share a line, and "fold" and the backticked
# `scope` kind share a line; falling short is "falls short" or "fails
# any/one"; the no-rule case is "name(s)/state(s) no fold";
# the commits are read with `git log --name-only` (design.md decision 6 and
# task 2.1, not the spec). Not stating the conditions is operationalised as
# the fragment's two most distinctive condition phrases, "screen of diff" and
# "their direct tests", appearing nowhere in the agent.
#
# Not asserted: which finding the reviewer emits on a given diff. That is its
# reasoning on a dispatch, exercised by the cold-run check (tasks 2.2-2.3).
#
# Static read: red until the exemption lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

A=agents/change-code-reviewer.md
# shellcheck disable=SC2016 # backticks are literal markdown in the regex
scan require "$A" "" fold-defers-to-conventions 'fold.*convention|convention.*fold'
# shellcheck disable=SC2016 # backticks are literal markdown in the regex
scan require "$A" "" fold-not-scope 'fold.*`scope`|`scope`.*fold'
scan require "$A" "" short-is-scope 'fall(s|ing)? short|fail(s|ing)? (any|one)'
scan require "$A" "" no-rule-none '(name|names|state|states) no fold'
scan require "$A" "" reads-commits 'git log --name-only'
scan forbid "$A" "" states-size 'screen of diff' 'Folded-in work is about a screen of diff.'
scan forbid "$A" "" states-files 'their direct tests' 'It touches only the change'"'"'s files or their direct tests.'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/agents"
cat > "$fixture/$A" <<'FIXTURE'
# change-code-reviewer

## Resolving the target

Read the range's diff, and its commits with `git log --name-only <base>..<head>`, so each commit's message and files are known.

## Scope

An edit the change's stated scope does not cover is a `scope` finding.
An edit the project's conventions let a change fold in, made as they direct, is not a `scope` finding; one falling short of any of their conditions is. A project whose conventions name no fold-in rule has none.
FIXTURE

scan_run "$fixture"
