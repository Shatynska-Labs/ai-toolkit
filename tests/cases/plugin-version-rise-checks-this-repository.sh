#!/usr/bin/env bash
# Scenario: The suite checks this repository
# Requirement: The plugin's version rises with what it ships.
# Change: raise-the-plugin-version-on-release (toolkit-structure, ADDED).
#
# SPECIFIED: the check reads this branch's own diff and version, not only fixtures.
# DERIVED (operationalisation): the check's report names the merge base, the
# version and the count of shipped paths this case reads for itself; the same
# report over a fixture names the fixture's, so the report follows its root.
#
# Static read of this repository (third situation). The fixture first establishes
# the case can fail. Green at authoring and through this change, whose diff
# touches no shipped path: it goes red on a later branch that ships without a rise.
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
printf 'changed\n' >> "$R/scripts/a"
commit_all
expect not-raised "control: a fixture owing a rise"
fixture_base="$(git -C "$R" rev-parse origin/main)"
case "$OUT" in *"compared base=$fixture_base base_version=2.0.0 "*" version=2.0.0 shipped=1"*) ;;
  *) die "the report does not name the fixture's own base, version and diff: $OUT" ;; esac

base="$(git -C "$TOOLKIT_ROOT" merge-base HEAD refs/remotes/origin/main)" || die "no merge base of HEAD and origin/main in $TOOLKIT_ROOT"
version="$(sed -n -E 's/.*"version"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' "$TOOLKIT_ROOT/.claude-plugin/plugin.json" | head -n 1)"
[ -n "$version" ] || die "no version read from this repository's plugin.json"
shipped="$(git -C "$TOOLKIT_ROOT" diff --no-renames --name-only "$base" -- skills agents rules scripts | grep -c '' || true)"

st=0
OUT="$(plugin_version_check "$TOOLKIT_ROOT" 2>&1)" || st=$?
[ "$st" -eq 0 ] || die "this repository's branch is refused: $OUT"
case "$OUT" in
  *"compared base=$base base_version="*" version=$version shipped=$shipped"*) ;;
  *) die "the report does not name this branch's base $base, version $version and $shipped shipped path(s): $OUT" ;;
esac
