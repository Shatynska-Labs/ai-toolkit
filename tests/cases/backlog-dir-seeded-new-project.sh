#!/usr/bin/env bash
# Scenario: A project without a backlog receives the seeded file (new-project
# mode). Requirement: A backlog is seeded where none exists.
# Change: one-file-per-backlog-entry (project-bootstrap, MODIFIED).
#
# SPECIFIED: in a target with neither docs/backlog/ nor docs/backlog.md,
# docs/backlog/README.md is created (docs/ and docs/backlog/ with it), no
# entry file is created, no docs/backlog.md, and the report states the
# backlog was created.
# SPECIFIED: the README states the listed statements; this case reads those
# not read by a case of their own: the directory lists changes identified and
# not yet archived, recorded instead of being folded in, one file per entry;
# <name>.md in kebab-case, the only identifier, no heading repeating it,
# referred to only by that name, revisable, a fix takes it as its branch's
# name only; no order; kept short, without line numbers, census tables or
# step-by-step plans; deleted when archived, taken as a fix, made obsolete,
# or not to be made; at an archive, entries unblocked, unparked or made stale
# updated and re_checked set; the README kept when there are no entries; the
# body written for a session that has not seen the work.
# DERIVED (wording): each statement is read by one tolerant pattern, listed
# below; a rewording that keeps a statement but avoids its pattern fails here.
# DERIVED (token): `backlog: created` is the report contract's line
# (tests/README.md).
#
# Executes the tool; each scan is discriminated on the fixture. Red until
# tasks 1.1 and 1.2 land (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

R=docs/backlog/README.md

# Local arrangement (test-plan.md, Missing shared arrangement: seeded-output
# scan wrappers). static-scan.sh's scan_run checks $TOOLKIT_ROOT only; these
# point the same scans at the tree project-init writes.
#
# fixture_readme: writes stdin as the fixture tree's README.
fixture_readme() {
  mkdir -p "$TESTDIR/fixture/docs/backlog"
  cat > "$TESTDIR/fixture/$R"
}
# seed_and_check: discriminates every scan on the fixture, runs project-init
# in a fresh directory, then holds the seeded README to the scans.
seed_and_check() {
  local work="$TESTDIR/work" st
  scan_discriminate "$TESTDIR/fixture" || exit 1
  mkdir -p "$work"
  (cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
  scan_check "$work"
  st=$?
  if [ "$st" -eq 2 ]; then
    echo "FAIL: target absent — project-init seeded no docs/backlog/README.md" >&2
  fi
  [ "$st" -eq 0 ] || exit 1
}

scan require "$R" "" not-yet-archived 'not yet archived'
scan require "$R" "" instead-of-folded 'instead of being folded|rather than (being )?folded'
scan require "$R" "" one-file-per-entry 'one file per entry|a file of its own|its own file'
scan require "$R" "" name-md '<name>[.]md'
scan require "$R" "" kebab 'kebab-case'
scan require "$R" "" only-identifier 'only identifier'
scan require "$R" "" no-heading 'no heading|without a heading'
scan require "$R" "" by-name-only 'only by (that|its) name'
scan require "$R" "" name-revisable 'revise|rename'
scan require "$R" "" fix-branch 'fix[^.]*branch'
scan require "$R" "" no-order 'no order|not ordered|unordered'
scan require "$R" "" short 'short'
scan require "$R" "" line-numbers 'line numbers'
scan require "$R" "" census 'census'
scan require "$R" "" step-plans 'step-by-step'
scan require "$R" "" delete-archived 'delet[^.]*archived'
scan require "$R" "" delete-as-fix 'as a fix'
scan require "$R" "" delete-obsolete 'obsolete'
scan require "$R" "" delete-not-made 'will not be made'
scan require "$R" "" archive-unblocked 'unblocked'
scan require "$R" "" archive-unparked 'unparked'
scan require "$R" "" archive-stale 'stale'
scan require "$R" "" archive-rechecked 're_checked'
scan require "$R" "" kept-empty 'no entries'
scan require "$R" "" body-unseen 'has not seen the work'

fixture_readme <<'FIXTURE'
# Backlog

This directory lists changes this project has identified and not yet archived, each recorded here instead of being folded into the change that found it, one file per entry beside this README.

An entry's file is `<name>.md`, the change's kebab-case name, which the session that opens the change may revise. The file's name is the entry's only identifier, and the file carries no heading repeating it. Refer to an entry only by that name. A fix takes it as its branch's name only.

Entries carry no order.

Keep an entry short, without line numbers, census tables or step-by-step plans.

Delete an entry's file when its change is archived, when the operator takes it as a fix rather than a change, when a change makes it obsolete, or when the operator decides the change will not be made.

When a change is archived, update the entries it unblocked, unparked or made stale, and set their `re_checked`.

Keep this README when there are no entries.

Write the body for a session that has not seen the work that found it.
FIXTURE

seed_and_check

work="$TESTDIR/work"
assert_contains "$TESTDIR/report.txt" "backlog: created" "the report states the backlog was created"
assert_file_absent "$work/docs/backlog.md" "no single file is seeded"
listing="$(ls -A "$work/docs/backlog")"
if [ "$listing" != "README.md" ]; then
  echo "FAIL: docs/backlog/ should hold the README alone, holds:" >&2
  printf '%s\n' "$listing" >&2
  exit 1
fi
