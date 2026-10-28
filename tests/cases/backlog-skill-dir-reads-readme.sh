#!/usr/bin/env bash
# Scenario (mechanical half only): A project's preamble differs from the
# seeded one (as revised: the project's README).
# Requirement: The skill restates neither the entry rules nor the workflow's
# obligations. Change: one-file-per-backlog-entry (backlog-maintenance,
# MODIFIED).
#
# SPECIFIED: the skill reads how an entry is shaped, named, kept and deleted
# from `docs/backlog/README.md`, and restates none of it.
# DERIVED (operationalisation): SKILL.md names the README; neither SKILL.md
# nor references/audit.md restates the new shape's rules — the only
# identifier, no heading repeating the name, the absent-key meanings, the
# flat form's quoting rule. The rules of the earlier shape are
# backlog-skill-restates-no-entry-rule.sh's.
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# until task 3.2 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
A=skills/backlog/references/audit.md
fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog/references"

scan require "$S" "" reads-readme 'docs/backlog/agents[.]md'
for f in "$S" "$A"; do
  b="${f##*/}"; b="${b%.md}"
  scan forbid "$f" "" "$b-only-identifier" 'only identifier' "The file's name is the entry's only identifier."
  scan forbid "$f" "" "$b-no-heading" 'carries no heading' "The file carries no heading repeating its name."
  # shellcheck disable=SC2016 # backticks and $ are literal text in a pattern or fixture
  scan forbid "$f" "" "$b-absent-empty" 'without `?waits_on`?[^.]*empty list' "An entry without waits_on has the empty list."
  scan forbid "$f" "" "$b-nothing-nested" 'nothing is nested' "Nothing is nested, and no value spans lines."
done

cat > "$fixture/$S" <<'FIXTURE'
# backlog

Read the entry rules from `docs/backlog/AGENTS.md`; do not restate them here.
FIXTURE
cat > "$fixture/$A" <<'FIXTURE'
# audit brief

Verify each entry against the code and the changes.
FIXTURE

scan_run "$fixture"
