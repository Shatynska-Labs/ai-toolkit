#!/usr/bin/env bash
# Scenario: New skill needs no manifest change.
# Requirement: Skills are discovered without manifest enumeration.
# Change: raise-the-plugin-version-on-release (toolkit-structure, MODIFIED).
#
# SPECIFIED: no entry in plugin.json or marketplace.json names a skill; the
# version in plugin.json, which a new skill now raises, is not such an entry.
# DERIVED (operationalisation): an entry naming a skill is a `"skills"` key, a
# path `skills/<name>`, or the string `"<name>"`, for each directory in skills/.
# DELIBERATELY UNTESTED: that the skill is discovered in the next session, which
# needs a Claude Code session; see test-plan.md.
#
# Static read (third situation); the check runs over fixtures first.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# check_manifests PLUGIN_DIR SKILLS_DIR
check_manifests() {
  local manifest d name seen=0
  for manifest in "$1/plugin.json" "$1/marketplace.json"; do
    [ -f "$manifest" ] || { echo "ABSENT: $manifest" >&2; return 2; }
    if grep -q -E '"skills"[[:space:]]*:' "$manifest"; then echo "[key] $manifest carries a skills key" >&2; return 1; fi
    for d in "$2"/*/; do
      [ -f "$d/SKILL.md" ] || continue
      seen=1
      name="$(basename "$d")"
      if grep -q -F -e "skills/$name" -e "\"$name\"" "$manifest"; then echo "[names] $manifest names the skill $name" >&2; return 1; fi
    done
  done
  [ "$seen" = 1 ] || { echo "ABSENT: no skill in $2 to look for" >&2; return 2; }
}
expect() {  # pass|TAG
  local out st=0
  out="$(check_manifests "$TESTDIR/fx" "$TESTDIR/fx/skills" 2>&1)" || st=$?
  if [ "$1" = pass ]; then [ "$st" -eq 0 ] && return 0
  else [ "$st" -eq 1 ] && case "$out" in *"[$1]"*) return 0 ;; esac
  fi
  echo "FAIL: discriminator — fixture expected $1, check returned $st: $out" >&2
  exit 1
}
mkdir -p "$TESTDIR/fx/skills/a-skill"
printf 'A skill.\n' > "$TESTDIR/fx/skills/a-skill/SKILL.md"
clean() {
  printf '{\n  "name": "ai-toolkit",\n  "version": "2.0.0",\n  "description": "skills, and a-skill in a sentence"\n}\n' > "$TESTDIR/fx/plugin.json"
  printf '{\n  "name": "ai-toolkit",\n  "plugins": [{ "name": "ai-toolkit", "source": "./" }]\n}\n' > "$TESTDIR/fx/marketplace.json"
}
clean; expect pass
printf '{\n  "name": "ai-toolkit",\n  "skills": ["./skills/a-skill"]\n}\n' > "$TESTDIR/fx/plugin.json"; expect key
clean
printf '{\n  "plugins": [{ "name": "ai-toolkit", "paths": ["./skills/a-skill"] }]\n}\n' > "$TESTDIR/fx/marketplace.json"; expect names
clean
printf '{\n  "plugins": [{ "name": "ai-toolkit", "only": ["a-skill"] }]\n}\n' > "$TESTDIR/fx/marketplace.json"; expect names

check_manifests "$TOOLKIT_ROOT/.claude-plugin" "$TOOLKIT_ROOT/skills" || exit 1
