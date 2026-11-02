#!/usr/bin/env bash
# No delta scenario: proposal.md, "The skill triggers on follow-ups", and design.md
# decision 6.
# Change: match-backlog-entries-to-a-workstream.
#
# SPECIFIED (proposal and design, not a spec): the description gains phrases for
# recording follow-ups, comes back under the 1,024-character limit, and holds no
# angle bracket (tasks.md 2.2); a positive fixture for follow-ups joins the trigger
# fixtures.
# DERIVED (wording, design.md decision 6): the three phrases; the fixture is read
# from the section under a heading naming `trigger`.
# DERIVED (operationalisation): a character is a code point, counted by dropping
# UTF-8 continuation bytes so that no locale is needed; the value is counted with
# its `description:` key, any block marker and any outer quotes removed.
#
# Not asserted: that the phrases route to the skill. tasks.md 2.2's trigger check
# does that.
#
# Static read (third situation); the scans are discriminated by mutants and the
# length and angle-bracket check by fixtures. Red at authoring on the three phrases,
# the fixture and [too-long] (state 1 on real content); goes green as task 2.2 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md

# Local arrangement (test-plan.md, Missing shared arrangement: description_check).
# Reads the shared scan_description; a forbid scan cannot reach it, since
# scan_mutate appends a forbid specimen for @description after the frontmatter.
# description_value FILE: the description on one line.
description_value() {
  scan_description "$1" | sed '1s/^description:[[:space:]]*//' | tr '\n' ' ' \
    | sed -E 's/^[>|][-+]?[[:space:]]*//; s/[[:space:]]+/ /g; s/^ //; s/ $//; s/^"(.*)"$/\1/'
}
# description_check FILE: 0 where the value is non-empty, at most 1024 characters
# and holds no angle bracket; a failure prints [too-long], [angle] or [empty].
description_check() {
  local value length
  value="$(description_value "$1")"
  [ -n "$value" ] || { echo "[empty] no description in $1" >&2; return 1; }
  length="$(printf '%s' "$value" | LC_ALL=C tr -d '\200-\277' | wc -c)"
  [ "$length" -le 1024 ] || { echo "[too-long] the description holds $length characters" >&2; return 1; }
  case "$value" in *'<'*|*'>'*) echo "[angle] the description holds an angle bracket" >&2; return 1 ;; esac
}
# specimen_with VALUE: a skill file whose description is VALUE.
specimen_with() {
  printf -- '---\nname: backlog\ndescription: %s\n---\n\n# backlog\n' "$1" > "$TESTDIR/specimen.md"
}
expect_rejected() {  # TAG
  local out st
  out="$(description_check "$TESTDIR/specimen.md" 2>&1)"; st=$?
  [ "$st" -eq 1 ] && case "$out" in *"[$1]"*) return 0 ;; esac
  echo "FAIL: discriminator — expected [$1], status $st: $out" >&2
  exit 1
}

# 1024 code points, a third of them em dashes, passes; one more fails.
at_limit="$(printf '—ab%.0s' $(seq 1 341))c"
specimen_with "$at_limit"
out="$(description_check "$TESTDIR/specimen.md" 2>&1)" || { echo "FAIL: discriminator — rejected 1024 characters: $out" >&2; exit 1; }
specimen_with "${at_limit}d"
expect_rejected too-long
specimen_with 'Handles <name> entries.'
expect_rejected angle

scan require "$S" @description follow-ups-write 'write up these follow-ups as backlog entries'
scan require "$S" @description follow-ups-staging 'record the follow-ups found on staging'
scan require "$S" @description where-it-belongs 'where does this entry belong'
scan require "$S" trigger follow-ups-fixture 'follow-ups'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
---
name: backlog
description: Used for "write up these follow-ups as backlog entries", "record the follow-ups found on staging", "where does this entry belong".
---

# backlog

## Trigger check fixtures

- **Positive** — "Write these follow-ups up." → expected routing: `backlog`.
FIXTURE

scan_discriminate "$fixture" || exit 1
status=0
scan_check "$TOOLKIT_ROOT" || status=1
description_check "$TOOLKIT_ROOT/$S" || status=1
exit "$status"
