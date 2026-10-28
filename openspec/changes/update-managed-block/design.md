## Context

`list-what-a-project-receives` left everything an update needs in place: `rules/manifest` lists each block and its target; each fragment carries a semantic `version`; `scripts/project-init` writes a block as `<!-- ai-toolkit:<name> <version> sha256:<hash> -->`, the two-line notice, the fragment's body and `<!-- /ai-toolkit:<name> -->`, the hash covering every line strictly between the markers; it reads the earlier `<!-- ai-toolkit:<name> v<N> -->` too. It reports a block at another version as out of scope, and a seeded directory holding `README.md` and no block as legacy, writing nothing there.

The workstream `keep-projects-on-the-current-workflow` holds the survey of adopting projects and decisions 1–5; this design takes them as given. Decision 2 (semantic versions), 3 (a legacy `v<N>` reads as older than `1.0.0` and is brought there without reconciling by hand), 4 (an edit is a body whose hash differs from its marker's; no history of past texts in the toolkit) and 5 (a README is converted in the run that brings the root block to `1.0.0`) bind this change directly.

## Goals / Non-Goals

**Goals:**
- One command, run in a project, brings every block the manifest lists to the toolkit's current text where nobody edited it, and says which ones it left and why.
- The adopting projects leave the shapes before `1.0.0` in one run, with the conversion visible in `git diff` and undone by `git restore`.

**Non-Goals:**
- What a version asks a project to do by hand; that is `record-what-each-version-asks`, which adds those steps to this tool's report.
- Writing a block a project does not hold at all; `project-init` does that, and this tool names it.
- Converting `docs/backlog.md`; `scripts/backlog-migrate` does that, and this tool names it.
- Committing, running across several projects, or running on a schedule (the workstream's *Not in scope*).
- A skill wrapping the tool. The script is the one command; a wrapper is added if one is wanted.

## Decisions

**1. A separate executable, `scripts/project-update`, one project per run.** It takes `project-init`'s interface shape — `[--help|-h] [TARGET_DIR]`, the target stated before any change, `SUCCESS`/`ERROR`/`BLOCKED` with exit codes `0`/`1`/`2`, its resources located from its own path and never from the environment — so a caller reads both tools the same way. `project-init` keeps its contract that it never rewrites a block; an overwrite path does not arrive in it as a side effect of being re-run. Rejected: `--update` on `project-init` (one entry point, but its never-overwrite contract would then hold only without a flag); several targets per run (a loop in the caller is as short, and one target keeps the report and the outcome about one project).

**2. Each manifest record is classified from the target file alone.** In order, the first that applies:

| state | condition | action |
|---|---|---|
| `not writable` | a target, or the directory holding it, other than the root's `AGENTS.md`, is a symbolic link or not of the expected type | none |
| `single file` | the `backlog` record, `docs/backlog/` absent and `docs/backlog.md` present | none; report names `backlog-migrate` |
| `legacy README` | a directory other than the root holds `README.md`, and its `AGENTS.md` holds no opening marker of the name | converted (decision 4) |
| `absent` | the target holds no opening marker of the name | none; report names `project-init` |
| `malformed` | more than one opening marker of the name, no closing marker after it, or a hashed marker whose hash is not 64 lowercase hex digits | none |
| `legacy block` | the opening marker is `v<N>` | converted (decision 4) |
| `edited` | the SHA-256 of the lines strictly between the markers differs from the marker's | none; report with the diff (decision 5) |
| `ahead` | the marker's version is greater than the fragment's | none |
| `current` | the marker's version equals the fragment's | none |
| `stale` | the marker's version is less than the fragment's | replaced (decision 3) |

`edited` is decided before the version, so an edited block at the current version is reported as edited, not current. Versions compare numerically by `MAJOR`, then `MINOR`, then `PATCH`; a `v<N>` marker is below every semantic version. The `README.md` check is never made at the project root, whose README is the project's own documentation, as in `project-init`; and a `README.md` beside a directory's block is the project's file once the block exists, so it is neither read nor removed. These are the states `project-init` already distinguishes, with its `present` split by what the marker and hash say.

**3. A replacement is the marker lines and what lies between them, nothing else.** The tool builds the block exactly as `project-init` does — same marker, notice, body and hash — and writes the file as: every line before the opening marker, the new block, every line after the closing marker, each byte-identical to before. It writes a temporary file in the target's directory and then copies its contents over the target, so a root `AGENTS.md` that is a symbolic link is written through, as `project-init` appends through it, and the file's mode is kept. The block-building code is a copy of `project-init`'s, kept equal by a test that compares a block this tool writes with the block `project-init` writes from the same fragment. Rejected: a shared shell library sourced by both (a new kind of file under `scripts/`, which holds executables, for about forty lines whose drift a test catches); invoking `project-init` to build the block (its run does git, OpenSpec and the ignore file).

**4. Legacy shapes are converted unconditionally, but only where git holds the original.** Neither shape carries a hash, so an edit cannot be told from an older text (decision 4 of the workstream rules out carrying past texts). Decision 3 of the workstream brings them to `1.0.0` without reconciling by hand; what keeps that from losing a project's edit silently is that the original stays one `git restore` away and the conversion is one `git diff` to review. So, before writing anything, the tool requires that the target is the top level of a git working tree with at least one commit, and that every file a conversion would write or remove — the root `AGENTS.md` holding a `v<N>` block, each legacy `README.md`, and an `AGENTS.md` or `CLAUDE.md` already present in a legacy directory — is tracked and identical in the working tree and the index to `HEAD`. Where any fails, the run reports `BLOCKED`, names the file, and writes nothing, so a project's legacy items are converted together or not at all (decision 5 of the workstream). The report states, for every converted item, that it could not be checked for edits and that `git diff` shows the conversion.

- A `v<N>` block is replaced as decision 3 replaces a stale one.
- A directory's `README.md` is removed, and the block is written into the directory's `AGENTS.md` — appended to one that exists, the file created otherwise — and the directory's `CLAUDE.md` is handled as `project-init` handles it: created holding `@AGENTS.md` where no path exists there, left alone holding the import, otherwise left alone with the line to add reported.

The git requirement applies only where a legacy item exists. A run with no legacy item replaces only hashed blocks, where the hash already proves nobody edited inside the markers, and needs no git: an uncommitted edit outside the markers survives a replacement by construction.

Rejected: carrying the hashes of every text shipped before `1.0.0` (a history the workstream decided against, and the `v<N>` blocks span twelve versions of a fragment whose text differed between projects); leaving the READMEs for the operator to remove (the root block at `1.0.0` sends sessions to `AGENTS.md`, so a README left behind is a second, older copy of the rules that the `backlog` skill no longer reads); refusing to convert without a hash (strands every adopting project before `1.0.0`, which is the state the workstream exists to end).

**5. An edited block is reported with the diff it would take, and never written.** The report carries, under the block's line, `diff -u` of the lines currently between the markers against the lines the toolkit would write there, labelled `project` and `toolkit`. The operator then moves the project's own text outside the markers and runs the tool again, or restores the block. The same applies to a block edited in a run with legacy items: the run proceeds and the edited block stays. Rejected: a `--force` (an edit the hash detects is exactly the one the workstream decided never to overwrite; restoring the block by hand is one deliberate step).

**6. Outcomes.** `BLOCKED`, nothing written: an unusable target; a manifest or listed fragment missing or invalid (as for `project-init`, whether or not its record is outstanding); no `sha256sum` or `shasum`; and decision 4's git preconditions. `ERROR`: a write attempted and failed, with what was already written reported. `SUCCESS` otherwise, including where records were left `edited`, `ahead`, `malformed`, `not writable`, `absent` or `single file`; a final `Attention:` line names those records, so a caller has one line to read without parsing every record's. Every precondition is checked before the first write. A run that replaces nothing writes nothing, so running the tool twice in a row leaves the second run reporting every replaced block as `current`.

**7. Report.** One line per manifest record in manifest order, then directory-import lines, then the outcome:

```
Target: <absolute path>
<name>: current (version X)
<name>: replaced (version X → Y)
<name>: converted from version vN to Y; not checked for edits, review with git diff
<name>: converted from <dir>/README.md to <dir>/AGENTS.md (version Y), README.md removed; not checked for edits, review with git diff
<name>: edited inside the markers (version X, toolkit carries Y); not replaced
        [unified diff, each line indented]
<name>: ahead of this toolkit (version X, toolkit carries Y); not replaced
<name>: markers malformed in <target>; not replaced
<name>: <path> is not a path the tool writes into; nothing written
<name>: absent; run scripts/project-init to write it
<name>: present as the single file docs/backlog.md; convert it with scripts/backlog-migrate
directory import: <dir>/CLAUDE.md created holding @AGENTS.md
directory import: add the line @AGENTS.md to <dir>/CLAUDE.md for <dir>/AGENTS.md to load
Attention: <name>, <name>   [only where a record was left as above]
Outcome: SUCCESS | BLOCKED | ERROR
Reason: <text>   [BLOCKED or ERROR only]
```

**8. `project-init`'s two "out of scope" lines name this tool.** `already present (existing version X, tool carries version Y; reconciling this is out of scope for this tool)` becomes `…; bring it current with scripts/project-update`, and the legacy README line's `converting it is out of scope for this tool, nothing written` becomes `convert it with scripts/project-update, nothing written`. `project-init` still writes nothing in either case. It names the `project-update` beside it in its own copy, as `backlog-migrate` names its `project-init`.

## Risks / Trade-offs

- [A project edited a legacy README or `v<N>` block on purpose, and the conversion discards the edit] → Only from the working tree: the run blocks unless the file is committed and unmodified, the report says every legacy item went unchecked, and `git diff` / `git restore` recover it. Every adopting project is the operator's own (workstream decision 3).
- [Every adopting project's workstreams README differs from the last seeded text] → Decision 4 converts it anyway, which is the case the git precondition exists for; the confirm step reviews each project's diff.
- [CRLF line endings or a whitespace-normalising editor make an untouched block read as edited] → The safe direction: it is reported with its diff, never overwritten.
- [The block-building code is duplicated in two scripts] → A test fails when the two write different blocks from the same fragment.
- [A major version reaches a project and the manual step it asks is not printed] → The report shows the version jump; the steps are `record-what-each-version-asks`, the next step of the workstream.
- [An installed toolkit older than the project's blocks would downgrade them] → `ahead` is never written.

## Migration Plan

Nothing in a project changes until the tool is run there. After this change merges, the confirm step runs it in each adopting project's working tree and reviews the diff with the operator; the project commits what it wrote. Rollback is reverting the change's commits; a project that ran the tool reverts with `git restore`.
