#!/usr/bin/env bash
# Scenario: Enumeration is not used.
# Requirement: Skills are discovered without manifest enumeration.
# Change: raise-the-plugin-version-on-release (toolkit-structure, MODIFIED; the
# scenario's text is unchanged, and no case covered it before).
#
# SPECIFIED: the marketplace entry contains no `skills` array.
# DERIVED (operationalisation): a `"skills"` key anywhere in marketplace.json,
# read with grep over the file joined to one line, there being no JSON parser
# this suite may rely on; and the file must carry a `"plugins"` entry to inspect.
#
# Static read (third situation); the check runs over fixtures first.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

check_marketplace() {
  local joined
  [ -f "$1" ] || { echo "ABSENT: $1" >&2; return 2; }
  joined="$(tr -d '\n' < "$1")"
  printf '%s\n' "$joined" | grep -q -E '"plugins"[[:space:]]*:' || { echo "[no-entry] $1 has no plugins entry" >&2; return 1; }
  if printf '%s\n' "$joined" | grep -q -E '"skills"[[:space:]]*:'; then echo "[array] $1 enumerates skills" >&2; return 1; fi
}
expect() {  # pass|TAG FILE
  local out st=0
  out="$(check_marketplace "$2" 2>&1)" || st=$?
  if [ "$1" = pass ]; then [ "$st" -eq 0 ] && return 0
  else [ "$st" -eq 1 ] && case "$out" in *"[$1]"*) return 0 ;; esac
  fi
  echo "FAIL: discriminator — fixture expected $1, check returned $st: $out" >&2
  exit 1
}
printf '{\n  "plugins": [{ "name": "x", "source": "./", "description": "the skills" }]\n}\n' > "$TESTDIR/ok.json"; expect pass "$TESTDIR/ok.json"
printf '{\n  "plugins": [{ "name": "x", "skills": ["./skills/a"] }]\n}\n' > "$TESTDIR/array.json"; expect array "$TESTDIR/array.json"
printf '{\n  "plugins": [{ "name": "x", "skills"\n    : ["./skills/a"] }]\n}\n' > "$TESTDIR/split.json"; expect array "$TESTDIR/split.json"
printf '{\n  "name": "x"\n}\n' > "$TESTDIR/empty.json"; expect no-entry "$TESTDIR/empty.json"

check_marketplace "$TOOLKIT_ROOT/.claude-plugin/marketplace.json" || exit 1
