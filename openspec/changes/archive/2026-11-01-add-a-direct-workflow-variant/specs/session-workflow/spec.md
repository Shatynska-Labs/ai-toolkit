## ADDED Requirements

### Requirement: The default workflow reaches production by promotion

`rules/development-workflow.md`, the promoting publication, SHALL state `ship` as `open pr · merge · deploy staging · confirm · promote · deploy production · smoke · archive`, with each transition deriving its state by the vocabulary's rule and one sentence saying `ship:confirmed` means the effect was confirmed on staging. It SHALL state that:

- a merge reaches staging and nothing else, and production is reached only by a promotion a person triggers, which a session proposes and never triggers silently, and the deploy command is never run locally against either host;
- `confirm` happens on staging, and a confirmed effect does not establish that production received it;
- production's gate is the smoke check the promotion runs, not a second `confirm`;
- a promotion whose smoke check fails leaves production on the promoted image, is not a delivered change, and re-enters at `build`'s review gate, with promoting the previous commit the operator's remedy;
- a change is archived only once it is confirmed or its gate waived and it is in production, and a change deliberately not going to production is archived on the operator's word as a waiver of `promote`, recorded as a confirmation waiver is and distinct from it;
- production runs behind the trunk by every merge not yet promoted, which is the pipeline working, not drift;
- the release a change must stay compatible with is the one production runs, not the trunk's last merge, because production lags the trunk and rollback is a promotion.

The fragment SHALL name no file, job or service of one project: `promote.yml`, `publish-prompts` and the like belong in that project's own conventions.

#### Scenario: Merging does not reach production

- **WHEN** a reader follows `ship` in `rules/development-workflow.md`
- **THEN** the stages name `deploy staging`, `promote`, `deploy production` and `smoke`, in that order, between `merge` and `archive`, and `confirm` precedes `promote`

#### Scenario: A change confirmed and never promoted is not archived

- **WHEN** a change is confirmed on staging and not promoted
- **THEN** the fragment does not permit its record, unless the operator waives `promote`, which it distinguishes from waiving `confirm`

#### Scenario: The previous release is what production runs

- **WHEN** a reader looks for what a change must stay compatible with
- **THEN** the fragment names the release production runs, not the trunk's last merge

#### Scenario: No project's name reaches the fragment

- **WHEN** `rules/development-workflow.md` is read
- **THEN** neither `promote.yml` nor `publish-prompts` appears in it

### Requirement: The two workflows differ only in what states ship

`rules/development-workflow-direct.md` SHALL state the one-deploy `ship`: `open pr · merge · deploy · confirm · archive`, with a change reaching production by merging. Outside the `### ship` section, the fragments' bodies SHALL be byte-identical except for exactly these: three lines that differ, the paragraph stating work too small to be a change, the paragraph stating what the rules assume, and the `ship:` line of the stage list; and one paragraph only the promoting fragment holds, directly after the paragraph stating the derivation of a state. A test taking the two paths as arguments SHALL hold this, and SHALL fail on any other difference.

Every requirement `project-bootstrap` and this capability state of the workflow fragment SHALL hold of both, except where one is named. Each fragment carries its own `version`, and the version of each SHALL rise when its own body changes. Each SHALL be complete on its own, so that an `@` import of either reaches a project with no tool involved.

**Two complete files and a test, not a shared file assembled by the tools** (design decision 1). `AGENTS.md` rules out a build step, and a fragment holding a placeholder would break the `@` import route.

#### Scenario: A difference outside ship fails

- **WHEN** the test is given two files whose `### build` sections differ
- **THEN** it fails naming the differing line

#### Scenario: The test cannot pass vacuously

- **WHEN** the test is given a file with no `### ship` section
- **THEN** it fails rather than comparing nothing

#### Scenario: The direct workflow reaches production by merging

- **WHEN** a reader follows `ship` in `rules/development-workflow-direct.md`
- **THEN** the stages are `open pr · merge · deploy · confirm · archive`, and `promote` appears nowhere in them

#### Scenario: The fragments as shipped differ only as stated

- **WHEN** the test is given `rules/development-workflow.md` and `rules/development-workflow-direct.md`
- **THEN** it passes

## MODIFIED Requirements

### Requirement: The session obligations are published in the workflow fragment and one binding fragment

*Modified by `add-a-direct-workflow-variant`: the workflow fragment is published in two forms, one per delivery shape, and an obligation shared by them is amended in both. "The workflow fragment" below means both unless one is named. Every scenario keeps its title.*

The obligations this capability governs SHALL be published in the three places named below, and in no further place a session must read alongside them to act correctly:

- `rules/development-workflow.md` — the workflow fragment in its promoting form, which states every obligation service-neutrally alongside the spec-driven gates it already carries, and which `scripts/project-init` inlines into a consuming project's conventions file by default;
- `rules/development-workflow-direct.md` — the workflow fragment in its direct form, the same text with the one-deploy `ship`, inlined in the promoting form's place where a project asks for it;
- `rules/development-workflow-database.md` — the binding fragment, which binds the workflow fragment's provisioning and namespace obligations to a containerized relational database.

The workflow fragment SHALL state a role and name its binding beneath it, as it already does for the agents and the working-tree location it binds to Claude Code. The binding fragment SHALL NOT restate an obligation the workflow fragment states; it names the service, the naming form and the operations that reach the stated end state.

**The fragment SHALL name its unit of work before stating any rule about it.** The unit is a change, and every rule below is a rule about a change's life; a document that never says so leaves a reader to infer it from the rules themselves.

**It SHALL state what falls outside that unit and what happens to it.** Work too small to be a change skips `plan` — there is nothing to specify — and does not skip `ship`, since nothing reaches production except by the route `ship` states: merging in the direct form, merging and a promotion in the promoting form. Unstated, the reader has two readings and neither is written down: that trivial work carries the whole process, or that it escapes the delivery rules too.

The qualifier SHALL sit in the opening rather than inside a rule. It governs whether the document applies at all, and a scope condition met halfway through has already been read as unconditional by anyone who stopped earlier.

**The workflow fragment SHALL assume a remote, pull requests, continuous integration, and its form's delivery shape, and SHALL state no conditional for their absence.** The promoting form assumes a staging deploy triggered by merging and a production deploy triggered deliberately; the direct form assumes that merging to the trunk deploys. Pull requests imply the forge whose merged-state report the teardown gate reads; naming it separately in the assumptions states twice what the gate states once. Every project these rules are written for has all of them. A conditional for a shape no consumer has is paid for by every reader of every project that does have one, and it is the class of text that made the previous publication expensive.

A project of a shape these assumptions do not fit is served by a publication of its own rather than by a conditional here. A second publication is written when there is something to write it for; a conditional is carried forever whether or not anything needs it.

The direct form is such a publication, written on 2026-11-01 for a repository with no production or whose job is that every server runs. Where such a publication is written, **this capability owns it alongside the others**, and states each shared obligation once while naming which publications it binds — the arrangement it already holds for the workflow fragment and the binding fragment. Stated, because the argument against keeping two publications of one rule set is that both must be maintained, and that argument applies to this pair the moment it exists rather than being answered by the pair having been anticipated.

Neither fragment SHALL name a `rules/` path, a sibling fragment, or an import. In a consuming project the conventions file is a copy and no `rules/` directory is read, so a sentence naming a fragment file names something the reader cannot open.

Where a binding is itself a fragment rather than a tool name written inline, the workflow fragment SHALL refer to it by where the reader will find it — an adjacent section of the same conventions file, where the project carries one — and not by a path. The reference SHALL be conditioned on the project carrying that binding, since until the installing tool writes a second block the section exists only where someone pasted it, and an unconditional reference points at nothing in every project initialised in the interval. Otherwise the two clauses above cannot both be satisfied for the case this requirement exists to introduce, and a project holding the workflow fragment alone would carry a service-neutral obligation with no stated way to learn that a binding exists at all.

Neither fragment SHALL name an `ai-toolkit:` agent or skill that this library does not ship. A consuming project reaches the library's agents and skills only through the installed plugin, so a name with no `agents/<name>.md` or `skills/<name>/SKILL.md` behind it is a dispatch that finds nothing — the same dangling reference as a path the reader cannot open, met at the gate that needs it.

`project-bootstrap` owns how the workflow fragment reaches a project and what shape it takes there — the managed block, the version and its increment condition, that a role is named before a tool, that the gates form an ordered sequence with checkable preconditions, and that an automatic dispatch loop is bounded, what happens on reaching the bound, and which outcomes exit the loop rather than consume a round. `change-code-review` owns one sentence of the workflow fragment: the content of `build`'s Claude Code binding, what the session does on each of the reviewer's four verdicts. This capability owns what the rest of the session-derived rules say, and MAY fix the numeric value of a bound for a loop it states — `project-bootstrap` requires that a bound exist and fixes no number.

Where this capability states a loop, it SHALL state the value, what happens on reaching the bound, **and** the outcomes that exit it — all three of what `project-bootstrap` requires of every loop the rules state, since a loop introduced here would otherwise arrive carrying only the part this capability remembered. The seams are stated because all three capabilities bear on one file, and an unstated seam is resolved by whoever amends it first — an editor starting from this capability would otherwise not learn that the binding's content is governed elsewhere.

#### Scenario: A session obligation is stated once

- **WHEN** an obligation this capability governs is amended
- **THEN** it is amended in both forms of the workflow fragment, and the binding fragment changes only where the amendment touches the service, the naming form or the operations

#### Scenario: A reader of a project's conventions finds no dangling reference

- **WHEN** a session reads the workflow fragment's body as inlined in a project's conventions file
- **THEN** every reference resolves within that document, and no sentence names a file that exists only in this library

#### Scenario: A fragment names only agents and skills the library ships

- **WHEN** either fragment's body names an agent or skill as `ai-toolkit:<name>`
- **THEN** the library ships an agent or a skill of that name, and a name it does not ship is reported rather than passing unnoticed

#### Scenario: A project without a deploy is not served by a conditional

- **WHEN** a project that does not deploy on merge needs these rules
- **THEN** it is served by a publication of its own, and the workflow fragment states its assumptions plainly rather than branching on them

#### Scenario: A second publication does not arrive unowned

- **WHEN** a publication for another project shape is written
- **THEN** this capability owns it alongside the workflow fragment and the binding fragment, and states each shared obligation once naming which publications it binds

#### Scenario: An editor learns every owner of the fragment's content from this capability

- **WHEN** an editor reads this capability before amending the workflow fragment
- **THEN** it names `project-bootstrap` as owning how the fragment reaches a project and its shape, `change-code-review` as owning the content of `build`'s Claude Code binding, and this capability as owning what the rest of the rules say

### Requirement: A change's stage is named from a fixed vocabulary

*Modified by `add-a-direct-workflow-variant`: the `ship` transitions are the form's own. Every scenario keeps its title.*

The report of where a change stands SHALL name the stage from a fixed vocabulary rather than describing it in prose. A prose description is re-read and re-interpreted by every session that resumes the work; a name from a closed set is read once.

**A stage SHALL name a state, never an act.** An act names what someone did or will do; a state names what is now true, which is what a report is for. The acts are the transitions between states, and the fragment SHALL state them, since the state names derive from them:

```
plan:   explore · draft · review · fix · approve · commit · derive tests
build:  apply · verify · review · fix
ship:   open pr · merge · deploy · confirm · archive
```

That is the direct form. The promoting form's `ship` line SHALL read `ship:   open pr · merge · deploy staging · confirm · promote · deploy production · smoke · archive`, and its two `deploy` transitions derive `ship:deploying-staging` / `ship:deployed-staging` and `ship:deploying-production` / `ship:deployed-production`, so that neither derives from `deploy` alone.

A state SHALL be `<family>:<transition>ing` while that transition runs and `<family>:<transition>ed` once it has happened.

**The transitions are the closed set; the states derive from them, and the fragment SHALL NOT enumerate every state.** An enumeration alongside a rule that generates the same names is a second source that drifts from the first, and it costs the fragment a paragraph on every read to say what one sentence already says.

The fragment SHALL state the transitions, the derivation rule, and enough examples to fix the pattern. It SHALL name the states the rule does not generate cleanly — `plan:tests-derived` and `ship:pr-open`, where the derivation reorders the words — and the two off-path names available in any family, `blocked:<what>` and `abandoned`.

Where a transition name matches a command the same session drives — `apply`, `archive`, `verify`, `review` — the state derived from it SHALL keep that word, so the operation remains recoverable from the stage.

**The `confirm` transition SHALL be stated as completing on either the operator's confirmation or a recorded waiver**, so `ship:confirmed` is true of a waived change rather than a name it lacks. A waiver is one of the two ways the gate is passed, not a way around it — the delivery requirement closes the record on either — and a transition stated as completing on only one of them leaves a session that has just recorded a waiver with no true stage between `ship:deployed` and `ship:archiving`, at the point in the sequence where the next session most needs to know where it stands. This is a statement about when the transition completes, not a licence to report a state that has not been reached.

**The family prefix SHALL always be written, and the vocabulary SHALL say so.** `plan:reviewing` and `build:reviewing` dispatch different reviewers — one reads the plan and refuses diffs — and the bare word names neither.

Both families SHALL share one review loop — `reviewing → fixing → reviewing` — since applying what a review returned is one act in two families, and stating it twice under two words would present two settings of one mechanism as two mechanisms.

The vocabulary SHALL NOT reuse one word for writing tests and running them: the `plan` transition producing tests from the change's specification deltas and the `build` transition running them against the implementation SHALL carry different words, so the states deriving from them cannot collapse into one. `plan:tests-derived` and `build:verifying` are given here to fix that distinction, not as names the fragment must write out — which state names it writes is governed by the enumeration prohibition above.

`plan:exploring` SHALL name a change with no proposal yet, whose auxiliary artifacts — a handoff — may exist.

**No rule SHALL require that every stage be derivable from the repository, and no ledger SHALL be mandated to make one so.** The stage is reported for the operator's information; a stage reported imprecisely costs a sentence of correction. An artifact recording every gate so that a resuming session could name the stage exactly would be paid for on every change to buy a precision nothing depends on. What a later session must be able to check is covered by the requirement below, which is about decisions rather than about stages.

**The commit rules SHALL state what happens to a commit made while applying, because otherwise they contradict themselves there.** They direct running the verification relevant to what changed before committing; the tests derived before the implementation fail by design until the implementation is complete. So for the whole of `build:applying` the rule requires a check that cannot pass, and a project whose hooks run it cannot commit at all.

The fragment SHALL name the bypass — `--no-verify` — rather than describing one, and SHALL say that the failure is expected rather than a defect. A session that must work the bypass out for itself has been left to guess whether it is breaking a rule, at every commit of the longest stage.

The fragment SHALL state that the bypass suspends the pre-commit check and not the gate: verification still runs before any completion claim. A bypass stated without its bound is read as permission to skip the check it stands in for.

#### Scenario: A commit made while applying is not blocked by tests written to fail

- **WHEN** a session commits partway through implementing, and the derived tests do not yet pass
- **THEN** it bypasses the hooks that run them, and the verification gate before any completion claim still applies

#### Scenario: A resuming session names the stage without interpreting prose

- **WHEN** a session enters a working tree holding a change another session left
- **THEN** it reads the stage from the change's artifacts, the commit log and the forge and names it from the vocabulary, rather than reconstructing a description

#### Scenario: Writing tests and running tests are not one word

- **WHEN** a report names a stage involving tests
- **THEN** `plan:tests-derived` names tests being derived from the specification deltas and `build:verifying` names tests being run against the implementation, and neither name is used for the other

#### Scenario: The vocabulary is not enumerated beside the rule that generates it

- **WHEN** the fragment states the stage vocabulary
- **THEN** it states the transitions, the derivation rule, examples, the two states whose derivation reorders and the off-path names, and does not list every derived state

#### Scenario: An imprecise stage is not treated as a defect worth an artifact

- **WHEN** a session reports a stage that turns out to be one step off
- **THEN** the correction is a sentence, and no rule requires a ledger written on every change so that the case cannot arise

### Requirement: A change is delivered through at least two pull requests, the last carrying its record

*Modified by `add-a-direct-workflow-variant`: in the promoting form the deploy, the confirmed effect and the route to production are as *The default workflow reaches production by promotion* states. Every scenario keeps its title, and reads production as staging for `confirm` in that form; a record in that form also needs the change in production.*

The workflow fragment SHALL state that a completed change reaches the trunk through pull requests, and that it takes **at least two**: the work, then the record that it shipped.

**Two is a floor, not a fixture.** Where the deploy is unhealthy, or the deployed change does not do what it existed to do and the cause is a defect in it, the remedy is itself work reaching the trunk — so it takes a pull request of its own, its own review, its own merge and its own deploy, and the sequence re-enters at the review gate rather than resuming mid-flight. A change that needed two remedial cycles was delivered through four pull requests, and nothing about that is exceptional.

The fragment SHALL therefore state the count as a minimum and SHALL identify the record's pull request as the **last** one rather than the second. A sequence written as exactly two leaves a session that has just merged a fix with no stated position: the record's slot is spent, and the only readings available are to skip the record or to treat the fix as though it never happened.

It SHALL state an entry gate: delivery begins only where the change's verification has run and passed against the branch head, and the post-implementation review has cleared.

**It SHALL bound the post-implementation review loop at three rounds**, and SHALL state that a re-review is dispatched only where the fixes applied were substantial enough to be worth reviewing in their own right. Past three, the session reports where the loop stands and asks rather than dispatching a fourth.

It SHALL also name the outcomes that exit the loop rather than consume a round: a review that clears exits forward, and a review judging the implemented change unsound rather than defective exits immediately and is raised, whatever the count stands at — no number of revisions answers it. A bound stated without its exits spends rounds on a verdict revision cannot satisfy. The bound differs from the plan-review bound stated elsewhere in the fragment because the loops differ: a plan review revises prose against a moving argument, a code review revises code against a specification already fixed.

The first pull request SHALL carry the work. The fragment SHALL require the operator's confirmation that it merged and that the deploy it triggered is healthy. A session SHALL NOT infer a merge, a deploy, or a confirmed effect from a green pull request, an approval, or silence.

**A healthy deploy is not the change working.** The fragment SHALL place a further gate between the healthy deploy and the record: the change's intended effect is confirmed, in production in the direct form and on staging in the promoting form. A deploy's health reports that the new code is running and reports nothing about whether the behavior the change existed to produce is the behavior production now has, and those fail separately.

The fragment SHALL acknowledge that a session usually cannot make that observation itself — production is reached through interfaces a session does not hold — and SHALL therefore oblige it to **propose how the effect can be observed**: what to look at, what to do to provoke it, and what result would mean the change worked. The confirmation itself is the operator's, on the same terms as the merge.

**The gate SHALL state its own exemption, in advance and by class.** A change with no externally observable effect in production — a refactor, a dependency bump, an internal cleanup, a change to the repository's own conventions — cannot pass a gate that asks what to look at, and a gate stating no exemption forecloses it permanently: the record is never written, and the teardown gate below is conditioned on the record's pull request having merged, so the branch and working tree become unremovable. That is the accumulation this capability exists to prevent, reached in a class of change that did nothing wrong.

The exemption SHALL be: where the session can propose no observation that can actually be made — including one it proposed and that turns out not to be performable — it says so plainly and names the class, and the operator waives the gate. The waiver SHALL be recorded in the change's own artifacts, and it is what the record then rests on in place of a confirmed effect. It is a waiver stated in advance for a named class, not a gap discovered at the gate — the distinction `project-bootstrap` requires of every precondition this fragment states.

Saying so plainly is still owed. What the exemption removes is the stall, not the disclosure: a change whose effect nobody can observe is worth knowing about before it is archived as shipped.

Only once the effect is confirmed, **or the waiver recorded**, and in the promoting form the change is in production or `promote` is waived, SHALL the record be closed: the change's branch brought back to the freshly fetched trunk, its specification record committed there, and a pull request opened for it — the last of the change's pull requests, however many the work took. The record's subject is that the change shipped, so it cannot precede the shipping.

Where the deploy is not healthy, the fragment SHALL state that the change is not delivered and the record is not written, and that the remedy re-enters the sequence at its review gate rather than continuing past it — carrying its own pull request, as any work reaching the trunk does.

Where the deploy is healthy and the intended effect is absent, the fragment SHALL require the session to distinguish a defect in the change from the change having been the wrong change — which is a new proposal, not a correction — and SHALL state a terminal for each. A defect re-enters the sequence at its review gate. The wrong change does not, and its terminal SHALL be stated rather than left open.

**The wrong change is the confirmation gate's second waivable class**, named in advance on the same terms as the first: a change whose proposed observation was made, whose effect is absent, and which is **not to be corrected in place**. Being superseded by a new proposal is the typical case and SHALL NOT be a defining condition — a change judged wrong and reverted, or simply dropped, satisfies the class as fully, and a definition requiring a successor would leave it in neither class and back at the dead end this exemption exists to close.

The session says so plainly and names the class, the operator waives, the waiver is recorded in the change's own artifacts, and the record proceeds on it. **Where a successor is intended, the waiver SHALL name its backlog entry or the branch it was opened on.** This class is the one whose defining fact is a decision rather than an observation, so what it leaves behind is the only trace of why a change was archived as shipped while its effect was confirmed absent — and the specification the archive step writes to the trunk then describes behaviour production does not have. A reader meeting that specification later is owed the pointer.

Without that terminal the path dead-ends. The record cannot be written, because the effect is unconfirmed. The first waivable class does not reach it, because an observation *was* proposed and made — and improvising an exemption at the gate is what stating exemptions in advance forbids. The abandonment route does not reach it either, because that record must assert the work on the change's branch is not wanted, and this work is merged, deployed and running. A compliant session would stop with a branch and a working tree it can never remove, which is the accumulation this capability exists to prevent, reached down a path the fragment itself names.

The record is truthful on this route: the change shipped, and what it shipped did not do what was wanted. That is what the waiver records, and it is worth having on the trunk rather than lost with the session that discovered it.

**The deploy pipeline SHALL be the only path to production.** The fragment SHALL state that the command that deploys is never run locally against production, and that a change reaches production by the route its form states and by nothing else. Local credentials for the production environment, where they exist at all, are for reading — a plan, a status, a log — and not for applying.

Without this, every gate above is optional. A session that can deploy from its own machine can reach production without a pull request, without continuous integration, and without the review that the pull request exists to obtain; the whole sequence becomes a convention rather than a constraint, and nothing reports the one time it was skipped.

The archive step SHALL be stated as a role — closing the change's specification record — and SHALL name no command.

The fragment names agents in its bindings and no command-line tool anywhere: it does not say which command applies a change, or verifies one, or opens a pull request. Naming one at the archive step alone would present the project's specification tooling as though the workflow turned on that one invocation, when every other step leaves the tool to the project. The tooling is named among the fragment's assumptions instead, which is where a project reads what these rules presuppose.

The predecessor of this requirement permitted the opposite, and could: it governed a fragment `project-bootstrap` does not govern. Consolidation moves the obligation onto the file it does, so the permission is dropped rather than inherited.

#### Scenario: Delivery does not begin against unverified work

- **WHEN** a session reaches the delivery sequence and the change's verification has not been run against the branch head, or was run and failed
- **THEN** delivery does not begin, and no pull request is opened

#### Scenario: The code-review loop does not run unbounded

- **WHEN** a session has applied a review's findings, made substantial fixes, and re-reviewed three times without the review clearing
- **THEN** it reports where the loop stands and what is outstanding, and asks before dispatching a fourth

#### Scenario: A merge and its deploy are confirmed rather than assumed

- **WHEN** the first pull request has been opened and continuous integration has run
- **THEN** the session waits for the operator's confirmation of the merge and of the deploy's health before treating either as done

#### Scenario: A healthy deploy is not confirmation the change worked

- **WHEN** a change's work is merged and the deploy it triggers reports healthy
- **THEN** the record is not yet written, and the session proposes how the change's intended effect can be observed in production — what to look at, what provokes it, and what result would mean it worked — before asking for confirmation

#### Scenario: A change with no observable effect reaches its record

- **WHEN** a session reaches the confirmation gate for a refactor, dependency bump or internal cleanup and can identify no way for its effect to be observed in production
- **THEN** it says so plainly and names the class, the operator waives the gate, the waiver is recorded in the change's own artifacts, and the record proceeds on the waiver — rather than the change stalling with an unremovable branch and working tree

#### Scenario: The record follows the confirmed effect

- **WHEN** the change's intended effect is confirmed in production
- **THEN** the change's one branch is brought back to the freshly fetched trunk, the record is archived there in a commit of its own, and it is merged through the last of the change's pull requests

#### Scenario: A remedial cycle adds a pull request rather than reusing one

- **WHEN** a change's deploy is unhealthy, or its effect is absent through a defect in it, and the fix is made
- **THEN** the fix reaches the trunk through a pull request of its own, is reviewed, merged and deployed on the same terms as the original work, and the record still waits for a confirmed effect

#### Scenario: A failed deploy does not produce a record

- **WHEN** the pull request carrying a change's work is merged and the deploy it triggers is not healthy
- **THEN** the change is not treated as delivered, no record is written, and the fix re-enters the sequence at its review gate

#### Scenario: Production is not reached from a local machine

- **WHEN** a session holds credentials that would let it deploy directly to production
- **THEN** it does not, and the change reaches production by the route its form states, because a locally reachable production makes every gate above optional

#### Scenario: A deployed change that does not do what it was for

- **WHEN** the deploy is healthy and the change's intended effect is not present in production
- **THEN** the session distinguishes a defect in the change from the change having been the wrong change, and does not re-enter the fix sequence by default

#### Scenario: The wrong change reaches its record rather than stalling

- **WHEN** a change's effect is absent and the session and operator agree the change was the wrong change, to be superseded by a new proposal rather than corrected
- **THEN** the operator waives the confirmation gate, the waiver is recorded in the change's own artifacts naming that class, and the record proceeds — rather than the change stalling with a branch and working tree that no route can remove

### Requirement: A production-confirmation waiver is recorded

*Modified by `add-a-direct-workflow-variant`: in the promoting form the gate runs on staging, and a waiver of `promote` is recorded on the same terms as this one and is no further kind of record. Every scenario keeps its title.*

**A production-confirmation waiver SHALL be recorded in the change's own artifacts**, and it is the only record this requirement adds beyond the artifacts a change already carries.

The change's record is archived on the strength of the waiver, and the specification that archive writes to the trunk then describes behavior production does not have. The waiver is the only trace of why.

No further record SHALL be required, and the requirement SHALL say so, because the obvious candidates each look load-bearing and are not:

- **A review's verdict.** The rules already require the approved plan to be committed before tests are derived from it, so a committed plan is the marker that a verdict cleared it. A separate record states the same fact twice, and a session could write a false one as easily as it could commit an unapproved plan. What it would buy is the occasional re-dispatched review, which returns the same verdict.
- **An operator's confirmation** of a merge or a deploy. It gates nothing a later session cannot ask about again.
- **A dispatch in flight.** It matters only where a session ends mid-review.
- **A pull request.** The forge reports it.
- **An abandonment.** Required already, by the teardown gate below, as the condition of its own second route.

The residual cost of requiring none of these is a conditional pass whose `[MINOR]` fixes a later session cannot see are outstanding. That is bounded by those fixes being minor, and it is smaller than a record written on every change forever.

#### Scenario: A waived change carries the reason to the trunk

- **WHEN** a change's production-confirmation gate is waived and its record archived
- **THEN** the waiver is recorded in the change's artifacts, so a reader meeting the archived specification can find why it describes behavior production does not have

#### Scenario: A verdict is not recorded, and the commit stands for it

- **WHEN** a session resumes a change whose plan is committed and whose tests are derived
- **THEN** it implements, taking the commit as the marker that a verdict permitted proceeding, rather than looking for a verdict record or re-dispatching the review

#### Scenario: A confirmation nobody recorded is simply asked again

- **WHEN** a session ends after the operator confirmed a merge, and the next session needs to know
- **THEN** it asks, rather than the rules having required a record for it
