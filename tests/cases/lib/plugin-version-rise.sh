#!/usr/bin/env bash
# The check that the plugin's version rises with what it ships.
# Not a case itself: run.sh runs tests/cases/*.sh only, so a file under
# tests/cases/lib/ is sourced, never run. Written by change-test-writer for
# raise-the-plugin-version-on-release (design decisions 2 to 4), and the only
# implementation of the check: the rule is this repository's, so it lives in
# test code rather than in scripts/. Cases source it first, before building a
# fixture, so the unset below reaches their git calls too.
#
#   plugin_version_check ROOT
#
# reads ROOT's git repository and returns 0 where the rise is sufficient and 1
# where it is not or could not be compared. It never skips: a base that cannot
# be found is a failure. On any comparison it prints one line to stdout,
#
#   compared base=<sha> base_version=<v> trunk_version=<v> version=<v> shipped=<n>
#
# so a caller can see what was read, and each refusal prints to stderr as
# [TAG] <reason>, the tags being no-trunk, unreadable, lowered, not-raised,
# trunk-took and too-small.

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE

# The full ref: a local branch or tag named origin/main would shadow the short one.
PVR_TRUNK=refs/remotes/origin/main
PVR_MANIFEST=.claude-plugin/plugin.json

# pvr_refuse TAG REASON: reports the refusal; returns 1 for the caller's return.
pvr_refuse() {
  echo "[$1] $2" >&2
  return 1
}

# pvr_version: the first `"version"` value on stdin, the read
# tests/cases/plugin-version-semantic.sh makes, no JSON parser being one this
# suite may rely on. Prints nothing where it is not MAJOR.MINOR.PATCH.
pvr_version() {
  sed -n -E 's/.*"version"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' \
    | head -n 1 \
    | grep -E '^[0-9]+[.][0-9]+[.][0-9]+$' || true
}

# pvr_frontmatter_version: the semantic `version:` in the frontmatter leading
# stdin, or nothing. A fragment with none has no rise (design decision 4).
pvr_frontmatter_version() {
  awk '
    NR == 1 { if ($0 != "---") exit; next }
    $0 == "---" { exit }
    /^version:/ { v = $0; sub(/^version:[[:space:]]*/, "", v); sub(/[[:space:]]*$/, "", v); print v; exit }
  ' | grep -E '^[0-9]+[.][0-9]+[.][0-9]+$' || true
}

# pvr_compare A B: prints -1, 0 or 1, comparing numerically part by part.
pvr_compare() {
  local a_major a_minor a_patch b_major b_minor b_patch
  IFS=. read -r a_major a_minor a_patch <<< "$1"
  IFS=. read -r b_major b_minor b_patch <<< "$2"
  local a b pair
  for pair in "$a_major $b_major" "$a_minor $b_minor" "$a_patch $b_patch"; do
    a="${pair% *}"; b="${pair#* }"
    if [ "$((10#$a))" -gt "$((10#$b))" ]; then echo 1; return 0; fi
    if [ "$((10#$a))" -lt "$((10#$b))" ]; then echo -1; return 0; fi
  done
  echo 0
}

# pvr_size FROM TO: the size of a rise, 3 major, 2 minor, 1 patch, 0 none.
pvr_size() {
  local f_major f_minor t_major t_minor
  [ "$(pvr_compare "$2" "$1")" = 1 ] || { echo 0; return 0; }
  IFS=. read -r f_major f_minor _ <<< "$1"
  IFS=. read -r t_major t_minor _ <<< "$2"
  if [ "$((10#$t_major))" -gt "$((10#$f_major))" ]; then echo 3
  elif [ "$((10#$t_major))" -eq "$((10#$f_major))" ] && [ "$((10#$t_minor))" -gt "$((10#$f_minor))" ]; then echo 2
  else echo 1
  fi
}

pvr_size_name() {
  case "$1" in 3) echo major ;; 2) echo minor ;; *) echo patch ;; esac
}

# pvr_names_something PATH: PATH is what a caller names (design decision 4).
# rules/README.md is not a fragment. Other files under the shipped directories
# change what ships and add or remove nothing a caller names.
pvr_names_something() {
  [ "$1" != rules/README.md ] || return 1
  [[ "$1" =~ ^(skills/[^/]+/SKILL\.md|agents/[^/]+\.md|rules/[^/]+\.md|scripts/[^/]+)$ ]]
}

plugin_version_check() {
  local root="$1"
  local base tip_text base_text tip_v base_v now_v
  local diff_status=0
  local status path shipped=0 required=1 before after why=""

  if ! git -C "$root" rev-parse --verify --quiet "$PVR_TRUNK^{commit}" >/dev/null 2>&1; then
    pvr_refuse no-trunk "no trunk to compare with: $PVR_TRUNK cannot be found in $root, so nothing was compared"
    return 1
  fi
  if ! base="$(git -C "$root" merge-base HEAD "$PVR_TRUNK" 2>/dev/null)" || [ -z "$base" ]; then
    pvr_refuse no-trunk "no trunk to compare with: HEAD has no merge base with $PVR_TRUNK in $root, so nothing was compared"
    return 1
  fi

  base_text="$(git -C "$root" show "$base:$PVR_MANIFEST" 2>/dev/null)" || base_text=""
  tip_text="$(git -C "$root" show "$PVR_TRUNK:$PVR_MANIFEST" 2>/dev/null)" || tip_text=""
  base_v="$(printf '%s\n' "$base_text" | pvr_version)"
  tip_v="$(printf '%s\n' "$tip_text" | pvr_version)"
  now_v=""
  [ ! -f "$root/$PVR_MANIFEST" ] || now_v="$(pvr_version < "$root/$PVR_MANIFEST")"
  [ -n "$base_v" ] || { pvr_refuse unreadable "no version in $PVR_MANIFEST at the merge base $base"; return 1; }
  [ -n "$tip_v" ] || { pvr_refuse unreadable "no version in $PVR_MANIFEST at $PVR_TRUNK"; return 1; }
  [ -n "$now_v" ] || { pvr_refuse unreadable "no version in $root/$PVR_MANIFEST"; return 1; }

  # Compared with the working tree, so an uncommitted edit counts and an
  # untracked file does not; --no-renames makes a rename a removal and an
  # addition (design decision 3).
  # -z, because git quotes a path holding a tab, a quote or a backslash, and a
  # quoted path would match no shipped directory.
  # --quiet exits 1 for a difference and above that for a failure.
  git -C "$root" diff --quiet "$base" -- >/dev/null 2>&1 || diff_status=$?
  if [ "$diff_status" -gt 1 ]; then
    pvr_refuse unreadable "git diff against the merge base $base failed in $root"
    return 1
  fi

  while IFS= read -r -d '' status && IFS= read -r -d '' path; do
    [ -n "$path" ] || continue
    case "$path" in
      skills/*|agents/*|rules/*|scripts/*) ;;
      *) continue ;;
    esac
    shipped=$((shipped + 1))
    if pvr_names_something "$path"; then
      case "$status" in
        D) required=3; why="$why $path removed;" ;;
        A) [ "$required" -ge 2 ] || required=2; why="$why $path added;" ;;
      esac
    fi
    case "$path:$status" in
      rules/README.md:*) ;;
      rules/*.md:M)
        [[ "$path" =~ ^rules/[^/]+\.md$ ]] || continue
        before="$(git -C "$root" show "$base:$path" 2>/dev/null | pvr_frontmatter_version)"
        after="$(pvr_frontmatter_version < "$root/$path")"
        if [ -n "$before" ] && [ -n "$after" ]; then
          case "$(pvr_size "$before" "$after")" in
            3) required=3; why="$why $path rose a major;" ;;
            2) [ "$required" -ge 2 ] || required=2; why="$why $path rose a minor;" ;;
          esac
        fi
        ;;
    esac
  done < <(git -C "$root" diff --no-renames --name-status -z "$base" -- 2>/dev/null)

  echo "compared base=$base base_version=$base_v trunk_version=$tip_v version=$now_v shipped=$shipped"

  if [ "$(pvr_compare "$now_v" "$base_v")" = -1 ]; then
    pvr_refuse lowered "the plugin's version $now_v is below $base_v, where the branch left the trunk"
    return 1
  fi
  [ "$shipped" -gt 0 ] || return 0
  if [ "$now_v" = "$base_v" ]; then
    pvr_refuse not-raised "the plugin's version is not raised: it stands at $now_v and the diff changes $shipped shipped path(s)"
    return 1
  fi
  if [ "$(pvr_compare "$now_v" "$tip_v")" != 1 ]; then
    pvr_refuse trunk-took "the plugin's version $now_v is not above the trunk's version $tip_v"
    return 1
  fi

  local anchor="$base_v"
  [ "$(pvr_compare "$tip_v" "$base_v")" != 1 ] || anchor="$tip_v"
  local size
  size="$(pvr_size "$anchor" "$now_v")"
  if [ "$size" -lt "$required" ]; then
    pvr_refuse too-small "the diff requires a $(pvr_size_name "$required") and $anchor to $now_v is a $(pvr_size_name "$size"):$why"
    return 1
  fi
  return 0
}
