#!/usr/bin/env bash
# Scenario: A record added to the manifest is written without a change to the
# tool. Requirement: A project receives exactly the blocks the manifest lists.
# Change: list-what-a-project-receives (project-bootstrap, ADDED).
#
# SPECIFIED: a copy of the toolkit whose manifest gains a record naming a
# fragment that copy holds, targeting a path under docs/, writes that block
# into that target when its tool runs in an empty directory.
# SPECIFIED (A directory's rules block is imported by a CLAUDE.md beside it):
# the new target is an AGENTS.md other than the root's, so its directory's
# CLAUDE.md is created holding @AGENTS.md.
# DERIVED (fixture): the added fragment is rules/extra-rules.md, kind
# standing-constraint, version 1.0.0, targeting docs/extra/AGENTS.md; the
# record is appended after the existing ones with a `---` separator.
#
# Executes the tool. Red until tasks 1.2 and 2.3 land (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Local arrangement (test-plan.md, Missing shared arrangement: toolkit_copy).
# toolkit_copy DIR: rules/ and scripts/ of the toolkit under test, copied to
# DIR, so a case can alter the copy without touching the repository.
toolkit_copy() {
  mkdir -p "$1"
  cp -R "$TOOLKIT_ROOT/rules" "$1/rules" || exit 1
  cp -R "$TOOLKIT_ROOT/scripts" "$1/scripts" || exit 1
}

# Local arrangement (test-plan.md, Missing shared arrangement: block readers).
# block_body FILE NAME: the lines strictly between NAME's opening and closing
# markers, each with its newline.
block_body() {
  awk -v n="$2" '
    index($0, "<!-- /ai-toolkit:" n " -->") == 1 { exit }
    f { print }
    index($0, "<!-- ai-toolkit:" n " ") == 1 { f = 1 }
  ' "$1"
}
# marker_line FILE NAME: NAME's opening line in the form
# `<!-- ai-toolkit:NAME MAJOR.MINOR.PATCH sha256:<64 hex> -->`, or nothing.
marker_line() {
  grep -E "^<!-- ai-toolkit:$2 [0-9]+[.][0-9]+[.][0-9]+ sha256:[0-9a-f]{64} -->\$" "$1" 2>/dev/null
}

# Local arrangement (test-plan.md, Missing shared arrangement:
# holds_import). holds_import FILE: FILE holds exactly the one line @AGENTS.md.
holds_import() {
  [ -f "$1" ] && [ ! -L "$1" ] && [ "$(cat "$1")" = "@AGENTS.md" ] && [ "$(grep -c '' "$1")" -eq 1 ]
}

assert_file "$TOOLKIT_ROOT/rules/manifest" "target absent — rules/manifest"
copy="$TESTDIR/copy"
toolkit_copy "$copy"
printf -- '---\nkind: standing-constraint\nversion: 1.0.0\n---\nExtra rules body line.\n' > "$copy/rules/extra-rules.md"
m="$copy/rules/manifest"
[ -z "$(tail -c 1 "$m")" ] || printf '\n' >> "$m"
printf '%s\n' '---' 'name: extra-rules' 'target: docs/extra/AGENTS.md' >> "$m"

work="$TESTDIR/work"
mkdir -p "$work"
(cd "$work" && bash "$copy/scripts/project-init") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?" "the copy's tool runs" 
f="$work/docs/extra/AGENTS.md"
assert_file "$f" "the added record's target is written"
line="$(marker_line "$f" extra-rules)"
[ -n "$line" ] || { echo "FAIL: docs/extra/AGENTS.md has no extra-rules opening marker with a version and hash" >&2; cat "$f" >&2; exit 1; }
case "$line" in *" 1.0.0 "*) ;; *) echo "FAIL: the marker does not carry the added fragment's version: $line" >&2; exit 1 ;; esac
block_body "$f" extra-rules | grep -q -x -F 'Extra rules body line.' || { echo "FAIL: the block does not hold the added fragment's body" >&2; exit 1; }
holds_import "$work/docs/extra/CLAUDE.md" || { echo "FAIL: docs/extra/CLAUDE.md does not hold exactly @AGENTS.md" >&2; exit 1; }
