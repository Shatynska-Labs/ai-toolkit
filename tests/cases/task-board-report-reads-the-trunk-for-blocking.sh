#!/usr/bin/env bash
# Requirement: The tool reports its outcome
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: what blocks is what the trunk holds, not the working tree.
#
# Executes the tool (first situation); red until scripts/task-board exists (state 2).
# shellcheck disable=SC1090,SC2016 # $TESTLIB is set by tests/run.sh; the awk program is single-quoted on purpose
source "$TESTLIB"

# Local arrangement (test-plan.md, Missing shared arrangement). tests/lib.sh
# holds no git fixture, no gh stub and no HTML reader, and a test module
# imports from no other test module, so every task-board case carries this
# same block.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE
BOARD="$TOOLKIT_ROOT/scripts/task-board"
P="$TESTDIR/project"
ORIGIN="$TESTDIR/origin.git"
OUT="$TESTDIR/page.html"
REPORT="$TESTDIR/report"
BIN="$TESTDIR/bin"
PRS="$TESTDIR/pull-requests"
RC=0

die() { echo "FAIL: $*" >&2; exit 1; }
g() { git -C "$P" "$@" >/dev/null 2>&1 || die "git $* failed in $P"; }
identity() { g config user.email t@t.com; g config user.name t; g config commit.gpgsign false; }

# stub_gh: gh on PATH answering `pr list` from $PRS, lines of name<TAB>STATE,
# in the column order the call's --template names, cut at its --limit. Every
# other call succeeds silently. It fails outright where $TESTDIR/gh-fails exists.
stub_gh() {
  mkdir -p "$BIN" "$TESTDIR/tmp"
  : > "$PRS"
  cat > "$BIN/gh" <<STUB
#!/usr/bin/env bash
if [ -e "$TESTDIR/gh-fails" ]; then echo 'gh: not logged in' >&2; exit 1; fi
[ "\$1 \$2" = "pr list" ] || exit 0
limit=30; template=''
while [ \$# -gt 0 ]; do
  case "\$1" in
    --limit|-L) limit="\$2"; shift ;;
    --limit=*) limit="\${1#--limit=}" ;;
    --template|-t) template="\$2"; shift ;;
    --template=*) template="\${1#--template=}" ;;
  esac
  shift
done
case "\$template" in
  *.state*.headRefName*) awk -F'\t' -v OFS='\t' '{ print \$2, \$1 }' "$PRS" | head -n "\$limit" ;;
  *) head -n "\$limit" "$PRS" ;;
esac
STUB
  chmod +x "$BIN/gh"
  export PATH="$BIN:$PATH" TMPDIR="$TESTDIR/tmp"
}
# repo_only: the stub, the bare origin and an empty repository with the remote.
repo_only() {
  stub_gh
  git init -q --bare "$ORIGIN" >/dev/null 2>&1 || die "git init --bare failed"
  git -C "$ORIGIN" symbolic-ref HEAD refs/heads/main
  mkdir -p "$P"
  git init -q "$P" >/dev/null 2>&1 || die "git init failed"
  g symbolic-ref HEAD refs/heads/main
  identity
  g remote add origin "$ORIGIN"
}
# commit MESSAGE [DAYS_AGO]: everything in the tree, dated DAYS_AGO days and an hour back.
commit() {
  local when
  when="$(( $(date +%s) - ${2:-1} * 86400 - 3600 )) +0000"
  g add -A
  GIT_AUTHOR_DATE="$when" GIT_COMMITTER_DATE="$when" git -C "$P" commit -q --allow-empty -m "$1" >/dev/null 2>&1 \
    || die "git commit failed in $P"
}
# save [DAYS_AGO]: commit on main and push it.
save() { commit save "${1:-1}"; g push -q origin main; }
# project_new: a project on the directory shape with main pushed and origin/HEAD set.
project_new() {
  repo_only
  mkdir -p "$P/docs/backlog" "$P/docs/workstreams"
  echo '# rules' > "$P/docs/backlog/AGENTS.md"
  echo '# rules' > "$P/docs/workstreams/AGENTS.md"
  save 30
  g remote set-head origin main
}
# entry NAME [FRONTMATTER_LINE...]
entry() {
  local n="$1" l; shift
  { echo '---'; echo 'kind: change'; for l in "$@"; do printf '%s\n' "$l"; done; echo '---'; echo; echo 'The entry body.'; } \
    > "$P/docs/backlog/$n.md"
}
# workstream NAME [STEP...]: STEP is a name, name|description, or !line kept
# as written. $WS_SUMMARY, where set, is a **Summary** line.
workstream() {
  local n="$1" s i=0 d; shift
  {
    printf '# `%s`\n\n' "$n"
    if [ -n "${WS_SUMMARY:-}" ]; then printf -- '- **Summary**: %s\n' "$WS_SUMMARY"; fi
    printf -- '- **Goal**: the goal text.\n- **Done when**: the done text.\n- **Steps**:\n\n'
    for s in "$@"; do
      i=$((i + 1)); d='the step text.'
      case "$s" in '!'*) printf '%s. %s\n' "$i" "${s#!}"; continue ;; esac
      case "$s" in *'|'*) d="${s#*|}"; s="${s%%|*}" ;; esac
      printf '%s. `%s` — %s\n' "$i" "$s" "$d"
    done
    printf '\n- **Not in scope**: nothing.\n'
  } > "$P/docs/workstreams/$n.md"
}
# change NAME [WORKSTREAM]: an open change's proposal in the tree.
change() {
  mkdir -p "$P/openspec/changes/$1"
  { printf '## Why\n\nA reason.\n\n'
    if [ -n "${2:-}" ]; then printf '**Workstream**: `%s`, a step.\n' "$2"; else echo '**Workstream**: none'; fi
  } > "$P/openspec/changes/$1/proposal.md"
}
# tasks_file NAME TICKED TOTAL
tasks_file() {
  local i
  mkdir -p "$P/openspec/changes/$1"
  { echo '## 1. Work'; echo
    for i in $(seq 1 "$3"); do
      if [ "$i" -le "$2" ]; then echo "- [x] 1.$i done"; else echo "- [ ] 1.$i open"; fi
    done
  } > "$P/openspec/changes/$1/tasks.md"
}
archived() { mkdir -p "$P/openspec/changes/archive/2026-01-01-$1"; echo 'x' > "$P/openspec/changes/archive/2026-01-01-$1/proposal.md"; }
on_branch() { g checkout -q -b "$1"; }
# leave_branch [DAYS_AGO]: commit what is in the tree on the branch, back to main.
leave_branch() { commit work "${1:-1}"; g checkout -q main; }
# branch NAME [DAYS_AGO]: a local branch one commit ahead of main.
branch() { on_branch "$1"; leave_branch "${2:-1}"; }
pr() { printf '%s\t%s\n' "$1" "$2" >> "$PRS"; }

# board [ARG...]: runs the tool from the project; $RC, $REPORT. The target-absent
# guard: a BLOCKED case asserts a non-zero exit a missing script would satisfy.
board_in() {
  local dir="$1"; shift
  [ -f "$BOARD" ] || die "target absent — $BOARD does not exist yet"
  RC=0
  ( cd "$dir" && "$BOARD" "$@" ) > "$REPORT" 2>&1 || RC=$?
}
board() { board_in "$P" --output "$OUT"; }
board_ok() {
  board
  assert_exit 0 "$RC" "report: $(cat "$REPORT")"
  assert_file "$OUT"
  assert_contains "$REPORT" 'Outcome: SUCCESS'
}
blocked() {
  assert_exit 2 "$RC" "report: $(cat "$REPORT")"
  assert_contains "$REPORT" 'Outcome: BLOCKED'
  assert_file_absent "$OUT"
}
has() { printf '%s\n' "$1" | grep -qiF -- "$2" || die "expected [$2] in: $1"; }
hasnt() { if printf '%s\n' "$1" | grep -qiF -- "$2"; then die "unexpected [$2] in: $1"; fi; }
hasre() { printf '%s\n' "$1" | grep -qiE -- "$2" || die "expected /$2/ in: $1"; }
hasntre() { if printf '%s\n' "$1" | grep -qiE -- "$2"; then die "unexpected /$2/ in: $1"; fi; }
report() { cat "$REPORT"; }
raw() { cat "$OUT"; }


# ---- the case
project_new
rm -rf "$P/docs"
echo x > "$P/README.md"
save
mkdir -p "$P/docs/backlog"
echo 'untracked' > "$P/docs/backlog/here-only.md"
board
blocked
