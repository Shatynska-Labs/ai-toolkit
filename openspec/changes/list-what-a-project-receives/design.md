## Context

`scripts/project-init` writes five things into a project: `.gitignore` when absent, `openspec init`, `docs/backlog/README.md` from `scripts/seed/backlog-README.md`, `docs/workstreams/README.md` from a heredoc inside the script, and the workflow block in `AGENTS.md`, built by `build_block` from `rules/development-workflow.md` between `<!-- ai-toolkit:development-workflow v<N> -->` and `<!-- /ai-toolkit:development-workflow -->`. Only the block carries a version, read from the fragment's frontmatter. `scripts/backlog-migrate` writes the same backlog README from the same seed.

The workstream `keep-projects-on-the-current-workflow` holds what this change shares with its later steps: the two channels, the survey of adopting projects, how Claude Code loads directory instructions, and decisions 1–4 (both channels; semantic versions with a meaning per part; everything at `1.0.0`; every rule as a managed block). This design takes those as given and does not restate them.

## Goals / Non-Goals

**Goals:**
- One list, readable from a shell with nothing installed, of every block the toolkit writes into a project and where.
- Every block written carries a version and the hash of what was written, so `update-managed-block` can classify a block as current, stale or edited from the block alone.
- The backlog's and workstreams' rules load in a session that works in their directory, under Claude Code's default settings, in a project with a root `CLAUDE.md`.

**Non-Goals:**
- Replacing or converting anything a project already holds, the workflow block included; that is `update-managed-block`.
- A changelog of what each version asks; that is `record-what-each-version-asks`.
- Raising the plugin's version on later releases; that is `raise-the-plugin-version-on-release`. This change sets it once, to `1.0.0`.
- Listing `.gitignore`, `openspec init` or a `CLAUDE.md` in the manifest. The first two are written once and owned by the project or by OpenSpec; a directory `CLAUDE.md` is one fixed line, created where absent and never maintained.

## Decisions

**1. The manifest is `rules/manifest`, and names blocks only.** One record per block, in the flat YAML subset the backlog entries use, records separated by `---`, in the order the tool writes them:

```
name: development-workflow
target: AGENTS.md
---
name: backlog
target: docs/backlog/AGENTS.md
---
name: workstreams
target: docs/workstreams/AGENTS.md
```

`name` is both the marker's name and the fragment, `rules/<name>.md`, so the record holds no path that could disagree with it. The version is not in the manifest: it stays in the fragment's frontmatter, beside the text it versions, so an author editing a body raises the version in the same file. The manifest says *what* a project receives; the fragments say *at which version*. Rejected: versions in the manifest (two files to edit per body change, and the earlier reason for it, that a seed could not carry frontmatter, goes with the seeds); `target:` in each fragment's frontmatter (no one place to read what a project receives, which is what the operator asked for); `scripts/manifest` (`scripts/` holds executables and `seed/`, and what the manifest lists are `rules/` fragments).

**2. The marker carries the version and a hash of the body.**

```
<!-- ai-toolkit:backlog 1.0.0 sha256:<64 lowercase hex> -->
<!-- Generated. Do not edit inside this block — it is replaced on update.
     Project-specific conventions belong outside the markers. -->
...fragment body...
<!-- /ai-toolkit:backlog -->
```

The hash is SHA-256 over every byte between the opening marker's line and the closing marker's line, both exclusive, each line with its newline: the notice and the body as written. Computed with `sha256sum`, or `shasum -a 256` where that is the one present (macOS); where neither is present and a block is outstanding, the run is `BLOCKED` before any write. A later tool recomputes it: equal means untouched, so a version older than the fragment's is stale and safe to replace; unequal means edited. Rejected: a record file in the project (one more file, and a block copied by hand with no record update reads as edited anyway); comparing with the stated version's text (the toolkit would have to carry every past text, and an installed copy has no history). The notice's last line changes from "below the closing marker" to "outside the markers", since a directory file may carry project text above the block as well.

**3. Versions are `MAJOR.MINOR.PATCH`; every fragment that has a `version` starts at `1.0.0`.** That is the workflow fragment (from `12`), `development-workflow-database` (from `1`) and `test-plan` (from `3`), and the two new fragments. A fragment's version rises with any change to its body: a patch for wording that changes no obligation, a minor for an obligation added or changed that asks nothing of the project by hand, a major where the project must do something by hand. A frontmatter-only edit raises nothing. A legacy marker, `v<N>` with no hash, is read as older than `1.0.0`. The plugin's `.claude-plugin/plugin.json` goes from `0.2.0` to `1.0.0` in this change.

**4. The directory rules are fragments, written as blocks into the directory's `AGENTS.md`, with a `CLAUDE.md` importing it.** `scripts/seed/backlog-README.md` becomes `rules/backlog.md` and the workstreams heredoc becomes `rules/workstreams.md`, each with `kind: standing-constraint` and `version: 1.0.0`; the body is the current text with "this README" read as "this file". `scripts/seed/` is removed, and with it `AGENTS.md`'s statement of why a seed is not a fragment: a block inlines the body without the frontmatter, so the reason a seed could not be a fragment no longer holds.

For each of `docs/backlog/` and `docs/workstreams/`, the tool writes the block into `AGENTS.md` by the root's rule (appended to a file that exists, the file created otherwise), and then:

- `CLAUDE.md` absent, no path of any type — created holding exactly `@AGENTS.md`;
- `CLAUDE.md` present holding `@AGENTS.md` — nothing said;
- `CLAUDE.md` present without it — left unchanged, and the report states the line to add.

The directory's `CLAUDE.md` is created unconditionally, unlike the root's, which the tool only advises: a directory file is the toolkit's own creation in a directory the toolkit seeded, while a project's root `CLAUDE.md` is the project's. The shadowing detection is not repeated per directory, because a root `CLAUDE.md` (present in every adopting project) always shadows a subdirectory's `AGENTS.md`.

**5. A legacy README is reported, and nothing is written beside it.** Where a seeded directory, `docs/backlog/` or `docs/workstreams/` but never the project root, holds `README.md` and its `AGENTS.md` holds no block of that name, the tool writes neither file there and reports the rules as present in the shape before `1.0.0`. Writing the block beside the README would leave two copies of the rules in the directory, one of which a session might still be sent to; converting it is `update-managed-block`'s, which can tell an untouched README from an edited one only by hashing it against the texts shipped before `1.0.0`, a question for that change. The `backlog` skill reads `AGENTS.md` and falls back to `README.md` where no block exists, so a project between the two steps keeps working.

**6. `scripts/project-init` writes what the manifest lists; checks particular to a directory stay in the tool.** The manifest and every fragment it names are read and validated (`kind`, a semantic `version`) before any write; any missing or invalid one blocks the run, whether or not its concern is outstanding, since a copy missing one is not a copy the tool can vouch for. Each record is then handled in order. Three checks apply to every target except the root's `AGENTS.md`: a target, or its directory, that is a link or not of the expected type is never written through; a `README.md` with no block is reported (decision 5); and the directory's `CLAUDE.md` is handled (decision 4). The root keeps today's rules unchanged, including appending through a root `AGENTS.md` that is a link, since the project chose that file. One check is tied to one record: a backlog in the single-file shape is pointed to `scripts/backlog-migrate` (the `backlog` record). Rejected: a fully generic loop with the backlog checks expressed in the manifest — a manifest field for one record's precondition is a schema for one case.

**7. `scripts/backlog-migrate` converts entries only.** It no longer writes the rules file, and its report names `scripts/project-init` as what writes `docs/backlog/AGENTS.md`. After a conversion the directory holds entries and no block, which is the state `project-init` already handles ("beside existing entries"). One writer per block means one implementation of the marker and the hash. Rejected: a shared shell library both tools source (a new kind of file under `scripts/`, for one caller beyond `project-init` that `retire-the-backlog-converter` will remove).

**8. This repository converts its own directories by hand.** Its `docs/backlog/README.md` and `docs/workstreams/README.md` become `AGENTS.md` blocks generated by the tool and a `CLAUDE.md` each, so the repository runs the shape it ships.

## Risks / Trade-offs

- [A project between this change and `update-managed-block` sees `project-init` report its READMEs as legacy and do nothing] → The `backlog` skill falls back to the README. That `update-managed-block` converts the READMEs in the run that brings the root block to `1.0.0` is a constraint on its design, recorded as the workstream's decision 5.
- [The converse mixed state: an old root block beside a new directory block, after `backlog-migrate` and `project-init`, or where `docs/workstreams/` was absent (infrastructure-template)] → The old fragment sends sessions to a `README.md` that does not exist, but the directory's `CLAUDE.md` loads its `AGENTS.md` whenever a file there is read or written, so the rules still reach the session; `update-managed-block` then brings the root block current.
- [On a filesystem that ignores case, an entry or workstream named `agents`, `claude` or `readme` would overwrite the rules or their import] → Those names are reserved in the rules themselves, refused by `record` and by `backlog-migrate`.
- [GitHub renders a folder's `README.md` and not its `AGENTS.md`, so `docs/backlog/` loses its rendered rules] → Accepted; the rules are written for sessions, and the file is one click away.
- [A hash over text with CRLF line endings, or edited by a tool that normalises whitespace, reads as edited] → The safe direction: an edited block is reported, never overwritten.
- [The hash command differs between Linux and macOS] → Both are probed; the run blocks with a named reason where neither exists.
- [About 60 test cases name the READMEs or the seed] → Their assertions are revised only where the delta replaced the path or wording; every rule they check about the texts is unchanged.

## Migration Plan

Adopting projects need no action from this change: `project-init` leaves their READMEs and their `v12` blocks as they are and reports both. `update-managed-block` converts them. Rollback is reverting the change's commits; no project state is written except by a run of `project-init` in a new project.
