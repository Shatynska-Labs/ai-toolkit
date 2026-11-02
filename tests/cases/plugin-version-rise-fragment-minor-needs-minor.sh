#!/usr/bin/env bash
# Scenario: A fragment's minor needs at least a plugin minor
# Requirement: The plugin's version rises with what it ships.
# Change: raise-the-plugin-version-on-release (toolkit-structure, ADDED).
#
# SPECIFIED: a fragment's minor rise with a plugin patch fails.
# DERIVED: a plugin minor and a plugin major pass; a fragment's patch owes only
# a patch, the fragment's rise being a floor and nothing more.
#
# Runs the check in tests/cases/lib/plugin-version-rise.sh over fixture
# repositories. Green at authoring: the check is written in this pass, so the
# refusals and the passes beside them are what establish it discriminates.
# shellcheck disable=SC1090,SC1091 # both paths are set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
source "$TOOLKIT_ROOT/tests/cases/lib/plugin-version-rise.sh"

# Local arrangement (test-plan.md, Missing shared arrangement: the fixture
# repository), declared here because tests/lib.sh holds no git fixture. The
# sourced file above unset GIT_DIR, GIT_WORK_TREE and GIT_INDEX_FILE.
R="$TESTDIR/repo"
OUT=""
die() { echo "FAIL: $*" >&2; exit 1; }
g() { git -C "$R" "$@" >/dev/null 2>&1 || die "git $* failed in $R"; }
commit_all() { g add -A; g commit -q --allow-empty -m change; }
set_version() { printf '{\n  "name": "ai-toolkit",\n  "version": "%s"\n}\n' "$1" > "$R/.claude-plugin/plugin.json"; }
# fragment_at FILE VERSION: a fragment carrying VERSION in its frontmatter.
fragment_at() { printf -- '---\nkind: standing-constraint\nversion: %s\n---\nThe rule of %s.\n' "$2" "$1" > "$R/rules/$1.md"; }
# fixture_at VERSION: a fresh repository, one commit with the plugin at VERSION
# and origin/main on it, a branch topic checked out. fixture: the same at 2.0.0.
fixture_at() {
  rm -rf "$R"
  mkdir -p "$R/.claude-plugin" "$R/skills/a" "$R/agents" "$R/rules" "$R/scripts" "$R/docs"
  git init -q "$R" || die "git init failed in $R"
  g config user.email t@t.com; g config user.name t; g config commit.gpgsign false
  set_version "$1"
  fragment_at a 1.2.3
  fragment_at b 1.2.3
  printf 'A skill, long enough to be seen as renamed.\n' > "$R/skills/a/SKILL.md"
  printf 'A reference of the skill.\n' > "$R/skills/a/reference.md"
  printf 'An agent, long enough to be seen as renamed.\n' > "$R/agents/a.md"
  printf 'A fragment with no frontmatter.\n' > "$R/rules/c.md"
  printf 'The rules directory.\n' > "$R/rules/README.md"
  printf '#!/usr/bin/env bash\necho a script, long enough to be seen as renamed\n' > "$R/scripts/a"
  printf 'A document.\n' > "$R/docs/a.md"
  commit_all
  g update-ref refs/remotes/origin/main HEAD
  g checkout -q -b topic
}
fixture() { fixture_at 2.0.0; }
# expect pass|TAG LABEL: runs the check over the fixture; a refusal must return
# 1 and carry [TAG]. Leaves what the check printed in OUT.
expect() {
  local st=0
  OUT="$(plugin_version_check "$R" 2>&1)" || st=$?
  if [ "$1" = pass ]; then
    [ "$st" -eq 0 ] || die "$2: expected a pass, the check returned $st: $OUT"
  else
    [ "$st" -eq 1 ] || die "$2: expected refusal [$1], the check returned $st: $OUT"
    case "$OUT" in *"[$1]"*) ;; *) die "$2: expected refusal [$1], got: $OUT" ;; esac
  fi
}

fixture
fragment_at a 1.3.0
set_version 2.0.1
commit_all
expect too-small "fragment minor, plugin patch"

for raised in 2.1.0 3.0.0; do
  fixture
  fragment_at a 1.3.0
  set_version "$raised"
  commit_all
  expect pass "fragment minor, plugin at $raised"
done

fixture
fragment_at a 1.2.4
set_version 2.0.1
commit_all
expect pass "fragment patch, plugin patch"
