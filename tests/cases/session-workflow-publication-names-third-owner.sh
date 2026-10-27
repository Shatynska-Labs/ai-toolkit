#!/usr/bin/env bash
# Scenario: An editor learns every owner of the fragment's content from this
# capability.
# Requirement: The session obligations are published in the workflow fragment
# and one binding fragment. Change: reconcile-commit-rule-with-spec
# (session-workflow, MODIFIED).
#
# SPECIFIED: the requirement names `project-bootstrap` as owning how the
# fragment reaches a project and its shape, `change-code-review` as owning the
# content of `build`'s Claude Code binding, and this capability as owning what
# the rest of the rules say.
# DERIVED (Q1, Q2 in test-plan.md): the requirement is read from the main
# specification, openspec/specs/session-workflow/spec.md, under its own
# heading; the owners are matched in the delta's wording ("`project-bootstrap`
# owns how the workflow fragment reaches a project", "`change-code-review`
# owns", "`build`'s Claude Code binding", "This capability owns what the
# rest"), each scan independently, not as one sentence.
#
# Static read (third situation). Red at authoring and until the change is
# archived (state 1 on real content: the main specification's requirement
# names two owners and says "owns what the session-derived rules say"); every
# scan is discriminated by a mutant of the conforming fixture below.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=openspec/specs/session-workflow/spec.md
W='published in the workflow fragment and one binding fragment'
scan require "$S" "$W" owner-bootstrap 'project-bootstrap.? owns how the workflow fragment reaches a project'
scan require "$S" "$W" owner-code-review 'change-code-review.? owns'
scan require "$S" "$W" binding-content 'build.?.?.?s claude code binding'
scan require "$S" "$W" owner-rest 'this capability owns what the rest'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/openspec/specs/session-workflow"
cat > "$fixture/$S" <<'FIXTURE'
# session-workflow Specification

## Requirements

### Requirement: The session obligations are published in the workflow fragment and one binding fragment

`project-bootstrap` owns how the workflow fragment reaches a project and what shape it takes there. `change-code-review` owns one sentence of the workflow fragment: the content of `build`'s Claude Code binding. This capability owns what the rest of the session-derived rules say.

### Requirement: A second change surfacing in a session is recorded in the backlog

Nothing here.
FIXTURE

scan_run "$fixture"
