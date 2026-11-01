## Context

`scripts/project-update` reads `rules/manifest` and every fragment before anything else, then reports one line per record. The workstream's decision 2 fixes what each part of a version means to the tool: a patch is silent, a minor prints its entry, a major lists its steps. A major always asks something by hand and a minor or patch never does. Decision 4 rules out a history of past *texts* in the toolkit; a changelog holds what versions asked, not their texts, so it does not reopen that.

Two versions above `1.0.0` exist: `development-workflow` `2.0.0` and `workstreams` `2.0.0`. A version's fragment is identified by its own name, and `development-workflow-direct` has its own version line.

## Goals / Non-Goals

**Goals:**
- A run that moves a block across a minor or major says what changed, and a major's manual steps, in the report of that run.
- An author raising a version cannot leave the record out without a test failing.

**Non-Goals:**
- Showing the steps again after the run that replaced the block.
- Printing anything for `project-init`, or for a block the run did not write.
- The plugin's own version and release notes (`raise-the-plugin-version-on-release`).
- Tracking whether a project did what a version asked.

## Decisions

**1. One file, `rules/changelog`, in the manifest's record form.** Records are `---`-separated `key: value` lines, as in `rules/manifest`, so the same awk-in-bash-3.2 reading applies:

```
name: workstreams
version: 2.0.0
changed: what the version changed, one line
ask: one thing a project does by hand, one line
ask: another
---
```

Rejected: a `CHANGELOG.md` at the root (reads as the plugin's release history, which versions differently, and markdown would have to be parsed); a changelog section in each fragment's body (it would be inlined into every project); in each fragment's frontmatter (frontmatter is flat `key: value` read by `sed`, and an edit there does not raise the version, so the record of the version would sit outside what it versions); one file per fragment (more files for one reader, and a `.md` in `rules/` must be a fragment).

**2. `1.0.0` is the floor, and has no record.** Everything started there and it asked nothing, so it would be a major with no step, against decision 2. Records exist only above `1.0.0`. A block converted from a `v<N>` or a README reads as coming from `1.0.0`, because the conversion itself is what the shapes before it needed. A fragment still at `1.0.0` needs no record.

**3. Selected by range, printed under the record's line, oldest first.** For a block written from version A to version B of one fragment, the tool takes that fragment's records with A < version ≤ B, ascending numerically, drops patches, and prints:

```
workstreams: replaced (version 1.0.0 → 2.0.0)
    2.0.0: <changed>
    2.0.0 by hand: <ask>
```

Printing beside the line, indented as a diff is, means a run that fails later has already reported what it did. A patch stays silent because decision 2 says so; it still has a record, since the file says what each version changed. Rejected: a final `By hand:` line naming records, as `Attention:` does (a second summary to keep in step; `Attention:` means a block was left, which these were not).

**4. A block crossing variants counts as held at `1.0.0` of the variant it arrives at.** Versions of `development-workflow` and `development-workflow-direct` are different number lines, so `2.0.0 → 1.0.0` is no range, but the block still arrives at a text whose steps are owed: `direct` to `full` reaches the same `2.0.0` a `v12` block does. Decision 2's floor gives the one rule for both, and the records are the arrival fragment's. Going to `direct` today prints nothing, since that fragment has no record. A later switch may repeat a step a project already did under that variant; a repeated line costs a reader one line, while a lost step cannot be recovered, since the next run reports `current`. Rejected: printing nothing (Goal 1 fails silently, and asking for a variant is not knowing its steps); one line pointing at `rules/changelog` (the operator selects the records by hand).

**5. The tool blocks on a broken file, not on a missing record.** `rules/changelog` absent or a malformed record is `BLOCKED`, read before anything else as the manifest and fragments are. A malformed record is: no kebab-case `name`, no `MAJOR.MINOR.PATCH` `version` above `1.0.0`, no `changed`, a major with no `ask`, or a minor or patch with one. Whether every version *has* a record is not the tool's check: its fixtures set versions freely, and a project should not be stopped by an omission only the library can fix. A test over `rules/` holds completeness, and for each major version `M.0.0` a run crosses with no record, a line beneath says `M.0.0: no record of what this version asks` rather than saying nothing. It is stated per major because a neighbouring record says nothing of the gap: `2.0.0` recorded and `3.0.0` not still loses `3.0.0`'s steps. A minor or patch gap stays quiet, since no manual step can be lost.

**6. The steps of `2.0.0` are written now.** The two records backfill what those versions asked, and they are the first text the tool prints. Their wording, for the operator to review at `plan:approved`:

```
name: development-workflow
version: 2.0.0
changed: `ship` gains a staging deploy on merging and a production deploy reached only by a promotion the operator triggers, followed by a smoke check, and a change is archived once it is in production.
ask: Provide a staging deploy triggered by merging, a production deploy triggered deliberately, and a smoke check; these rules cannot be followed without them.
ask: Where this project keeps one deploy by merging, run project-update --workflow direct instead.
---
name: workstreams
version: 2.0.0
changed: A step taken as a fix is done once a pull request from a branch of its name has merged, a change is a step of one workstream only, and "every step is done", beside a Done when's effect, replaces "every step is archived".
ask: Where one change is a step of two workstreams, keep it in one, and name it in `waits_on` of the backlog entry of the other's step that cannot start before it, recording that entry where there is none.
ask: Where an open workstream's Done when still says "every step is archived", change it to "every step is done", since a step taken as a fix is never archived.
```

## Risks / Trade-offs

- [The steps print once: a re-run reports `current`, and a report nobody kept is gone] → `rules/changelog` holds them for reading, and the project's own commit of the replaced block marks the moment. Printing on every run would repeat finished work forever.
- [An edited block is left, so its steps wait] → They print on the run that replaces it, once the operator restores it.
- [A record's text is one line] → Long is fine; markdown prose is one line per paragraph already. A step needing structure is two `ask:` lines.
- [A shipped omission on a minor is silent] → Held by the test before it ships.

## Migration Plan

Nothing changes in a project until the tool runs there. Every run after this change needs `rules/changelog`, which any copy of the tool carries. Rollback is reverting the change's commits.

Confirm by running the tool in a project holding a `workstreams` block below `2.0.0`, or a throwaway copy of one, and reading the printed steps.
