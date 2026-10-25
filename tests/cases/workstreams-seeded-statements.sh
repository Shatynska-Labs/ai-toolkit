#!/usr/bin/env bash
# Scenario: A project without a workstream register receives the seeded file
# — "created with every statement listed above".
# Requirement: A workstream register is seeded where none exists.
# Change: add-workstreams (project-bootstrap, ADDED).
#
# SPECIFIED: the created file states each of the requirement's listed
# statements: a workstream is a goal taking more than one change, one
# kebab-case `<name>.md` per open one, unique among open and archived
# workstreams and not a change's name, referred to only by that name; the
# file holds the plan and never its progress, a step's status read from the
# repository by name, first match winning, from the freshly fetched trunk,
# branches and pull requests, and the backlog; order gates nothing, Waits on
# says so; the file is edited only when the plan changes; opened on the
# operator's decision and committed with the first change's plan or as work
# too small to be a change; attached changes and entries placed or detached
# at the next edit and at the latest at a change's archive; archived to a
# dated `archive/` file in the record's commit after unfinished steps and
# entries are dealt with; abandonment; kept short, decisions pointed to; the
# README kept when there is no workstream.
#
# DERIVED (wording): the requirement fixes what the text states, not the text.
# Each statement is asserted by one stable phrase from the seeded text in
# design.md decision 8, as backlog-seeded-new-project.sh does for the backlog.
# A rewording that keeps a statement but drops its phrase fails here.
#
# Executes the tool and reads its output; no fixture owed. Red until the
# concern lands (state 2: the file this case reads is absent).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
bash "$PROJECT_INIT" >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"

r="$work/docs/workstreams/README.md"
assert_file "$r" "the seeded file this case reads"

assert_contains "$r" "A workstream is a goal that takes more than one change" "definition"
# shellcheck disable=SC2016 # backticks are literal markdown, not expansions
assert_contains "$r" '`<name>.md`' "one file per open workstream, named <name>.md"
assert_contains "$r" "kebab-case" "named in kebab-case"
assert_contains "$r" "unique among workstreams, open and archived" "unique among open and archived workstreams"
assert_contains "$r" "is not also a change's name" "not also a change's name"
assert_contains "$r" "only by that name" "referred to only by that name"
assert_contains "$r" "holds the plan and never its progress" "plan, never progress"
assert_contains "$r" "the first of these that holds wins" "status precedence: first match wins"
assert_contains "$r" "freshly fetched trunk" "status read from the freshly fetched trunk"
assert_contains "$r" "archived change of that name" "done: an archived change of the step's name"
assert_contains "$r" "local or remote branch" "in flight: a local or remote branch"
assert_contains "$r" "open pull request" "in flight: an open pull request"
assert_contains "$r" "holds an entry of that name" "recorded: a backlog entry of that name"
assert_contains "$r" "planned otherwise" "planned otherwise"
assert_contains "$r" "Edit the file only when the plan changes" "edited only when the plan changes"
assert_contains "$r" "gates nothing" "step order gates nothing"
assert_contains "$r" "Open a workstream when the operator decides" "opened on the operator's decision"
assert_contains "$r" "with the plan of the first change that advances it" "committed with the first change's plan"
assert_contains "$r" "work too small to be a change" "or as work too small to be a change"
assert_contains "$r" "at the latest at the archive of a change in it" "attached work placed at the latest at an archive"
# shellcheck disable=SC2016 # backticks are literal markdown, not expansions
assert_contains "$r" '`archive/<YYYY-MM-DD>-<name>.md`' "archived to a dated file"
assert_contains "$r" "in the commit that carries the record" "in the record's commit"
assert_contains "$r" "backlog entry naming no workstream" "a still-wanted step kept as an entry naming no workstream"
assert_contains "$r" "continues as its own change" "an in-flight step continues as its own change"
assert_contains "$r" "re-point or clear every backlog entry still naming it" "entries re-pointed or cleared"
assert_contains "$r" "**Abandoned**" "abandonment line"
assert_contains "$r" "Keep a workstream short" "kept short"
assert_contains "$r" "that the file points to" "lasting decisions pointed to"
assert_contains "$r" "Keep this file when there is no workstream" "README kept when there is no workstream"
