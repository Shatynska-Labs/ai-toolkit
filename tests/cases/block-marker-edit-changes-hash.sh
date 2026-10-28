#!/usr/bin/env bash
# Scenario: An edit inside a block changes what its hash describes.
# Requirement: A block's opening marker records its version and a hash of
# what was written. Change: list-what-a-project-receives (project-bootstrap,
# ADDED).
#
# SPECIFIED: once a line between a written block's markers is changed, the
# digest of the lines between the markers no longer equals the hash the
# opening line carries.
# DERIVED (fixture): the backlog block of a fresh run is used, its last line
# inside the markers gaining a word; the unedited block is first required to
# match, so a mismatch is the edit's and not the writer's.
#
# Executes the tool. Red until task 2.2 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

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

# Local arrangement (test-plan.md, Missing shared arrangement: sha256_of).
# sha256_of: the SHA-256 digest of stdin, in lowercase hex.
sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum | awk '{print $1}'
  else
    shasum -a 256 | awk '{print $1}'
  fi
}

work="$TESTDIR/work"
mkdir -p "$work"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"
f="$work/docs/backlog/AGENTS.md"
line="$(marker_line "$f" backlog)"
[ -n "$line" ] || { echo "FAIL: target absent — docs/backlog/AGENTS.md has no backlog marker with a hash" >&2; exit 1; }
want="$(printf '%s\n' "$line" | sed -E 's/.* sha256:([0-9a-f]{64}) -->$/\1/')"
[ "$(block_body "$f" backlog | sha256_of)" = "$want" ] || { echo "FAIL: precondition — the unedited block's digest does not match its marker" >&2; exit 1; }
closing="$(grep -n -F '<!-- /ai-toolkit:backlog -->' "$f" | head -n 1 | cut -d: -f1)"
last=$((closing - 1))
awk -v n="$last" 'NR == n { print $0 " edited"; next } { print }' "$f" > "$f.edited"
[ "$(grep -c -F '<!-- ai-toolkit:backlog ' "$f.edited")" -eq 1 ] || { echo "FAIL: the edit touched the marker" >&2; exit 1; }
if [ "$(block_body "$f.edited" backlog | sha256_of)" = "$want" ]; then
  echo "FAIL: after an edit inside the block its digest still equals the marker's hash" >&2
  exit 1
fi
