## ADDED Requirements

### Requirement: Arrangement the Shared Arrangement Lacks Is Declared Locally and Handed On

A project's **shared test arrangement** is the test code its tests take builders, fixtures, fakes and stubs from — a module the runner imports but does not collect as tests. The agent SHALL NOT write to it, edit it, or add a module to it: editing a shared double changes what every test using it arranges, which is editing existing tests by another route, and telling a new shared module from a changed one would need a rule that is easy to get wrong.

Where a scenario needs arrangement the shared arrangement does not hold, the agent SHALL declare that arrangement inside the test file it is writing, so the tests run and fail for the reason the testing floor requires rather than for want of a collaborator. It SHALL record every such local declaration in the manifest, so the declaration reaches the implementation step rather than staying where it was written.

Where the shared arrangement holds a **near-miss** — arrangement standing in for the same port, collaborator or value that does not serve the scenario as it stands — the agent SHALL NOT edit the near-miss. It SHALL declare what it needs locally and record the near-miss together with why it would not do.

Where the dispatch names no shared arrangement, the agent SHALL still declare what its tests need locally and record each declaration, and the manifest SHALL state that no shared arrangement was named. Where, in addition, the dispatched convention files neither name a shared arrangement nor state that the project has none, the agent SHALL record that as an **unresolved project question** and surface it in its report: such a project leaves every later pass declaring locally what may already exist, and the operator is the one who can record it. Where the convention files state that the project has none, no question is raised.

#### Scenario: Missing arrangement is declared locally and recorded

- **WHEN** a scenario's test needs a fake for a port the dispatched shared arrangement does not hold
- **THEN** the agent declares the fake inside the test file it is writing, leaves the shared arrangement unchanged, and records the declaration in the manifest's **Missing shared arrangement** section

#### Scenario: A near-miss is recorded, not extended

- **WHEN** the shared arrangement holds a builder for the needed value that lacks a field the scenario sets
- **THEN** the agent declares its own builder locally, does not edit the shared one, and records the shared builder as a near-miss with the missing field as the reason it would not do

#### Scenario: No shared arrangement was named

- **WHEN** the dispatch names no shared arrangement, the convention files are silent on one, and the tests need a stub
- **THEN** the agent declares the stub locally, records it, the manifest's section states that no shared arrangement was named, and the absence is recorded and reported as an unresolved project question

#### Scenario: A project that has none raises no question

- **WHEN** the dispatch names no shared arrangement and the convention files state that the project has none
- **THEN** the manifest's section states that no shared arrangement was named, and no unresolved project question is raised for it

### Requirement: Arrangement Is Never Imported from Another Test Module

A **test module**, for this requirement, is any file within the dispatched test-path glob that is not part of the dispatched shared arrangement. A test file the agent writes SHALL take its arrangement only from the shared arrangement or from declarations in that same file. It SHALL NOT import any name from another test module — including a test module the same pass wrote, and including arrangement an earlier change declared locally that serves the scenario exactly.

Each such import couples the importer to a module that may be rewritten or deleted for reasons of its own, and a module imported this way becomes a library no one owns. Arrangement found in another test module is handled as missing arrangement: declared locally and recorded, with the test module it was found in named in the record.

#### Scenario: Arrangement found in an earlier test module is not imported

- **WHEN** the arrangement a scenario needs exists in an earlier change's test file and not in the shared arrangement
- **THEN** the agent declares it in its own test file, records it as missing shared arrangement naming the test file it was found in, and adds no import from that test file

#### Scenario: Two test files written by one pass do not share arrangement by import

- **WHEN** two test files written by the same pass need the same local stub
- **THEN** each declares it, or neither does because the shared arrangement holds it; neither imports it from the other

## MODIFIED Requirements

### Requirement: The Change Is Supplied by Dispatch, Not Discovered

The agent SHALL work on what its dispatcher names and SHALL NOT search for a change to act on or infer the repository from where it was dispatched.

**Essential inputs**, without which there is nothing to act on: the change name, the absolute `changeRoot`, the resolved artifact paths, the absolute path to the change's `.openspec.yaml`, the absolute paths of the project's convention files (`AGENTS.md`, `CLAUDE.md`, or their absence stated explicitly), the project's test command, and the **test-path glob** identifying where tests may be written.

`specsRoot` is **conditionally** essential, stated separately so the qualification cannot be read as binding the inputs around it. It is required where the change carries a `MODIFIED`, `REMOVED` or `RENAMED` delta, because establishing what was superseded means reading the requirement as it currently stands. Where every delta is `ADDED` there is nothing to compare against and the agent SHALL NOT block on its absence, whether or not the project records specifications elsewhere.

The dispatch MAY additionally supply the absolute path of an earlier `test-plan.md`. This is optional: its absence changes what the obsolete search can draw on, not whether the pass can proceed.

The dispatch MAY additionally supply the absolute path or paths of the project's **shared test arrangement**, read-only. This is optional: its absence changes what the agent's tests can take arrangement from — everything they need is then declared locally — and what the manifest's missing-arrangement section records, not whether the pass can proceed. The agent SHALL NOT go looking for a shared arrangement the dispatch did not name, for the same reason it constructs no other path.

The `.openspec.yaml` path is essential rather than derived because this specification forbids constructing paths, and the specs-exemption below is read from that file — an exemption reachable only by guessing a conventional location would not be the file read it is described as.

The convention-file paths are essential because the testing floor this agent loads obliges it to read a project's recorded conventions before test work. An agent that cannot reach them cannot discharge an obligation it has inherited, and would satisfy it by assumption instead. Missing any of the inputs enumerated above, the agent SHALL report itself blocked on what is absent and stop, rather than guessing a conventional path. This blocking rule reaches the enumerated essential inputs only; the conditional and optional inputs described below are governed by their own paragraphs.

Every file SHALL be addressed by the absolute path supplied. A conclusion resting on a file nobody named rests on ground the dispatcher cannot reproduce.

#### Scenario: A missing essential input blocks rather than defaults

- **WHEN** a dispatch omits the test command or the test-path glob
- **THEN** the agent SHALL report itself blocked naming what is missing, and SHALL NOT infer a runner from the repository's contents or write tests to a path it chose itself

#### Scenario: Paths are not guessed from convention

- **WHEN** the agent needs the change's artifacts
- **THEN** it SHALL use the supplied absolute paths, and SHALL NOT construct a path such as `openspec/changes/<name>/` or assume the working directory is the repository

#### Scenario: An absent shared arrangement does not block

- **WHEN** a dispatch supplies every essential input and no shared-arrangement path
- **THEN** the agent proceeds, does not search the repository for a shared arrangement, and declares the arrangement its tests need locally

### Requirement: What the Agent May Read Is Bounded

The reason this work runs in its own context is that its author has not seen the implementation and therefore cannot shape assertions to match it. That property is secured by dispatch ordering for an `ADDED` requirement — there is nothing to read — but not for a `MODIFIED` one, where the pre-change implementation exists and matching tests to superseded behaviour invites reading it. Left unstated, the agent could satisfy every other requirement here while deriving its assertions from the code it is meant to constrain.

The agent SHALL read only: the change's artifacts at the paths supplied; the specifications under `specsRoot`; the project's dispatched convention files; an earlier `test-plan.md` where its path is supplied; the dispatched shared test arrangement where its path is supplied; and files within the dispatched test-path glob. It SHALL NOT read the implementation of the behaviour under test, and SHALL NOT do so in order to establish what a `MODIFIED` delta supersedes — the delta and the existing requirement state that, which is what `specsRoot` is for.

The shared arrangement is test code, and reading it is no route to the implementation. A shared double mirrors a port's signature; the agent SHALL take that signature from the double, and SHALL NOT follow the double to the port's implementation, nor read the port's implementation to judge whether the double is faithful.

Reading a source file outside the test-path glob and the shared arrangement to determine what an assertion should say SHALL be reported as a departure from this bound, not resolved silently.

#### Scenario: Superseded behaviour is established from specifications, not from code

- **WHEN** the agent must determine what a `MODIFIED` delta supersedes
- **THEN** it SHALL do so by comparing the delta with the existing requirement under `specsRoot`, and SHALL NOT read the implementation to find out

#### Scenario: The read bound is reported rather than crossed silently

- **WHEN** the agent cannot proceed without reading implementation source
- **THEN** it SHALL report that it is blocked on the bound rather than crossing it, so the property the separate context exists to secure is not lost unrecorded

#### Scenario: A shared double is read without following it to the port

- **WHEN** a shared double outside the test-path glob stands in for a port the scenario's code calls
- **THEN** the agent reads the double to learn the port's signature and does not read the port's implementation

### Requirement: The Pass Produces a Manifest at a Named Path

The artifact's filename is `test-plan.md`, renamed from `test-manifest.md` by `consolidate-development-workflow`. The name is the one the wider OpenSpec ecosystem uses for an artifact of this shape, so a project forking a schema that declares `id: test-plan` gets this artifact unchanged rather than renaming it at the moment that is least wanted. What the artifact is and what it must carry are unchanged.

Where the pass proceeds past both stop-routes — the blocked report and the specs-exempt report, neither of which writes one — the agent SHALL write a manifest to **`<changeRoot>/test-plan.md`** — that exact name, so the `rules/` fragment and any later reader can name it — recording, at minimum: each scenario and the tests covering it; each uncovered scenario with its reason; each assertion's classification under the testing floor's specified/derived/deliberately-untested rule; the obsolete-tests list, each entry carrying the superseding delta, the evidence it was matched on, and its candidate-for-confirmation marking; any unresolved project questions with the assumptions taken and the tests depending on them; the **Missing shared arrangement** section; and the baseline, recorded in whichever form the testing floor permits — including a scoped baseline together with its scope, which that floor makes a first-class form rather than a fallback. The manifest SHALL NOT restate or narrow the floor's baseline rule; it records the result in the forms that rule defines.

The **Missing shared arrangement** section SHALL be present in every manifest. It SHALL list each local declaration of arrangement the pass made, each entry recording: the declared name and the test file declaring it; what it stands in for — the port, collaborator or value; the tests using it, in runner-selectable form; whether the shared arrangement holds a near-miss, and if so which and why it would not do; where it was found in another test module, if it was; and a proposed home in the shared arrangement, or, where none was named, that there is none to propose. Where the pass declared nothing locally, the section SHALL say so. Where the dispatch named no shared arrangement, the section SHALL say so in addition to listing the declarations. A section with nothing to list SHALL NOT be omitted, so a pass that needed no arrangement is distinguishable from a manifest that never considered it.

The manifest SHALL name tests in a form the test runner can select, so that whoever implements next can run exactly the tests a given task must satisfy.

The agent SHALL state in its report that the manifest is not an artifact the OpenSpec schema knows about, so it is not surfaced by `openspec instructions apply` and must be read deliberately.

#### Scenario: The manifest carries runnable test identifiers

- **WHEN** the manifest records that a scenario is covered
- **THEN** the tests SHALL be named in a form the project's runner can select individually, not described in prose

#### Scenario: The baseline is carried into the manifest

- **WHEN** the pass completes
- **THEN** the manifest SHALL record the baseline taken before the tests were written — full, or scoped together with its scope — or state that none could be taken and why, matching the forms the testing floor defines rather than a narrower pair

#### Scenario: A local declaration is listed with everything promotion needs

- **WHEN** the pass declared a fake locally
- **THEN** the manifest's **Missing shared arrangement** section lists it with its name and file, what it stands in for, the tests using it, any near-miss and why it would not do, and a proposed home

#### Scenario: Nothing missing is stated, not omitted

- **WHEN** every test the pass wrote takes its arrangement from the shared arrangement
- **THEN** the manifest's **Missing shared arrangement** section is present and states that nothing was declared locally

### Requirement: The Manifest Is Reachable by Whoever Implements Next

The manifest is not an artifact the OpenSpec schema defines, so it is not surfaced among the context files an implementation step is handed. The library SHALL therefore carry a rule fragment directing that a change's `test-plan.md` be read before implementing, and stating why it is not surfaced automatically.

The fragment SHALL also name the manifest's **Missing shared arrangement** section and state what the implementation step does with it: each listed item is promoted into the shared arrangement in the same change, or kept with a recorded reason, and the disposition of each is written against its entry in that section.

The agent's own report SHALL name the manifest's path as well. The fragment's import path is machine-local, resolving only where this library is checked out at that path, so a fragment alone would leave the manifest unreachable on any other machine. Two independent pointers are deliberate rather than redundant.

#### Scenario: The manifest is pointed to twice

- **WHEN** the pass completes
- **THEN** the manifest's location SHALL be reachable both from the rule fragment and from the agent's own report, so a machine without this library checked out at the imported path still learns where it is

#### Scenario: The fragment names what implementation does with missing arrangement

- **WHEN** an implementer reads the rule fragment before implementing
- **THEN** it learns that the manifest lists missing shared arrangement and that each item is promoted or kept, with the disposition recorded against the entry
