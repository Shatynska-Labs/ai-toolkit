#!/usr/bin/env bash
# Requirement: The tool reports the board as JSON
# Change: report-the-board-as-json (task-board, ADDED).
#
# SPECIFIED: parts is drawn from step, entry, change, archived_change, branch, open_pr and merged_pr, and change is one open on the trunk or on its branch.
# DERIVED: its order is not asserted, since none is stated.
#
# Runs the tool; red until scripts/task-board accepts --json.
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"
source "${TESTLIB%/*}/task-board-lib.sh"

# ---- local arrangement (test-plan.md, Missing shared arrangement)
STDOUT="$TESTDIR/stdout"
STDERR="$TESTDIR/stderr"
# board_json [ARG...]: runs the tool from $P with its streams apart; $RC.
board_json() {
  [ -f "$BOARD" ] || die "target absent — $BOARD does not exist yet"
  RC=0
  ( cd "$P" && "$BOARD" "$@" ) > "$STDOUT" 2> "$STDERR" || RC=$?
}
# jv PATH: a value of the document as compact JSON, keys sorted, by python3 or
# else jq. PATH is dotted; key:NAME picks the list element of that name, # is a
# length, @ an object's sorted keys. A key or name that is absent is an error.
jv() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import json, sys
v = json.load(open(sys.argv[1], encoding="utf-8"))
for s in sys.argv[2].split("."):
    k, _, n = s.partition(":")
    if s == "#": v = len(v)
    elif s == "@": v = sorted(v)
    else:
        v = v[k]
        if n: v = next(t for t in v if t["name"] == n)
out = json.dumps(v, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
sys.stdout.buffer.write((out + "\n").encode("utf-8"))' "$STDOUT" "$1"
  else
    jq -cS --arg p "$1" 'reduce ($p | split("."))[] as $s (.;
      if $s == "#" then length elif $s == "@" then keys else
        ($s | split(":")) as [$k, $n]
        | (if has($k) then .[$k] else error("absent: " + $k) end)
        | if $n then (map(select(.name == $n)) | if length > 0 then .[0] else error("no name: " + $n) end) else . end
      end)' "$STDOUT"
  fi
}
require_parser() {
  command -v python3 >/dev/null 2>&1 || command -v jq >/dev/null 2>&1 \
    || die "neither python3 nor jq is present, so the document cannot be parsed"
}
# doc: runs the tool with --json, which must succeed and parse.
doc() {
  require_parser
  board_json --json
  assert_exit 0 "$RC" "stderr: $(cat "$STDERR")"
  jv schema_version > /dev/null || die "standard output is not the document: $(head -c 300 "$STDOUT")"
}
# jis PATH JSON: the value at PATH is exactly JSON.
jis() {
  local got
  got="$(jv "$1")" || die "cannot read $1"
  [ "$got" = "$2" ] || die "$1 is [$got], expected [$2]"
}

# ---- the case
project_new
workstream ws-a a-task
entry a-task
change a-task
entry an-old-one
archived an-old-one
save
branch a-task
pr a-task OPEN
pr a-task MERGED
on_branch on-a-branch
change on-a-branch
leave_branch
doc
for part in step entry change branch open_pr merged_pr; do has "$(jv tasks:a-task.parts)" "\"$part\""; done
hasnt "$(jv tasks:a-task.parts)" 'archived_change'
jis tasks:a-task.parts.# 6
has "$(jv tasks:an-old-one.parts)" '"archived_change"'
has "$(jv tasks:an-old-one.parts)" '"entry"'
jis tasks:an-old-one.parts.# 2
has "$(jv tasks:on-a-branch.parts)" '"change"'
