#!/usr/bin/env bash
# Scenario: The seeded file carries no numbering.
# Requirement: A backlog is seeded where none exists.
# Change: one-file-per-backlog-entry (project-bootstrap, MODIFIED).
#
# SPECIFIED: no heading in the seeded README begins with a number, and no
# sentence refers to an entry's number.
# DERIVED (operationalisation, carried from the superseded
# backlog-seeded-no-entry-numbering.sh): no heading matches
# `#+ [`*_[(]*[0-9]`; the word `number` occurs only in "line numbers", which
# the brevity statement names.
#
# Executes the tool; the two scans are checked on specimens first. Red until
# tasks 1.1 and 1.2 land (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

numbered_headings() { grep -n -E '^#+[[:space:]]*[`*_[(]*[0-9]' "$1"; }
number_mentions() { sed -E 's/[Ll]ine numbers?//g' "$1" | grep -n -i 'number'; }

spec="$TESTDIR/specimen"
mkdir -p "$spec"
printf '# Backlog\n\nKeep it short, without line numbers.\n' > "$spec/ok.md"
# shellcheck disable=SC2016 # backticks and $ are literal text in a pattern or fixture
printf '# Backlog\n\n## 1. `some-change`\n' > "$spec/heading.md"
printf '# Backlog\n\nCite an entry by name, never by its number.\n' > "$spec/mention.md"
if [ -n "$(numbered_headings "$spec/ok.md")$(number_mentions "$spec/ok.md")" ]; then
  echo "FAIL: discriminator — the scans reject a conforming README" >&2; exit 1
fi
[ -n "$(numbered_headings "$spec/heading.md")" ] || { echo "FAIL: discriminator — a numbered heading passes" >&2; exit 1; }
[ -n "$(number_mentions "$spec/mention.md")" ] || { echo "FAIL: discriminator — an entry number passes" >&2; exit 1; }

work="$TESTDIR/work"
mkdir -p "$work"
(cd "$work" && bash "$PROJECT_INIT") >/dev/null 2>&1
r="$work/docs/backlog/AGENTS.md"
assert_file "$r" "the seeded README this case reads"
hits="$(numbered_headings "$r")"
[ -z "$hits" ] || { echo "FAIL: a heading in the seeded README begins with a number:" >&2; echo "$hits" >&2; exit 1; }
hits="$(number_mentions "$r")"
[ -z "$hits" ] || { echo "FAIL: the seeded README refers to a number other than line numbers:" >&2; echo "$hits" >&2; exit 1; }
