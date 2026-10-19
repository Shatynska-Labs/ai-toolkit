## ADDED Requirements

### Requirement: Test arrangement a derivation lacked is promoted by the change that needed it

The workflow fragment's **derive tests** SHALL name, among what the test author needs from this project's conventions, the location of the project's shared test arrangement where the project has one, alongside the test command and the test-path glob.

The fragment's **apply** SHALL direct that each entry in the change's test plan listing missing shared arrangement be dealt with in the same change, before `build`'s review, in one of two ways, and that the disposition be recorded against the entry:

- **promoted** — the arrangement is added to the shared test arrangement, or the near-miss the entry names is extended to serve it, and the derived tests that declared it locally are moved onto it;
- **kept** — the arrangement stays declared locally, and a reason is recorded.

Where the project's conventions record no shared arrangement's location — whether they state that the project has none or are silent on it — every entry is kept with that reason. Creating a shared arrangement, or recording where an existing one lives, is a decision about the project's testing strategy, not a step of the change that happened to need one.

The fragment SHALL state outright that moving derived tests onto promoted arrangement is permitted, since an implementer reading that existing tests are never weakened either leaves them untouched or edits them in a way that reads as weakening at review. It SHALL bound the permission: only where a test takes its arrangement from changes — the local declaration removed, an import from the shared arrangement added, an adapter to the shared arrangement's constructor — and never what the test asserts.

The fragment SHALL state the reason promotion happens in the same change in as few words as carry it: a local copy drifts from the interface it stands in for, and later tests import it from the test file that declared it.

#### Scenario: The test author's inputs include the shared arrangement

- **WHEN** a session dispatches the test author following **derive tests**
- **THEN** the fragment has named the shared arrangement's location, where the project's conventions record one, among the inputs to supply

#### Scenario: A listed item is promoted during apply

- **WHEN** the test plan lists a locally declared fake and the implementer adds it to the shared test arrangement
- **THEN** the implementer removes the local declaration from the derived test, takes the fake from the shared arrangement instead, leaves every assertion in that test unchanged, and records the entry as promoted

#### Scenario: A listed item is kept

- **WHEN** the implementer decides a listed item stays local
- **THEN** a reason is recorded against its entry in the test plan, and the derived test is left as written

#### Scenario: A project with no shared arrangement keeps every entry

- **WHEN** the project's conventions state that it has no shared arrangement and the test plan lists missing arrangement
- **THEN** each entry is recorded as kept with that reason, and no shared arrangement is created by the change

#### Scenario: A project silent on its shared arrangement keeps every entry

- **WHEN** the project's conventions neither name a shared arrangement nor state that there is none, and the test plan lists missing arrangement
- **THEN** each entry is recorded as kept because the shared arrangement's location is unrecorded, and nothing is promoted into an unrecorded location

#### Scenario: The permission does not reach assertions

- **WHEN** an implementer moves a derived test onto promoted arrangement
- **THEN** the edit is confined to where the test takes its arrangement from, and an edit to what it asserts is outside the permission
