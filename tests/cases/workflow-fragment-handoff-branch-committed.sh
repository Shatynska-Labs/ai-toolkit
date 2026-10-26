#!/usr/bin/env bash
# Scenario (mechanical half only): A handoff is not left uncommitted on a
# branch the session leaves.
# Requirement: A second change surfacing in a session is recorded in the
# backlog. Change: reconcile-commit-rule-with-spec (session-workflow,
# MODIFIED).
#
# SPECIFIED: "The fragment SHALL direct committing that branch as soon as it
# is opened." and "The commit is made, not proposed, so the fragment states no
# path for a declined one."
# DERIVED (lexical proxies, unresolved question Q1 in test-plan.md): the rule
# is read from the fragment's lines naming a handoff (the fragment keeps one
# paragraph per line); "commit that/the/this/its branch" is the direction,
# "at once", "immediately" or "as soon as" its timing; "propose(s|d) a commit"
# and "declin"/"unsaved" mark the superseded proposed-and-declined form.
#
# Not asserted: that a session does commit the branch.
#
# Static read (third situation): the fragment already carries the rule
# (design.md, Context), so green at authoring; every scan is discriminated by
# a mutant of the conforming fixture below (tests/cases/lib/line-scan.sh). A
# failing scan reports its tag and regex, never the fragment's text.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

F=rules/development-workflow.md
line_select 'handoff'
line_scan require commit-branch 'commit (that|the|this|its) (handoff |new )?branch'
line_scan require at-once '(at once|immediately|as soon as)'
# shellcheck disable=SC2016 # the backticks are literal markdown, not a command substitution
line_scan forbid no-proposed-commit 'propos(e|es|ed|ing) (a )?commit' \
  'Propose a commit on that branch as soon as it is opened, carrying its `handoff.md`.'
# shellcheck disable=SC2016 # the backticks are literal markdown, not a command substitution
line_scan forbid no-declined-path '(declin|unsaved)' \
  'Where that commit is declined, report that the `handoff.md` is unsaved and stop.'

fixture="$TESTDIR/fragment.md"
cat > "$fixture" <<'FIXTURE'
# Workflow

- Where it **does not**: record it in `docs/backlog/`, or open it on a branch of its own carrying a `handoff.md` and no proposal. Commit that branch at once: you are not returning to it, so no later commit carries the handoff.
FIXTURE

line_run "$fixture" "$F"
