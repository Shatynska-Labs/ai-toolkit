#!/usr/bin/env bash
# seed-the-worktree-ignore-entry, project-foundation (MODIFIED requirement
# "The foundation covers a fixed set of decisions including non-goals"),
# scenario (mechanical half only): Recursive tools are kept out of the
# working-tree roots.
#
# The scenario's subject is a decision taken in a foundation conversation,
# which no script can run. What is mechanical is that the checklist the
# conversation follows, rules/project-foundation.md, carries the obligation
# on its provisioning concern — without it, nothing prompts the decision.
# Read from the lines of the fragment that mention provisioning:
#   [root-worktrees]         SPECIFIED  names `.worktrees/`
#   [root-claude-worktrees]  SPECIFIED  names `.claude/worktrees/`
#   [recursive]              SPECIFIED  speaks of tools that recurse the tree
#                                       ("recurs", DERIVED operationalisation)
#   [ignore-file]            SPECIFIED  says those tools do not read the
#                                       ignore file ("ignore", DERIVED
#                                       operationalisation)
#   [no-tool]                SPECIFIED property ("The checklist SHALL name
#                                       each concern without naming a tool");
#                                       the tool list is DERIVED and not
#                                       exhaustive
#
# The selector is the word "provisioning" (DERIVED anchor). The case's author
# did not read the fragment, so it does not know how many lines mention
# provisioning; each scan is satisfied by any one of them, not necessarily the
# same line. That is weaker than a single-line scope, and is recorded in the
# change's test-plan.md.
#
# Not asserted: that a foundation conversation actually decides, for each
# chosen recursive tool, how it is kept out of the roots, or that the stack
# has none. Conversational; verified by reading and by the skill's trigger
# checks.
#
# Static read (third situation); every scan is discriminated by a mutant over
# the fixture below. Red at authoring on [root-worktrees],
# [root-claude-worktrees] and possibly [recursive]/[ignore-file] until task
# 2.1 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select 'provisioning'
line_scan require root-worktrees '[.]worktrees/'
line_scan require root-claude-worktrees '[.]claude/worktrees/'
line_scan require recursive 'recurs'
line_scan require ignore-file 'ignore'
line_scan forbid no-tool '(^|[^a-z])(pytest|jest|vitest|eslint|ruff|docker)([^a-z]|$)' 'Use pytest with docker.'

fixture="$TESTDIR/project-foundation.md"
cat > "$fixture" <<'FIXTURE'
# Foundation checklist

- **Provisioning** — what a new working tree needs before its verification can be trusted, including keeping every tool that recurses the tree without reading the ignore file out of the roots the workflow places working trees under (`.worktrees/`, and `.claude/worktrees/` by its Claude Code binding).
FIXTURE

line_run "$fixture" rules/project-foundation.md
