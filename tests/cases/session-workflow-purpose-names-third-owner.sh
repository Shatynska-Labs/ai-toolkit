#!/usr/bin/env bash
# DERIVED from the change, not from a delta-spec scenario: proposal.md ("What
# Changes": the Purpose names the same three owners), design.md decision 2,
# and task 2.1 — a delta cannot change a Purpose, so it is edited in the main
# specification directly, and no scenario reaches it.
# Change: reconcile-commit-rule-with-spec (session-workflow Purpose).
#
# Asserted: the Purpose of openspec/specs/session-workflow/spec.md names
# `project-bootstrap` and `change-code-review`, the latter against "`build`'s
# Claude Code binding". DERIVED (Q1): `change-code-review` is matched as a
# whole name, so `change-code-reviewer` does not satisfy it; the binding in
# task 2.1's wording.
#
# Static read (third situation). Red at authoring and until task 2.1 lands
# (state 1 on real content: the Purpose names `project-bootstrap` and
# `toolkit-structure` only); every scan is discriminated by a mutant of the
# conforming fixture below.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=openspec/specs/session-workflow/spec.md
scan require "$S" purpose bootstrap-named 'project-bootstrap'
scan require "$S" purpose code-review-named 'change-code-review([^e]|$)'
scan require "$S" purpose binding-content 'build.?.?.?s claude code binding'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/openspec/specs/session-workflow"
cat > "$fixture/$S" <<'FIXTURE'
# session-workflow Specification

## Purpose
It shares the workflow fragment with `project-bootstrap`, which owns how that fragment reaches a project, and with `change-code-review`, which owns the content of `build`'s Claude Code binding; this capability owns what the rest of the rules say.

## Requirements

### Requirement: Something

`change-code-review` is named here too, outside the Purpose.
FIXTURE

scan_run "$fixture"
