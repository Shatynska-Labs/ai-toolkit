# project-bootstrap Specification

## Purpose

Defines what initializing a project into this development workflow must do and where it stops: a standalone tool that performs only deterministic setup, resolves the toolkit it belongs to without depending on any single agent harness, reports an outcome a machine can act on, refuses to overwrite what a project already owns, and hands the next step to a human rather than taking it.

Requirements below say "repository" and "specification tooling" where the behavior does not depend on which tool provides them; the concrete instances this change implements against are **Git** (`git init`) and **OpenSpec** (`openspec init`). The generic phrasing marks which requirements would survive substituting a different tool, not a refusal to name the ones in use.

## Requirements

### Requirement: Bootstrap is a standalone executable, not an agent's implementation detail

The deterministic half of initialization SHALL be a shell script at `scripts/project-init`, runnable by a human, a shell, a CI job, or any agent in any harness, without requiring a skill, plugin, or model to be present.

The script SHALL document its modes, arguments, flags, outcomes, and exit codes in its own `--help` output. `--help` is the tool's portable interface: a `SKILL.md` is readable only by a harness that implements skills, whereas `--help` is readable by anything that can run a shell.

The tool SHALL operate on the current working directory, and SHALL accept an optional path argument naming a different target. It SHALL state the target directory in its report before making any change, so that a run against the wrong tree is visible rather than discovered afterwards. The never-overwrite guarantee protects a project's files; it does not protect against initializing the right files in the wrong place, which only the stated target can.

A target that does not exist, is not a directory, or is not writable SHALL be a precondition failure producing `BLOCKED`, not a directory the tool creates.

The script SHALL document its arguments alongside its flags in `--help`. An argument that decides where the tool writes, omitted from the interface a wrapper is written against, would defeat the purpose of that interface being self-sufficient.

A skill MAY wrap the tool, but SHALL NOT be the only way to reach it, and SHALL NOT reimplement what it does.

#### Scenario: A non-skill-aware tool can use it

- **WHEN** an agent or developer with no skills primitive works in a repository and needs to initialize it
- **THEN** `scripts/project-init --help` states what the tool does and how to run it, and running it requires nothing that only a skills-aware harness provides

#### Scenario: An explicit target is acted on and stated

- **WHEN** the tool is given a path argument naming a directory other than the current one
- **THEN** it initializes that directory, and its report states which directory it acted on before any change was made

#### Scenario: An unusable target blocks

- **WHEN** the target path does not exist, is not a directory, or is not writable
- **THEN** the tool reports `BLOCKED`, creates nothing, and exits non-zero

#### Scenario: The entry point is not buried inside a skill

- **WHEN** the library's layout is inspected
- **THEN** the executable resides at `scripts/project-init` rather than under `skills/`, because a path under `skills/` is unreachable by a harness that never loads a `SKILL.md` and reads as inapplicable to one that does not implement skills

### Requirement: A caller locating the tool resolves the toolkit root by an ordered chain

This requirement governs a **caller** — a skill, agent, or wrapper that must find the script before running it. A person who types the script's path has already resolved it and is subject to none of this.

A caller SHALL locate the toolkit by trying, in order:

1. `$AI_TOOLKIT_ROOT` — explicit and portable across any harness
2. `$CLAUDE_PLUGIN_ROOT` — zero-setup when running as an installed Claude Code plugin
3. the machine-local default path at which this repository is conventionally checked out

No single entry SHALL be required. Claude Code appears as one option, never as a precondition.

Where no entry resolves, the caller SHALL report itself blocked, invoke nothing, and stop.

The caller SHALL invoke the script through its interpreter (`bash <root>/scripts/project-init`) rather than as an executable path, so that the executable permission bit surviving distribution is not a precondition for running it.

#### Scenario: No Claude Code environment is present

- **WHEN** a caller runs from a plain shell with `$CLAUDE_PLUGIN_ROOT` unset and `$AI_TOOLKIT_ROOT` set
- **THEN** the toolkit root resolves from `$AI_TOOLKIT_ROOT` and the script is invoked from there

#### Scenario: A caller cannot resolve any root

- **WHEN** no entry in the chain yields a toolkit root
- **THEN** the caller reports itself blocked naming what it looked for, invokes nothing, and no filesystem change is made

#### Scenario: The executable bit is not relied upon

- **WHEN** distribution strips the executable permission from the script
- **THEN** the tool still runs, because it is invoked through `bash` rather than executed directly

### Requirement: The running script locates its own resources

Once running, the script SHALL derive its own directory from its invocation path and SHALL locate the rule fragments it reads relative to that. It SHALL NOT consult `$AI_TOOLKIT_ROOT`, `$CLAUDE_PLUGIN_ROOT`, or any other environment variable to find them.

Resolution therefore happens exactly once, in the caller. A script that re-resolved could read fragments from a different copy than the one it was invoked from, making the version it stamps into a project's marker untrue of the text it inlined.

#### Scenario: Fragments come from the copy the script belongs to

- **WHEN** the script runs from an installed copy while an environment variable names a different toolkit root
- **THEN** it reads the fragments belonging to the copy it was invoked from, and the version it stamps describes the text it actually inlined

#### Scenario: Explicit root reaches the working tree through the caller

- **WHEN** `$AI_TOOLKIT_ROOT` names a working tree while an older version is also installed as a plugin
- **THEN** the caller resolves to the working tree and invokes the script there, so a toolkit developer exercises the fragments they are editing rather than a pinned installed copy

### Requirement: Every run ends in one of three outcomes, and the exit code agrees

Each run SHALL terminate in exactly one of:

- `SUCCESS` — every applicable concern was completed or was already satisfied. Exit code SHALL be zero.
- `BLOCKED` — a precondition was unmet and no filesystem change was attempted. Exit code SHALL be non-zero.
- `ERROR` — a step was attempted and failed. Exit code SHALL be non-zero and distinct from the code used for `BLOCKED`.

The outcome SHALL be stated in the report, and the exit code SHALL never contradict it. A run that reports `BLOCKED` and exits zero is a defect, because shell and CI callers act on the exit code rather than the text.

Unmet preconditions that SHALL produce `BLOCKED` include: a required rule fragment absent from the script's own copy, and a required external command (`git`, or the specification tooling the script drives) unavailable.

**The rule fragment is read unconditionally, before anything else, and its absence always blocks.** It is not scoped to whether the conventions-file concern is outstanding, because the report requirement below (*Workflow rules reach a project as a versioned managed block*) obliges the tool to state its own carried version even when a managed block already exists and nothing will be written — a case where the concern is satisfied but the fragment must still be read to produce that report. Treating the fragment as scoped like a command precondition would leave that report field unproducible in exactly the case it exists to cover.

**External-command preconditions SHALL be computed from the concerns that are actually outstanding, and SHALL be validated in full before any write.** Determining which concerns are outstanding is a set of filesystem reads, not attempts, so it precedes validation without violating the no-change guarantee.

Scoping commands this way is required, not merely economical: validating every command precondition unconditionally would make the tool report `BLOCKED` when a command is missing for a concern that is already satisfied — refusing to run because some concerns are complete, which a separate requirement forbids. Validating lazily instead, at each concern's point of use, would report `BLOCKED` after earlier concerns had already written, making the outcome's own definition false. Only the scoped-then-eager order satisfies both, and it is why the fragment — read once, up front, for reasons unrelated to any single concern's completion — is carved out of it rather than folded in.

Root resolution is not among the preconditions. A script that is running was found, so an unresolvable root is a condition its caller reports before invoking anything.

#### Scenario: A machine consumer can branch on the result

- **WHEN** a CI job runs the tool and checks its exit status
- **THEN** a zero status means initialization succeeded, and any non-zero status means it did not, without the caller parsing report text

#### Scenario: A command missing for an already-satisfied concern does not block

- **WHEN** the tool runs where specification tooling is already present but the command that would initialize it is unavailable
- **THEN** that command is not among the preconditions validated, the run proceeds with the remaining concerns, and the satisfied concern is reported as already present

#### Scenario: The fragment is read even when nothing will be written

- **WHEN** the tool runs where a managed block is already present and the fragment is absent from the script's own copy
- **THEN** the tool reports `BLOCKED`, because the version it would need to report as "the version the tool carries" cannot be produced without reading the fragment, regardless of the conventions-file concern being satisfied

#### Scenario: Missing fragment blocks rather than degrades

- **WHEN** the toolkit root resolves but the workflow rule fragment is absent from it
- **THEN** the tool reports `BLOCKED` and exits non-zero, rather than writing a conventions file without the workflow rules

### Requirement: Neither the caller nor the script substitutes an improvised equivalent

A caller that cannot locate the script SHALL report itself blocked and stop. A script that cannot locate its own resources SHALL report `BLOCKED` and stop, and its caller SHALL relay that outcome rather than reinterpreting it. Neither SHALL fall back to performing the underlying operations itself — running `git init` and `openspec init` directly, or writing the workflow rules from memory.

An improvised fallback produces a project initialized differently from every other one (no managed block, no marker, no version stamp) while reporting success, which is the silent divergence this workflow exists to prevent.

#### Scenario: A wrapper cannot find the tool

- **WHEN** a skill or agent wrapping the tool cannot resolve a toolkit root
- **THEN** it reports itself blocked and stops, and does not initialize the project by running the underlying commands itself

### Requirement: Bootstrap distinguishes a new project from an adoption

The repository concern SHALL be evaluated as "the target directory is itself the root of a repository", not as "the target lies somewhere inside one". A fresh subdirectory of an existing repository is a new project, and treating the enclosing repository as satisfying the concern would report it initialized and route it to the adoption ending.

The tool SHALL determine its mode from the target directory rather than from a flag the caller must remember, and SHALL split on a single observable — whether the repository rooted at the target has at least one commit:

- **New project** — no commit exists, whether or not a repository has been initialized. The run ends by naming foundation discovery as the next step.
- **Adoption** — at least one commit exists. The run ends at the managed workflow block.

A single observable is required because plausible states sit between the intuitive descriptions: a directory where `git init` has been run but nothing committed is neither "no repository" nor "a repository with existing code", and a rule phrased on those terms would leave it unclassified.

Adoption SHALL NOT create a foundation change. An existing repository's architecture, stack, and testing approach are already embodied in its code, so a discovery phase for them would re-derive decisions that are no longer open. The adoption report SHALL nonetheless name foundation discovery as available, so recording those decisions retroactively remains a discoverable option rather than an undocumented one.

#### Scenario: Empty directory takes the new-project path

- **WHEN** the tool runs in a directory where no commit exists, whether or not a repository has been initialized
- **THEN** it initializes every unsatisfied concern and its report names foundation discovery as the next step

#### Scenario: Existing repository takes the adoption path

- **WHEN** the tool runs where the target is the root of a repository with at least one commit
- **THEN** it completes only the concerns that are unsatisfied, does not create a foundation change, and its report states that foundation discovery is available if the project's decisions should be recorded retroactively

#### Scenario: A subdirectory of an existing repository is not treated as already initialized

- **WHEN** the tool runs in a directory that has no repository of its own but sits inside one that does
- **THEN** the repository concern is reported unsatisfied, a repository is initialized rooted at the target rather than reusing the enclosing one, and mode is derived from the new repository's own commit history rather than the enclosing repository's

### Requirement: Each concern is checked independently and is safe to repeat

The tool SHALL evaluate each concern on its own — repository initialized, specification tooling initialized, ignore file present, backlog present, conventions file present, managed block present — completing what is absent and skipping what is satisfied.

The tool SHALL NOT refuse to run because some concerns are already satisfied. Repeated execution SHALL be safe: a second run against an unchanged directory SHALL make no destructive change and SHALL alter no file the first run already brought to its target state.

#### Scenario: Repeated execution is not destructive

- **WHEN** the tool is run twice in succession against the same directory
- **THEN** the second run completes reporting every concern as already satisfied, and no file written by the first run is modified, truncated, or duplicated

#### Scenario: A partially initialized directory is completed, not refused

- **WHEN** the tool runs where a repository exists but specification tooling does not
- **THEN** it skips repository initialization, completes specification tooling, and reports each concern's outcome separately

#### Scenario: Existing specification tooling is skipped, not reinitialized

- **WHEN** the tool runs where both a repository and specification tooling are already present
- **THEN** both are reported as already satisfied, neither is reinitialized, and no file either of them owns is modified

### Requirement: A partial run is recoverable by re-running

Where a run fails partway, the tool SHALL NOT attempt to roll back completed steps. It SHALL report which concerns were completed before the failure and which were not.

Re-running SHALL be the documented recovery path, which is sound only because each concern is checked independently: a second run completes what the first did not reach.

#### Scenario: Failure midway leaves a reported, recoverable state

- **WHEN** repository initialization succeeds and specification tooling initialization then fails
- **THEN** the tool reports `ERROR`, states that the repository was initialized and specification tooling was not, exits non-zero, and leaves the completed step in place

### Requirement: Files the project already owns are never overwritten

The tool SHALL create what is absent and report what is present. It SHALL NOT itself modify, merge into, extend, or truncate a file it did not create, with exactly one exception: appending the managed block to the conventions file.

A script cannot distinguish a deliberate project decision from an oversight, so editing a file it did not write risks discarding an intentional choice with no way to detect it.

**The guarantee is bounded to the tool's own writes.** The tool delegates specification-tooling initialization to an external command, whose writes it does not control and SHALL NOT claim to prevent. What that command creates or modifies SHALL be established before implementation and recorded, and the report SHALL attribute those changes to it rather than presenting the run as having touched only the files the tool wrote itself.

An unbounded guarantee would be false on the adoption path — the path this tool exists to serve — precisely where a project has files worth protecting.

#### Scenario: A delegated command's writes are attributed, not concealed

- **WHEN** the tool initializes specification tooling in a project that already has files, and that command writes files of its own
- **THEN** the report attributes those changes to the delegated command, and the tool's own never-overwrite guarantee is stated as covering the files it writes itself

#### Scenario: An existing ignore file is preserved exactly

- **WHEN** the target directory already contains an ignore file
- **THEN** its contents are left byte-for-byte unchanged, its presence is reported, and no entry is appended or merged

#### Scenario: An existing conventions file receives only the managed block

- **WHEN** the target directory already contains a conventions file with project content
- **THEN** the managed block is added and every line outside the block is left unchanged

### Requirement: The minimal ignore file is enumerated, not described

Where no ignore file exists, the tool SHALL create one containing exactly these entries and no others:

```
# Environment
.env
.env.*
!.env.example

# OS
.DS_Store
Thumbs.db

# Editors
.idea/
.vscode/
```

The entries are enumerated here, in the specification, rather than characterized as "minimal" or "generic". An adjective invites growth that each addition can justify individually; an enumeration does not. They are enumerated *here* rather than in a design document because a design document is archived with its change, while this requirement outlives it — a durable constraint that pointed at a transient file could not be checked later.

The tool SHALL NOT include stack-specific entries. It cannot know the project's language, and a wrong entry asserts something false about the project. Stack-specific exclusions belong to foundation discovery as a deliverable.

#### Scenario: Created ignore file carries no stack assumption

- **WHEN** an ignore file is created in a directory whose language is not yet decided
- **THEN** it contains only the three enumerated categories, and no entry naming a language's dependency directory, build output, or cache

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

### Requirement: The workflow rules name a role before naming a tool

The workflow rule fragment SHALL state each obligation as a role to be filled, and MAY name a specific agent or command beneath it as one harness's binding for that role.

A rule that names only a tool becomes a dangling reference in any project where that tool is absent, which makes a single harness a hard dependency of the methodology rather than its first adapter.

A binding MAY additionally name a tool that SHALL NOT fill the role it sits beneath, where a plausible wrong candidate exists. Naming only the correct tool leaves the wrong one available to anything reading the role description alone, and a role whose description matches a tool the project ships is filled by that tool whether or not it is the intended one. Where a negative binding is stated, it SHALL say why the excluded tool does not fill the role, so that a reader can tell an exclusion from an arbitrary preference.

Both the positive and the negative form are bindings, and neither SHALL appear in the role sentence: a role stated in terms of one harness's tool names is not portable, which is what this requirement exists to prevent.

#### Scenario: Rules remain meaningful without the toolkit installed

- **WHEN** a project's conventions file carries the managed block but the library is not installed in that project
- **THEN** each rule still states what must happen and why, and the named agents read as one harness's bindings rather than as required references

#### Scenario: A plausible wrong tool is excluded by name

- **WHEN** the fragment states a role whose description also matches a tool the library ships for a different role
- **THEN** the binding beneath that role names the excluded tool and states why it does not fill the role, and the role sentence above it names no tool at all

#### Scenario: An excluded tool's own contract is what the exclusion rests on

- **WHEN** a reader checks a negative binding against the excluded tool
- **THEN** the reason stated is one the excluded tool's own description supports, rather than a preference asserted only by the fragment

### Requirement: Specification tooling targets are not hardcoded to one harness

Where the tool initializes specification tooling that supports multiple agent targets, the target SHALL be caller-controlled through a flag with a documented default, and SHALL NOT be fixed to a single harness in the script.

Hardcoding one harness would make every initialized project shaped for that harness regardless of what its developer uses, contradicting the portability the tool otherwise establishes.

#### Scenario: A non-default harness is selected

- **WHEN** a developer initializes a project for a harness other than the default
- **THEN** the flag selects it, and the generated specification tooling targets that harness

### Requirement: The report enumerates outcomes and names the next step without taking it

The report SHALL state, at minimum: the target directory; each concern with its outcome; the terminal outcome; and the next step. It SHALL additionally carry the obligations other requirements place on it — the workflow version where a block was inlined, both versions where a block was already present, any import line still needed for the rules to load, and attribution of files written by a delegated command.

This enumeration is a minimum rather than a closed list, so that an obligation stated in the requirement that creates it is not silently dropped by a requirement that enumerates elsewhere.

The tool SHALL NOT take the next step. Where a wrapper offers to create an initial commit, it SHALL wait for confirmation rather than committing, and SHALL NOT begin foundation discovery automatically — starting an open-ended discovery conversation decides that this is the right moment for it, which belongs to the person running the tool.

"Successful initialization" SHALL be defined as this enumerated report rather than as a claim, so that a reader can verify it.

#### Scenario: Completion is verifiable rather than asserted

- **WHEN** a run finishes
- **THEN** the report names each concern and whether it was created, skipped as already present, or failed, together with the workflow version inlined

#### Scenario: Nothing is committed without confirmation

- **WHEN** a wrapper offers to create an initial commit after a successful run
- **THEN** no commit exists until the user confirms

#### Scenario: Discovery is named, not started

- **WHEN** a new-project run completes successfully
- **THEN** the report names foundation discovery as the next step and the run ends, rather than continuing into it

### Requirement: The tool is portable across the shells its users run

The script SHALL declare `bash` via `#!/usr/bin/env bash` and SHALL NOT use constructs unavailable in bash 3.2, so that behavior is identical on macOS, Linux, and Git Bash on Windows.

The script SHALL pass ShellCheck cleanly, which the library's existing shell standard already establishes as necessary but not sufficient for completion.

#### Scenario: Behavior is identical on a system shipping an older bash

- **WHEN** the tool runs on a system whose default bash is 3.2
- **THEN** it behaves identically to a run on a newer bash, because no construct introduced after 3.2 is used

### Requirement: The workflow rules state an ordered sequence whose gates have checkable preconditions

The workflow rule fragment SHALL state the order in which its obligations are discharged, not only the set of obligations. Where one obligation must precede another, the fragment SHALL say so.

For each gate in that order, the fragment SHALL name what must be observably present before the gate is passed — an artifact that exists, a verdict that was returned, a commit that was made — rather than describing the gate only as a stage that has been reached.

A rule stating that a step comes "after" another, without naming an observable that distinguishes done from not-done, is one an agent satisfies by asserting the earlier step happened. An unordered set of obligations is weaker still: every rule can be individually satisfied while the work runs in an order that defeats all of them, and nothing is violated. Both failures are silent, which is why the ordering and its observables are specified here rather than left to the fragment's author.

Where a precondition for a gate is absent, the fragment SHALL direct that the missing step be taken before the gate, rather than that the gate be passed with the gap noted.

A precondition MAY be waived by an exemption stated in advance — in this specification, in another specification it names, or in the project's own rules — identifying the class of change exempted and the reason. The fragment SHALL distinguish such an exemption from a gap found at the gate, and SHALL require the reason to be stated when the exemption is used. The two are not the same act: an exemption stated in advance is a decision recorded where the next reader finds it, whereas a gap noted at the gate is a judgment made by whoever happened to arrive there, invisible to anyone who did not. A specification that forbids both forbids the recorded decision along with the unrecorded one, which forces a gate that some legitimate change cannot pass.

#### Scenario: A stage boundary names an observable rather than a stage

- **WHEN** the fragment states that implementation follows review and test authoring
- **THEN** it names what must exist before implementation begins — the review verdict, the commit holding the approved plan, and the tests derived from that plan — rather than stating only that review and test authoring are earlier stages

#### Scenario: An obligation dispatched against incomplete inputs is prevented, not merely discouraged

- **WHEN** the fragment states an obligation discharged by dispatching a reviewer or test author against a change's artifacts
- **THEN** it states which artifacts must be complete before that dispatch, so that dispatching against a partial package is a precondition failure rather than a judgment call

#### Scenario: A missing precondition halts rather than annotates

- **WHEN** an agent following the fragment reaches a gate whose precondition is absent and no exemption stated in advance covers it
- **THEN** the fragment directs it to take the missing step first, and states no alternative in which the gate is passed and the gap recorded

#### Scenario: An exemption stated in advance is not a gap noted at the gate

- **WHEN** a precondition is unsatisfiable for a class of change that a specification or a project rule has already exempted, naming the class and the reason
- **THEN** the gate is passed without that precondition and the exemption's reason is stated, while a precondition merely found absent at the gate still halts

#### Scenario: A gate does not foreclose a change that structurally cannot satisfy it

- **WHEN** a change cannot produce one of a gate's preconditions because that precondition's own inputs are outputs of the change itself
- **THEN** the fragment admits the stated exemption covering it, rather than describing a gate no such change can pass

### Requirement: An automatic agent-dispatch loop stated by the rules is bounded

Where the workflow rule fragment states an obligation discharged by repeatedly dispatching an agent until a condition is met, it SHALL state a bound on how many of those dispatches happen without asking, and SHALL state what the agent does on reaching the bound: report where the loop stands and what is outstanding, and ask before continuing.

The bound SHALL be stated as a role-level obligation, not only inside a harness binding. A bound that lives only in a binding is absent from every project that fills the role by other means, and an unbounded loop is the more expensive failure precisely where the binding is unfamiliar.

The fragment SHALL further state which outcomes exit the loop rather than consume a round. An outcome that no amount of revision answers — a judgment against the change's concept rather than against its artifacts — is not a round of the loop, and treating it as one spends the bound on revisions that cannot succeed.

An unbounded loop dispatches an agent repeatedly against work no one has looked at since it started, and converges or does not with nothing reporting which.

#### Scenario: The bound is reached rather than exceeded

- **WHEN** a loop the fragment states has run its stated number of automatic dispatches without meeting its exit condition
- **THEN** the fragment directs the agent to report the loop's state and what is outstanding, and to ask before dispatching again

#### Scenario: The bound survives the binding being absent

- **WHEN** a project carries the managed block and fills a looping role by some means other than the named binding
- **THEN** the bound and the ask-on-reaching-it obligation are still stated, because they sit in the role rather than in the binding

#### Scenario: A non-revisable outcome exits rather than iterates

- **WHEN** the outcome of a dispatch is a judgment that revision cannot address
- **THEN** the fragment directs the loop to stop and raise it at once, whatever the count stands at, rather than counting it as a round

### Requirement: The fragment's version increments when its body changes

A rule fragment's `version` SHALL increment whenever the body text inlined into a project changes. This is stated for the workflow rule fragment, which is the only fragment inlined today, and holds for any other fragment this capability inlines. It SHALL NOT increment for a change confined to the fragment's own frontmatter, and it SHALL NOT remain unchanged across a body edit.

The version is what a project's managed block records, and the only thing distinguishing an adopted copy from a current one. A body edit that leaves the version alone makes every project carrying the old text indistinguishable from one carrying the new, which defeats the marker's stated purpose of answering which version a project adopted.

This requirement owns when the version increments. `toolkit-structure` fixes the frontmatter's form and states that the version is unrelated to any package or plugin version; it defers the increment condition here by name, so that an author checking a fragment edit reaches one answer rather than two.

#### Scenario: An edited fragment is distinguishable from the copy already adopted

- **WHEN** the fragment's body is edited and a project already carries a managed block of the previous text
- **THEN** the version the tool carries differs from the version recorded in that project's block, and the skew is therefore reportable

#### Scenario: A frontmatter-only edit does not consume a version

- **WHEN** the fragment's frontmatter changes while the body inlined into a project does not
- **THEN** the version is unchanged, because no project's inlined text differs from any other's

### Requirement: A repository the tool creates starts on a stated branch

Where the tool initializes the repository in a target whose `.git` was absent or empty before the run, the repository's `HEAD` SHALL name the branch given by the operator's `init.defaultBranch` configuration where that is set, and `refs/heads/main` where it is not. The tool SHALL NOT leave the initial branch to git's built-in default, which differs between git versions and machines.

Where the repository concern is already satisfied, the tool SHALL NOT change the repository's current branch, whether or not that branch has commits. Where the target holds a `.git` with any content that the repository concern does not recognise as a repository, the tool SHALL NOT write that repository's `HEAD` itself; what it should do with such a directory otherwise is outside this requirement.

The step SHALL NOT rely on `git init --initial-branch` or on `git init` honouring `init.defaultBranch`, both of which need git 2.28; the resulting branch SHALL be the same on an older git. The configuration SHALL be read as the created repository sees it, not as an enclosing repository or the caller's working directory sees it.

Where the initial branch cannot be set after the repository was created, the run SHALL end in `ERROR` with a reason naming that step.

#### Scenario: No configured default yields main

- **WHEN** the tool creates a repository and `init.defaultBranch` is not set in any git configuration the run can see
- **THEN** the created repository's `HEAD` is `refs/heads/main`

#### Scenario: A configured default is honoured

- **WHEN** the tool creates a repository and `init.defaultBranch` is set to a name other than `main`
- **THEN** the created repository's `HEAD` names that branch, not `main`

#### Scenario: A configured default in an enclosing repository is not read

- **WHEN** the tool creates a repository in a subdirectory of an existing repository whose own local configuration sets `init.defaultBranch`, and no global or system configuration sets it
- **THEN** the created repository's `HEAD` is `refs/heads/main`

#### Scenario: An existing repository's branch is left alone

- **WHEN** the tool runs where the target is already the root of a repository whose `HEAD` names a branch other than `main`, with or without commits
- **THEN** the repository is reported `already present` and its `HEAD` still names that branch after the run

### Requirement: A backlog is seeded where none exists

Where `docs/backlog.md` does not exist in the target, the tool SHALL create it, in both the new-project and the adoption mode, creating `docs/` if absent. Where the file exists, the tool SHALL leave it byte-for-byte unchanged and report it present.

The workflow fragment routes out-of-scope work to that path and defers to the file for how an entry is written. A file each project's first session invents carries a different header, entry shape and deletion rule in every project, so the rules the fragment defers to would not be the same rules anywhere.

The created file SHALL state, as prose a session reads before adding an entry:

- that it lists changes the project has identified and not yet archived, each recorded instead of being folded into the change that found it;
- that an entry's heading is the change's kebab-case name — the name its branch and change directory are expected to take, which the session that opens the change may revise if the work turns out different — and that an entry is referred to only by that name, a fix taking it as its branch's name only;
- that the order of entries carries no meaning, and that an entry states in its own fields what it waits on and which entries share a design with it;
- that an entry is kept short: what is needed and why, with files, specifications and changes named as pointers, and without line numbers, census tables or step-by-step plans;
- that an entry is deleted when its change is archived, when the operator takes it as a fix rather than a change, when a change makes it obsolete, or when the operator decides the change will not be made;
- that when a change is archived, the entries it unblocked or made stale are updated and their re-checked date set;
- that the file is kept when it has no entries;
- the shape of an entry: its heading; what the change is and why, written for a session that has not seen the work that found it; its **Kind**, `fix` or `change`, with the reason; what it **Waits on**, as `nothing` or as something that can be checked — a change by name, a person's answer, an event; which entries it is to be **designed with**, or nothing; what **recorded** it and why it was not done there; and the date it was last **re-checked** against the repository.

**Kind is `fix` only where the entry owes no specification delta, needs no decision from the operator, and is small enough to review in one sitting**; otherwise it is `change`. The size condition is the workflow's own: a fix is work too small to be a change, which skips `plan`, so an entry too large for one sitting is not one whatever it owes. The reason is stated because the label alone cannot be checked, and an entry's kind is the first thing a session picking work reads.

**Waits on replaces a list of changes that must land first.** An entry that should precede another says so from the waiting side: the later entry names it in Waits on. The earlier shape also let an entry state what it should precede; that direction is dropped, because a constraint stated on both sides is two statements that drift, and Waits on is the side the pick and the archive re-read read.

A blocked entry waits on more than changes — an answer, an access grant, a production event — and a trigger stated as something checkable is the one that can be noticed when it fires.

Entry brevity is stated because the details it excludes are the ones that go stale first, and the session that takes the entry up redoes them anyway. A census worth keeping belongs in the change's own artifacts once the change is opened.

**This requirement owns the backlog's entry rules**; `session-workflow` owns only routing work to the file and when it is re-read, and its fragment defers to the file for these rules rather than restating them. `backlog-maintenance` performs operations over the file and likewise reads these rules from it.

The file is present where a path exists at `docs/backlog.md` of any type, including a symbolic link whether or not it resolves. A link counted as absent would be written through, to wherever it points.

The created file SHALL contain no entry, and SHALL NOT number entries or mention entry numbers. An entry carrying a number invites citing and ordering by it; a name is the identifier that survives other entries being deleted.

The file is kept when empty because the tool created it: deleting it would leave the next session to recreate it from no text at all, which is the variance this requirement removes.

#### Scenario: A project without a backlog receives the seeded file

- **WHEN** the tool runs in a target with no `docs/backlog.md`
- **THEN** the file is created with every statement listed above and no entry, and the report states the backlog was created

#### Scenario: An existing backlog is preserved exactly

- **WHEN** the target already contains `docs/backlog.md`
- **THEN** its contents are left byte-for-byte unchanged and the report states the backlog is already present

#### Scenario: The seeded file carries no numbering

- **WHEN** the seeded file is created
- **THEN** no heading in it begins with a number and no sentence in it refers to an entry's number

#### Scenario: The seeded entry shape carries the structured fields

- **WHEN** the seeded file is created
- **THEN** its entry shape names Kind, Waits on, Design with, Recorded by and Re-checked, and does not name Depends on

#### Scenario: A fix is distinguished from a change by what it owes

- **WHEN** a session reads the seeded file to record an entry that owes a specification delta
- **THEN** the file's definition of Kind leaves only `change` available to it, because `fix` is stated as owing no delta, needing no decision and fitting one review sitting

### Requirement: A wrapper offers the direct initial commit only to a repository without one, and shows what it holds

A wrapper SHALL offer to create a commit directly on the repository's current branch only where the run ended in `SUCCESS` and the repository rooted at the target had no commit — the new-project mode. That commit is the repository's first, and the only one the workflow lets reach the trunk without a pull request. The wrapper SHALL take the mode from the tool's report, which names a different next step in each, rather than re-deriving it.

Before asking for confirmation, the wrapper SHALL show the operator every path the commit would contain: every path already staged, and every untracked path not excluded by git's standard exclusions — not only the paths the tool wrote. A wholly untracked directory MAY be shown as one entry. A target may already hold the project's own files when it is initialized, and a confirmation given for "what the tool just did" is not a confirmation of those.

Where the operator declines the commit, the wrapper SHALL state that the repository's first commit and a remote are both outstanding, and that the workflow's first pull request needs both.

In the adoption mode the wrapper SHALL NOT offer to commit the tool's writes onto the repository's current branch, and SHALL state that they reach the trunk through a pull request like any other change. Where the adopted repository has no remote configured, it SHALL also state that a remote is needed before that pull request can be opened.

#### Scenario: The commit offer lists files the tool did not write

- **WHEN** a new-project run succeeds in a target that already held a file of the project's own, not excluded by the ignore file
- **THEN** the wrapper's offer names that file among the paths the commit would include, before asking for confirmation

#### Scenario: A file staged before the run is listed

- **WHEN** a new-project run succeeds in a target whose repository has no commit and a file already staged
- **THEN** the wrapper's offer names that file among the paths the commit would include

#### Scenario: A declined commit leaves both gaps stated

- **WHEN** the operator declines the initial commit
- **THEN** no commit and no remote exist, and the wrapper states that the first commit and a remote are both outstanding

#### Scenario: An adoption is not committed onto the trunk

- **WHEN** an adoption run succeeds
- **THEN** the wrapper offers no commit onto the current branch and states that the tool's writes reach the trunk through a pull request

### Requirement: A wrapper connects a remote only from a URL the operator supplies

After the initial commit has been made in the new-project mode, where the repository has no remote configured, the wrapper SHALL ask the operator for the URL of a hosted repository the operator has created. The wrapper SHALL NOT create a hosted repository, and SHALL NOT choose its forge, owner, name or visibility: each is a judgment about the project, not a deterministic step.

Where the operator supplies a URL and confirms, the wrapper SHALL add it as the remote `origin` and push the current branch to it with its upstream set. Pushing is outward-facing, so the wrapper SHALL NOT push before that confirmation.

Where the push fails — the hosted repository is not empty, the URL is unreachable, access is refused — the wrapper SHALL report the failure as git stated it, SHALL state that `origin` now names the supplied URL, and stop. It SHALL NOT force the push, and SHALL NOT fetch, merge or rebase the remote's content to make the push succeed; correcting the remote and pushing are the operator's. Re-running the tool does not return to this step, since the repository then has a commit.

Where the operator declines or supplies no URL, the wrapper SHALL state that the workflow's first pull request needs a remote with the trunk pushed to it, and continue to naming the next step.

Where a remote is already configured, the wrapper SHALL leave it unchanged and SHALL NOT ask for one.

The tool itself SHALL NOT configure a remote or push. The remote step is the wrapper's, because it needs the operator's answer and a network, and the tool is deterministic and asks nothing.

#### Scenario: A supplied URL is connected and pushed after confirmation

- **WHEN** the initial commit has been made, no remote is configured, and the operator supplies a URL and confirms
- **THEN** `origin` names that URL and the current branch is pushed to it with its upstream set

#### Scenario: A rejected push is reported, not forced

- **WHEN** the push to the supplied URL is rejected because the hosted repository already has commits
- **THEN** the wrapper reports the rejection, states that `origin` names the supplied URL, and stops, and neither force-pushes nor merges the remote's history

#### Scenario: Declining leaves the gap stated

- **WHEN** the operator declines to supply a URL
- **THEN** no remote is configured, and the wrapper states that the first pull request needs a remote with the trunk pushed to it

#### Scenario: An existing remote is left alone

- **WHEN** the repository already has a remote configured when the initial commit is made
- **THEN** the wrapper does not ask for a URL and the configured remote is unchanged

#### Scenario: The tool configures no remote

- **WHEN** `scripts/project-init` runs to `SUCCESS` in an empty directory
- **THEN** the created repository has no remote configured
