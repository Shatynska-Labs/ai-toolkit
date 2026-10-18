## MODIFIED Requirements

### Requirement: Workflow rules reach a project as a versioned managed block

The project's conventions file SHALL be `AGENTS.md` at the project root. It is named here rather than left to the implementer because it is the file every targeted harness reads, and because a project may hold more than one candidate.

The tool SHALL apply the following, in order:

- `AGENTS.md` exists — the block is appended to it.
- `AGENTS.md` is absent and `CLAUDE.md` exists — `AGENTS.md` is created with the block, and `CLAUDE.md` is left untouched. The tool SHALL NOT write into `CLAUDE.md`, whose contents are the project's own and may be a single import of another file.
- Neither exists — `AGENTS.md` is created with the block.

**Writing the file is not the same as the rules taking effect, and the tool SHALL NOT conflate them.** Whether a harness loads `AGENTS.md` without an explicit import SHALL be established by observation and recorded, and established again when the harness changes it. For Claude Code it was observed on 2026-08-17 that it did not. On 2026-10-18, at version 2.1.302, it was observed to read `AGENTS.md` without an import only where no project instructions file is found for the target — no `CLAUDE.md`, `CLAUDE.local.md` or `.claude/CLAUDE.md` in the target or in any directory above it, up to the filesystem root, the user's own `~/.claude/CLAUDE.md` excepted. Any such file switched the fallback off, whether in the target, in an enclosing repository, or in a directory above that is no repository; with `@AGENTS.md` added to the target's `CLAUDE.md`, the rules loaded where the shadowing file was an enclosing directory's `CLAUDE.md` or the target's `.claude/CLAUDE.md`, the arrangements in which that was observed. Its changelog records the fallback as added in 2.1.277 and extended in 2.1.281 to Amazon Bedrock, Google Vertex AI, Microsoft Foundry, LLM gateways and sessions with telemetry disabled.

A **shadowing file** is any of `CLAUDE.md`, `CLAUDE.local.md` or `.claude/CLAUDE.md`, in the target or in any directory above it, other than `.claude/CLAUDE.md` in the user's home directory.

Where the target's `CLAUDE.md` contains the `@AGENTS.md` import, the report SHALL state nothing about the import. Otherwise, where a shadowing file exists, the report SHALL state the one line the user must add for the rules to load, naming the target's own `CLAUDE.md` as where it goes and that the file may need creating — a `CLAUDE.md` above the target would import that directory's `AGENTS.md`, not this one's — and SHALL still write nothing into any such file. This holds whichever of the ordered branches above produced `AGENTS.md`.

Where no shadowing file exists, the report SHALL NOT state that the import is needed for the rules to take effect: on a current Claude Code they take effect without it, and an instruction to do what is not needed is an untrue report. The report SHALL instead carry a note, phrased as a condition rather than an instruction and not beginning `Import needed:`, naming the version from which Claude Code reads `AGENTS.md` without a `CLAUDE.md`, the later version for the providers and sessions it reached afterwards, and that its "Project instructions" setting can turn the fallback off. A session on an older version, or with the setting changed, is then not left with inert rules unannounced.

Reporting `SUCCESS` and stamping a version while the rules are inert would be the silent divergence this workflow exists to prevent, and it would be worse than an obvious failure: the marker's whole purpose is to answer "is this workflow adopted here", and it would answer yes.

The tool SHALL write the workflow rule fragment into that file between delimiters that name the fragment and the version inlined, and SHALL include a notice inside the block stating that its contents are generated and that project-specific rules belong outside it.

Where a managed block for the same fragment is already present, the concern is satisfied and the block SHALL NOT be rewritten. The report SHALL then state both the version recorded in the existing block and the version the tool carries, and SHALL state that reconciling a difference is out of scope for this tool. Reporting a version as "inlined" when nothing was inlined would make the report untrue in the one case where version skew is visible.

Content between the delimiters SHALL be defined as generated and replaceable. Content outside them SHALL belong to the project and SHALL never be modified by this tool or any future update to it.

The delimiters SHALL be greppable and SHALL carry the version, so that a later update can locate and replace the block without parsing hand-written text, and so that a project's adopted workflow version is readable without comparing file contents.

#### Scenario: A project's adopted version is readable

- **WHEN** a reader needs to know whether a project uses this workflow and at which version
- **THEN** the delimiters in the conventions file state both, without any separate state file being consulted

#### Scenario: Project content below the block survives

- **WHEN** a project has added its own conventions beneath the managed block and the tool runs again
- **THEN** those conventions are unchanged

#### Scenario: A project with only a CLAUDE.md

- **WHEN** the tool runs where `CLAUDE.md` exists and `AGENTS.md` does not
- **THEN** `AGENTS.md` is created carrying the managed block, and `CLAUDE.md` is not read into, written to, or modified

#### Scenario: Rules written but not yet loadable are reported as such

- **WHEN** the tool writes the managed block into `AGENTS.md` where the target's `CLAUDE.md` exists and does not import `AGENTS.md`
- **THEN** the report states the import line the user must add for the rules to take effect, and does not present the rules as being in force merely because the file was written

#### Scenario: A shadowing file above the target is reported like one in it

- **WHEN** the tool writes the managed block into `AGENTS.md` in a target with no `CLAUDE.md` of its own, inside a directory that holds a `CLAUDE.md` without the import
- **THEN** the report states the import line the user must add to the target's `CLAUDE.md`, not the version note

#### Scenario: The user's own instructions file does not shadow

- **WHEN** the only shadowing candidate is `.claude/CLAUDE.md` in the user's home directory
- **THEN** the report carries the version note, not the import line

#### Scenario: No CLAUDE.md yields a version note, not an instruction

- **WHEN** the tool writes the managed block into `AGENTS.md` where no shadowing file exists
- **THEN** the report does not state that an import is needed for the rules to take effect, and states the Claude Code versions from which `AGENTS.md` is read without one

#### Scenario: An existing block at a different version is reported, not rewritten

- **WHEN** the tool runs where a managed block for the same fragment already exists at an earlier version
- **THEN** the block is left unchanged, and the report states both versions and that reconciling them is out of scope
