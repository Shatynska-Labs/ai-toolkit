## Context

See `proposal.md` and `handoff.md` for why. Initialization has two halves: `scripts/project-init`, deterministic and asking nothing (`project-bootstrap`), and the `project-init` skill wrapping it, which already does one non-deterministic thing — offering an initial commit and waiting for confirmation. The workflow fragment is read by every session in an adopting project and is governed by `session-workflow` for content and `project-bootstrap` for delivery and version.

Both dependencies the handoff named have settled: `name-initial-branch-main` archived, so the first commit lands on `init.defaultBranch` or `main`; and `move-setup-gates-to-project-setup` was taken up by `require-code-quality-tooling-in-foundation`, which did not take the remote. This change therefore lands on its own.

## Goals / Non-Goals

**Goals:**

- A new project leaves initialization with its trunk on a remote, or with the missing remote stated, before foundation's first pull request needs it.
- The trunk's first direct commit is accounted for in the rules a later session reads, narrowly enough to permit nothing else.

**Non-Goals:**

- Creating a hosted repository, or any forge-specific step. Forge, owner, name and visibility stay the operator's.
- Retrofitting a remote into projects initialized before this change.
- Replacing a managed block of the same version (`update-managed-block`), which the handoff noted bears on any fragment wording; this change increments the version, so it does not depend on that.

## Decisions

**1. The remote step belongs to the wrapper, not the script.** The script is deterministic and asks nothing; connecting a remote needs the operator's URL and a network, and pushing is outward-facing. The wrapper already holds the one confirmation-gated step (the commit), and the push follows the commit directly. *Alternative: `project-foundation`*, recording forge, owner and visibility as a decision item the way it records branch protection. Rejected: foundation is itself a change that ships through a pull request, so the remote would have to be created partway through it, from inside a discovery conversation, and a project that skips foundation would never get one. *Alternative: a prerequisite only*, stated and left to the operator. Rejected: that is the current state, which produced the ad hoc setup in `basis`.

**2. The wrapper connects, it does not create.** It takes any URL git accepts, so it is forge-neutral without naming a forge. On a rejected push it stops rather than force-pushing or merging: a hosted repository created with a README has a history of its own, and choosing between discarding it and merging it is the operator's.

**3. The exception is stated in the fragment, defined by an observable.** A session reading `AGENTS.md` later sees a history beginning with a direct commit; only the fragment reaches that session. The commit is identified as "no commit exists before it", the same observable `project-bootstrap` already uses to tell a new project from an adoption, so no later commit can satisfy it. Naming a class ("the initialization commit") was rejected because a later session could place another commit in that class. This is not a setup obligation under `session-workflow`'s exclusion — it changes how a session reads every history, not something discharged once.

**4. Version 6 → 7.** `The fragment's version increments when its body changes` requires it. The operator first asked to keep 6 to avoid skew; that conflicts with an unamended requirement, so it was raised and the increment chosen. Every consuming project is reported one version behind when `project-init` is re-run there; the tool does not rewrite an existing block, so clearing the skew waits on `update-managed-block`.

**5. An adoption gets no direct commit.** Today the skill offers a commit in both modes, which in an adoption puts the tool's writes straight onto an existing trunk — exactly a direct push the exception must not license. The adoption ending instead says the writes reach the trunk through a pull request, and that a remote is needed first where none is configured. The wrapper reads the mode from the tool's report rather than re-deriving it, so it does not reimplement the tool's classification.

**6. The commit offer shows its real content.** The wrapper lists every staged path and every untracked path git does not exclude before asking, so a directory that already held the project's files (as `basis` did) is committed knowingly. A wholly untracked directory may be one entry, which keeps a large unignored tree from flooding the offer while still naming it. Declining the commit is not silent: it states that the first commit and a remote are both outstanding.

**6a. A failed push leaves `origin` configured, and says so.** The URL is added before the push, so a failed push leaves it. Removing it would hide what happened; the wrapper states it and leaves correcting it to the operator, since re-running the tool takes the adoption path and does not reach this step again.

**7. `rules/project-foundation.md` and `project-foundation` are unchanged.** The line "initialization runs before a remote, a stack or any check exists", in the fragment and in the spec's "Foundation decides branch protection and does not apply it", still holds of the script, and the branch-protection reasoning it supports needs checks that have reported, which a remote alone does not give.

## Risks / Trade-offs

- [Version skew in every consuming project] → the intended signal of the version marker; re-running `project-init` there reports it.
- [The wrapper's steps are prose a model follows, not code a test runs] → the derived tests can check the skill states each step; the behaviour itself is checked by a cold run of the skill against a scratch project with a local bare repository as the remote.
- [A project initialized before this change still has no remote] → out of scope; the fragment's assumption that a remote exists stands, and the operator adds one as before.

## Plan review

Round 1: `CONDITIONALLY APPROVED`, eight `[MINOR]` findings, all applied without a further round — the state a failed push leaves, a declined commit, staged paths in the listing, an adoption with no remote, the re-initialization claim, the skill's opening paragraph and how it learns the mode, the cold-run fixture, and the proposal's step numbering.

## Code review

Round 1: `FIX REQUIRED`. One `[MAJOR]` — the literal git commands in steps 4 and 5 ran in the current directory although step 2 passes through another target — and one `[MINOR]` — `git status --short` hides untracked paths under `status.showUntrackedFiles=no`. Both fixed by running every command as `git -C <target>` and listing with `--untracked-files=normal`; the fixes were mechanical, so no second round was dispatched.
