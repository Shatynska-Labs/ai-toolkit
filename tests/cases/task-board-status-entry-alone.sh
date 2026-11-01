#!/usr/bin/env bash
# Scenario: An entry alone
# Requirement: A task's status is derived by its name
# Change: task-board (task-board, ADDED).
#
# SPECIFIED: an entry with no change, branch or pull request is recorded.
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

# The page's reader. HTML is walked by element, so a case asserts on what
# a reader sees and where it sits, not on classes or layout. What it assumes:
#  - the section of what is in flight is the page's first <section>, or, with
#    none, all that comes before the first <details>;
#  - a workstream's group is the first <details> whose <summary> names it;
#  - a task's row is its nearest <tr>, <li>, role="row" or element of class
#    row, task, step or work, or else its nearest <details>.
# Regions: flight, rest (all but flight), all, or a workstream's name.
PG='
function word(t, n,   i, p, c, d) {
  p = 1
  while ((i = index(substr(t, p), n)) > 0) {
    i += p - 1
    c = (i > 1) ? substr(t, i - 1, 1) : " "
    d = substr(t, i + length(n), 1)
    if (c !~ /[A-Za-z0-9_-]/ && d !~ /[A-Za-z0-9_-]/) return 1
    p = i + 1
  }
  return 0
}
function within(x, e) { while (x) { if (x == e) return 1; x = up[x] } return 0 }
function addtext(t) {
  gsub(/[ \t\r\n]+/, " ", t); sub(/^ /, "", t); sub(/ $/, "", t)
  if (t == "") return
  T++; tx[T] = t; te[T] = stack[sp]
}
function opentag(tag,   nm, at, sc) {
  sc = (tag ~ /\/$/); sub(/\/$/, "", tag)
  nm = tag; sub(/[ \t\r\n].*/, "", nm); nm = tolower(nm)
  at = substr(tag, length(nm) + 1)
  E++; en[E] = nm; ea[E] = at; up[E] = stack[sp]; lastnm = nm
  if (nm == "details" && !dt) dt = T + 1
  if (nm == "section" && !sect) sect = E
  if (!sc && !(nm ~ /^(area|base|br|col|embed|hr|img|input|link|meta|source|track|wbr)$/)) stack[++sp] = E
}
function closetag(nm,   i) {
  nm = tolower(nm); gsub(/[ \t\r\n]/, "", nm)
  for (i = sp; i > 0; i--) if (en[stack[i]] == nm) { sp = i - 1; return }
}
function attr(e, k,   s, i) {
  s = ea[e]; i = index(s, k "=\"")
  if (!i) return ""
  s = substr(s, i + length(k) + 2)
  return substr(s, 1, index(s, "\"") - 1)
}
function isrow(e,   c) {
  if (en[e] == "tr" || en[e] == "li" || attr(e, "role") == "row") return 1
  c = " " attr(e, "class") " "
  return (c ~ / (row|task|step|work) /)
}
function rowof(x,   d) {
  d = 0
  while (x) {
    if (isrow(x)) return x
    if (!d && en[x] == "details") d = x
    x = up[x]
  }
  return d
}
function textof(e,   t, o, s) {
  o = ""; s = ""
  for (t = 1; t <= T; t++) if (within(te[t], e)) { o = o s tx[t]; s = "\n" }
  return o
}
function summaryof(d,   e) {
  for (e = d + 1; e <= E; e++) if (up[e] == d && en[e] == "summary") return e
  return 0
}
function findgroup(n,   e, s) {
  for (e = 1; e <= E; e++) if (en[e] == "details" && (s = summaryof(e)) && word(textof(s), n)) return e
  return 0
}
function inregion(t, r) {
  if (r == "all") return 1
  if (r == "flight") return fl[t]
  if (r == "rest" || r == "") return !fl[t]
  return gr ? within(te[t], gr) : 0
}
function firstword(n, r,   t) {
  for (t = 1; t <= T; t++) if (inregion(t, r) && word(tx[t], n)) return t
  return 0
}
function emit(r,   t) { for (t = 1; t <= T; t++) if (inregion(t, r)) print tx[t] }
BEGIN { RS = "\001"; E = 0; T = 0; sp = 0; stack[0] = 0; up[0] = 0 }
{ s = s $0 }
END {
  while (length(s)) {
    i = index(s, "<")
    if (!i) { addtext(s); break }
    if (i > 1) addtext(substr(s, 1, i - 1))
    s = substr(s, i)
    if (substr(s, 1, 4) == "<!--") { j = index(s, "-->"); s = j ? substr(s, j + 3) : ""; continue }
    j = index(s, ">"); if (!j) break
    tag = substr(s, 2, j - 2); s = substr(s, j + 1)
    if (substr(tag, 1, 1) == "!") continue
    if (substr(tag, 1, 1) == "/") { closetag(substr(tag, 2)); continue }
    opentag(tag)
    if (lastnm == "style" || lastnm == "script" || lastnm == "title") {
      j = index(tolower(s), "</" lastnm); s = j ? substr(s, j) : ""
    }
  }
  for (t = 1; t <= T; t++) fl[t] = sect ? within(te[t], sect) : ((!dt || t < dt) ? 1 : 0)
  if (b != "" && b != "flight" && b != "rest" && b != "all") gr = findgroup(b)
  if (mode == "text") emit("all")
  else if (mode == "flight") emit("flight")
  else if (mode == "rest") emit("rest")
  else if (mode == "group") { d = findgroup(a); if (d) print textof(d) }
  else if (mode == "gsum") { d = findgroup(a); if (d) print textof(summaryof(d)) }
  else if (mode == "count") { n = 0; for (t = 1; t <= T; t++) if (inregion(t, b) && word(tx[t], a)) n++; print n }
  else if (mode == "pos") print firstword(a, b)
  else if ((t = firstword(a, b)) == 0) { }
  else if (mode == "row") print textof(rowof(te[t]))
  else if (mode == "summary") {
    x = te[t]; while (x && en[x] != "summary") x = up[x]
    if (x) print textof(x)
  }
  else if (mode == "near") {
    x = te[t]; while (x && en[x] != "details") x = up[x]
    if (!x) print "none"; else print ((ea[x] ~ /(^|[ \t])open([ \t=]|$)/) ? "open" : "closed")
  }
  else if (mode == "cells") {
    r = rowof(te[t]); if (en[r] == "details") r = summaryof(r)
    n = 0; for (e = 1; e <= E; e++) if (up[e] == r) n++
    print n
  }
  else if (mode == "outer" || mode == "otext") {
    o = 0; x = te[t]; while (x) { if (en[x] == "details") o = x; x = up[x] }
    if (!o) print "none"
    else if (mode == "otext") print textof(o)
    else {
      st = (ea[o] ~ /(^|[ \t])open([ \t=]|$)/) ? "open" : "closed"
      l = textof(summaryof(o)); gsub(/\n/, " ", l); print o, st, l
    }
  }
  else if (mode == "link") {
    r = rowof(te[t])
    for (e = 1; e <= E; e++) if (en[e] == "a" && within(e, r)) print attr(e, "href")
  }
  if (mode == "target") {
    for (e = 1; e <= E; e++) if (attr(e, "id") == a) {
      x = e; while (x && en[x] != "details") x = up[x]
      if (x) print textof(summaryof(x)); else print textof(e)
      break
    }
  }
}'
pg() { awk -v mode="$1" -v a="${2:-}" -v b="${3:-}" "$PG" "$OUT"; }
flight() { pg flight; }
group() { pg group "$1"; }
row() { pg row "$1" "${2:-rest}"; }
count() { pg count "$1" "${2:-rest}"; }
pos() { pg pos "$1" "${2:-rest}"; }
# status_is NAME REGION WORD: the row shows WORD and no other status.
status_is() {
  local r w; r="$(row "$1" "$2")"
  [ -n "$r" ] || die "no row for $1 in $2"
  for w in 'done' 'in flight' recorded planned; do
    if printf '%s\n' "$r" | grep -qiw -- "$w"; then
      [ "$w" = "$3" ] || die "$1 shows status [$w], expected [$3]: $r"
    elif [ "$w" = "$3" ]; then die "$1 does not show status [$3]: $r"; fi
  done
}
# in_order A B...: each name comes before the next, in the region $REGION.
in_order() {
  local prev=0 n p
  for n in "$@"; do
    p="$(pos "$n" "${REGION:-rest}")"
    [ "${p:-0}" -gt "$prev" ] || die "$n is out of order in ${REGION:-rest} (position ${p:-0}, after $prev)"
    prev="$p"
  done
}
one() { [ "$(count "$1" "$2")" = "$3" ] || die "$1 appears $(count "$1" "$2") times in $2, expected $3"; }
in_loose_group() {
  local o; o="$(pg outer "$1" rest)"
  [ -n "$o" ] && [ "$o" != none ] || die "$1 is in no collapsed group: [$o]"
  case "$o" in *' closed '*) ;; *) die "$1's group is not collapsed: $o" ;; esac
}

# ---- the case
project_new
workstream ws-a a-task
entry a-task
save
board_ok
status_is a-task ws-a recorded
