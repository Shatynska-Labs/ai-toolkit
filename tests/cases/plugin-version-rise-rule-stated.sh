#!/usr/bin/env bash
# Scenario: The rule is stated.
# Requirement: The plugin's version rises with what it ships.
# Change: raise-the-plugin-version-on-release (toolkit-structure, ADDED).
#
# SPECIFIED: AGENTS.md states that the version rises with every shipped change
# and what each of the three sizes means: major where a project or caller must
# do something by hand, minor for a new capability or a changed obligation,
# patch otherwise.
# DERIVED (operationalisation): the rule is read from the paragraphs naming the
# plugin's version with a rise, and the list directly under each. AGENTS.md
# already gives a fragment's sizes the same words, so a read of the whole file
# would pass over that alone. The phrases are alternatives, not a set wording.
#
# Static read (third situation); the check runs over fixtures first.
# Red until task 1.1 lands (state 1: no paragraph of AGENTS.md states the rule).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# rule_lines FILE: the lowercased paragraphs stating the rule, with their lists.
rule_lines() {
  tr '[:upper:]' '[:lower:]' < "$1" | awk '
    /^- / { if (inlist || after) { print; inlist = 1; after = 0 } next }
    /^[[:space:]]*$/ { if (keep) after = 1; keep = 0; next }
    { inlist = 0; after = 0; keep = 0 }
    /plugin\.json|plugin(.s)? [`]?version/ && /(rise|rises|raise|raises)/ { print; keep = 1 }
  '
}
check_rule() {
  local block
  [ -f "$1" ] || { echo "[absent] $1 is absent" >&2; return 2; }
  block="$(rule_lines "$1")"
  [ -n "$block" ] || { echo "[absent] no paragraph states that the plugin's version rises" >&2; return 2; }
  printf '%s\n' "$block" | grep -q -E 'every|each|whenever|any ' || { echo "[every] the rule is not stated of every change" >&2; return 1; }
  printf '%s\n' "$block" | grep -q -E 'shipped|ships|skills/.*agents/.*rules/.*scripts/' || { echo "[shipped] the rule does not name what ships" >&2; return 1; }
  printf '%s\n' "$block" | grep -q -E 'major.*by hand|by hand.*major' || { echo "[major] major is not given its meaning" >&2; return 1; }
  printf '%s\n' "$block" | grep -q -E 'minor.*(capabilit|obligation)|(capabilit|obligation).*minor' || { echo "[minor] minor is not given its meaning" >&2; return 1; }
  printf '%s\n' "$block" | grep -q -E 'patch.*(otherwise|the rest|anything else|everything else|fix|wording)|(otherwise|the rest|anything else|everything else|fix|wording).*patch' || { echo "[patch] patch is not given its meaning" >&2; return 1; }
  return 0
}
expect() {  # pass|TAG FILE
  local out st=0
  out="$(check_rule "$2" 2>&1)" || st=$?
  if [ "$1" = pass ]; then [ "$st" -eq 0 ] && return 0
  else case "$out" in *"[$1]"*) return 0 ;; esac
  fi
  echo "FAIL: discriminator — fixture expected $1, check returned $st: $out" >&2
  exit 1
}
# shellcheck disable=SC2016 # the backticks are markdown, not an expansion
rule='The plugin'"'"'s version in `.claude-plugin/plugin.json` rises with every shipped change.'
sizes='A major where a project or a caller must do something by hand, a minor for a new capability or a changed obligation, a patch otherwise.'

printf '# x\n\n%s %s\n' "$rule" "$sizes" > "$TESTDIR/para.md"; expect pass "$TESTDIR/para.md"
printf '# x\n\n%s\n\n- major: by hand\n- minor: a new capability\n- patch: the rest\n' "$rule" > "$TESTDIR/list.md"; expect pass "$TESTDIR/list.md"
printf '# x\n\n%s\n' "$sizes" > "$TESTDIR/no-rule.md"; expect absent "$TESTDIR/no-rule.md"
printf '# x\n\nThe plugin'"'"'s version rises. %s\n' "$sizes" > "$TESTDIR/no-every.md"
sed -i 's/ every / /' "$TESTDIR/no-every.md"; expect every "$TESTDIR/no-every.md"
printf '# x\n\nThe plugin'"'"'s version rises with every release. %s\n' "$sizes" > "$TESTDIR/no-shipped.md"; expect shipped "$TESTDIR/no-shipped.md"
printf '# x\n\n%s A minor for a new capability, a patch otherwise.\n' "$rule" > "$TESTDIR/no-major.md"; expect major "$TESTDIR/no-major.md"
printf '# x\n\n%s A major where done by hand, a patch otherwise.\n' "$rule" > "$TESTDIR/no-minor.md"; expect minor "$TESTDIR/no-minor.md"
printf '# x\n\n%s A major where done by hand, a minor for a new capability.\n' "$rule" > "$TESTDIR/no-patch.md"; expect patch "$TESTDIR/no-patch.md"
# The sizes given only to a fragment, in a paragraph of their own: what AGENTS.md
# holds today, and what a read of the whole file would take for the rule.
printf '# x\n\n%s\n\nA fragment'"'"'s patch changes wording only, a minor changes an obligation, and a major asks something by hand.\n' "$rule" > "$TESTDIR/fragment-only.md"; expect major "$TESTDIR/fragment-only.md"

check_rule "$TOOLKIT_ROOT/AGENTS.md" || exit 1
