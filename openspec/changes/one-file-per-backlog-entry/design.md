## Context

The backlog has been one file since `seed-the-backlog`. Its rules sit in the preamble, its entries under `## \`name\`` headings, its values in bold-labelled free text. Eight projects carry one (2026-10-25 survey):

| Project | Entries |
|---|---|
| fuperia/commerce-ops | 95 |
| fuperia/infrastructure | 69 |
| infrastructure-template | 59 |
| shatynska/infrastructure | 59 |
| shatynska/ai-toolkit | 20 |
| shatynska/basis | 12 |
| fuperia/subscribed-agent-platform | 9 |
| fuperia/subscribed-agent | 4 |

Three shapes are in use:

- **Oldest:** paragraph fields, with Depends on and no Kind.
- **Middle:** Kind, Waits on, Design with and Recorded by as paragraphs. Some projects add Must not undo.
- **Current:** a list of seven fields, `list-the-entry-fields`.

In commerce-ops, 82 of 95 entries are `normal` and none `high`. The empty value appears as `nothing`, `none`, `nothing.` and `` `none` ``.

The operator works in several parallel sessions and wants a board across projects (2026-10-25). Backlog.md (MrLesk/Backlog.md, v1.55.3, MIT) was evaluated as an off-the-shelf alternative before this design.

## Goals / Non-Goals

**Goals:**

- One file per entry, so parallel sessions stop conflicting.
- Values a program reads without guessing, so the board and any other reader can rely on them.
- One conversion, the same in every project, that loses nothing.
- Keep every rule that already holds: the name as the only identifier, status derived from the repository and never stored, deletion at archive, the skill restating no rule.

**Non-Goals:**

- The board. It is `backlog-board`, the workstream's next step.
- A checker that refuses malformed frontmatter. The workstream records it as an open question, and the board's reader is the first place it is needed.
- Migrating the other seven projects. Each takes a pull request of its own.
- Updating a managed block in place. That is `update-managed-block`.

## Decisions

### 1. A directory with a README, one file per entry, the file name as identity

`docs/backlog/README.md` carries what the preamble carried, and each entry is `docs/backlog/<name>.md`. An entry file has no heading. A heading repeating the file's name would be a second statement of the identifier, and renaming one without the other leaves them disagreeing.

The README also keeps an empty backlog in version control, which does not track an empty directory.

*Alternatives:*

- Keeping the single file with frontmatter-like blocks inside it. Rejected: it fixes the reading, not the conflicts.
- A YAML or JSON index of all entries. Rejected: it reintroduces the one shared file every session edits.

### 2. Frontmatter as a flat subset of YAML

The form is fixed:

- One `key: value` per line.
- Names, values from a stated set, and dates are bare.
- Free text is double-quoted, with `"` and `\` escaped.
- Lists are inline, `[a, b]`, and empty as `[]`.
- No nesting, no comments, no value spanning lines.

The result is valid YAML, so any YAML reader reads it: the board, Backlog.md, an editor. A shell reader parses it with `sed` and `awk` line by line, as the library's no-install rule requires.

The keys are snake_case and in a fixed order: `priority`, `parked_until`, `kind`, `waits_on`, `waits_for`, `design_with`, `workstream`, `recorded_by`, `re_checked`. A fixed order keeps one entry's diff readable against another's.

*Alternative:* adopting Backlog.md's format and tool. Rejected:

- Its IDs are a prefix and a number (`BACK-200`; the source checks the segments are digits). Here the name is the identity of the entry, its branch and its change directory.
- Its status is a stored field moved by hand. Here status is derived from the repository and never stored.
- It moves finished tasks to `completed/`. Here entries are deleted at archive.
- It has no view across repositories.

Its frontmatter fields do survive edits it does not understand, so it could still read these files as a viewer later.

### 3. `waits_on` holds names only; `waits_for` and `parked_until` hold conditions

A wait mixed into one sentence makes every reader guess which words are names. Split, `waits_on` is a set of edges a program can follow and resolve as archived or not, and `waits_for` is a condition a person or an agent checks.

An entry is **unwaited** when `waits_on` is empty and there is no `waits_for`. Pick treats a `waits_for` it cannot show to hold as a wait, as it treated any non-`nothing` Waits on before. `parked_until` is the parked condition's own key because it is what a later reading checks.

### 4. Reasons stay prose in the body

`kind`, `priority` and `recorded_by` each need a reason a person reads, not a program. The reasons go in one list after the prose: `- **Kind**: …`, `- **Priority**: …` (on `high` or parked entries only) and `- **Recorded by**: …`. Further labelled items a project adds, such as Must not undo, sit in the same list.

A long quoted reason in the frontmatter would be harder to write and to read than a sentence. It would also put escaping in front of every author.

### 5. One seed file, read by both tools

The README text moves out of `project-init`'s heredoc into `scripts/seed/backlog-README.md`. Both `project-init` and `backlog-migrate` read it relative to their own location, so a seeded backlog and a converted one carry identical rules, which a test can check byte for byte.

`project-init` blocks on its absence only where the backlog concern is outstanding. Blocking on a file the run will not use would be the refusal its existing concern rules forbid. The workstream README's heredoc is left where it is: moving it is unrelated to this change.

`scripts/` has held only executables, and `toolkit-structure` says so; the change modifies that requirement to admit `scripts/seed/`, and `AGENTS.md`'s *Three categories* states it.

*Alternative:* the seed as a `rules/` fragment. Rejected: a fragment carries `kind` frontmatter and is read as instructions to import or inline, whereas a seed is written byte for byte as a file the project then owns. Its frontmatter would have to be stripped on every write, and a third `kind` invented for text that is not a rule.

### 6. `project-init` reports a single file; it does not convert it

Where `docs/backlog.md` exists and `docs/backlog/` does not, `project-init` leaves the file unchanged and reports the shape and the converter. It never rewrites what a project owns (*Files the project already owns are never overwritten*), and a conversion is something the operator reads before committing.

### 7. The `backlog` skill supports the directory only

Faced with a single-file backlog, the skill names the converter and does nothing. Supporting both shapes would double every operation's rules for the length of a migration the converter finishes in one run.

*Entries in an older shape* narrows to entries missing a value, which the converter does produce, and to a `nothing` written by hand.

### 8. The converter's rules

- **An entry heading is a level-2 heading outside fenced code, holding one backticked name.** The seeded preamble shows an example entry inside a fence; read naively, it would become a phantom `change-name` entry, `high` by its example Priority, in every seeded project. A level-2 heading before the first entry heading is preamble; one after it that is not a name blocks. The name `readme` is refused, since it collides with `README.md` where the filesystem ignores case.
- **Code review found three inputs the first implementation misread**, none of them present in the eight real backlogs: a file with Windows line endings read as having no entry and converted to nothing under `SUCCESS`; a malformed first heading was read as preamble and left out; and a fence directly after a field, or a fence of the other marker, moved text into a value or across an entry. A carriage return is now ignored, a fence closes only on its own marker, and a backticked level-2 heading before the first entry that is not a name blocks, as one after it does.
- **Preconditions are all checked before any write.** The directory is written under a temporary name and moved into place, then the file is deleted. `docs/backlog.md` must be committed and unmodified, so the deletion is recoverable from history.
- **A field is recognised by `**Label**:` at the start of a line**, list item or paragraph alike.
- **A known name** is an entry in the same file, or an open or archived change directory with its date prefix stripped. Only known names become `waits_on`, `design_with` or `recorded_by` values. A backticked kebab-case word that is neither, such as `` `project-bootstrap` ``, is a specification's name in the commerce-ops entries and must not become an edge.
- **Nothing is dropped.** Unmapped text stays in the body under its own label, and the report names it. The operator is the judgement the tool lacks.
- **Branches are not consulted for known names.** They are local state that differs between checkouts and would make the conversion non-deterministic.

The converter is bash and awk, bash 3.2-compatible and ShellCheck-clean, like `project-init`. It is exercised by `tests/cases/` against fixtures of each shape, and in this change against this repository's own backlog.

### 9. The workflow fragment names the directory; version 11 → 12

`rules/development-workflow.md` changes only the path it names and "the file itself states" → "its README states". *The fragment's version increments when its body changes* makes it 12.

Projects carry the fragment as a managed block, and `project-init` cannot yet replace an existing block (`update-managed-block`). So each project's migration pull request edits its block by hand, and the version marker with it.

### 10. Workstream `see-the-backlog-across-projects`

Opened with this plan, as the workflow directs for a goal needing more than one change. Its steps:

1. `one-file-per-backlog-entry`
2. `backlog-board`

Open questions:

- **The board's language.** A Python script run by `uv` conflicts with `AGENTS.md`'s *using the library never requires anything installed*.
- **A frontmatter checker.** Whether one ships, and where it lives.

## Risks / Trade-offs

- **About forty test cases assert the single file.** → Each case is rewritten or replaced against the directory. `tests/coverage.md` is updated alongside, and the test author derives new cases from the deltas before apply.
- **Projects stay on the old shape until migrated, and the updated skill refuses them.** → The refusal names the converter, and migrating takes one run and one pull request. The operator chooses when each project moves.
- **A project's preamble may hold rules of its own the seeded README lacks.** → The report says the preamble was not carried over, and the deleted preamble is in the diff for the operator to compare.
- **Conditions kept as `waits_for` text still need a person to judge them.** → That is the point of the split. Names become edges, and what was always judgement is marked as judgement.
- **Hand-written frontmatter may break the flat form.** → Record writes it; a checker is an open question of the workstream.

## Migration Plan

1. Land this change: the seed, the converter, `project-init`, the fragment at version 12, the skill, and this repository's own backlog converted by the tool.
2. In each consuming project, in a pull request of its own: run `scripts/backlog-migrate`, read the report and the diff, replace the managed block's text with the version 12 fragment by hand, and commit.
3. **Rollback:** a project reverts its migration commit. In this repository, reverting the change's merge restores the single file and version 11.

## Open Questions

None that block this change. The two open questions in decision 10 belong to the workstream.
