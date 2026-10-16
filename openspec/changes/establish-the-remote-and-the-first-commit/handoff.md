# Handoff: establish the remote and the first commit

Identified while initializing `shatynska/basis` with `project-init`. The session that found it is not working this change; the session that takes it up writes the proposal.

## Why this change was identified

`rules/development-workflow.md` opens by assuming the adopting project already has "a remote, pull requests, continuous integration, a deploy triggered by merging to the trunk". Nothing in the setup path establishes the first two, and nothing says how the trunk first comes to exist:

- **The remote.** Neither `scripts/project-init`, `skills/project-init/SKILL.md`, `skills/project-foundation/SKILL.md` nor `rules/project-foundation.md` mentions a remote. In `basis` the operator created the GitHub repository by hand, and `git remote add` and the first push were done ad hoc, outside any skill. A project can finish `project-init` and most of foundation discovery with no remote, then reach the workflow's first `open pr` with nothing to open it against.
- **The first commit.** `skills/project-init/SKILL.md` step 4 offers an initial commit on the trunk. The fragment says "every change reaches the trunk through pull requests" and that even work too small to be a change "does not skip `ship`". A pull request needs a base branch, and an empty repository has none, so the first commit can only reach the trunk directly. That is correct, but it is stated nowhere: a session reading `AGENTS.md` after the fact sees a direct commit and push to `main` that the rules appear to forbid, and in `basis` the operator asked exactly that.

Two smaller observations from the same run, for the change to take or leave:

- The initial commit in `basis` covered more than what the tool created: the project's research documents were already in the directory, so "a commit covering what the tool just did" was really "a commit of everything present". The skill's wording assumes an empty directory.
- `project-init` does not replace a managed block of the same version, so a fix to the fragment that keeps its version reaches no project that already carries it (seen with `fix/backlog-naming`, PR #25). Not this change's problem to solve, but it bears on any wording this change adds to the fragment.

## What bears on it

- **`### Requirement: A one-time setup obligation does not belong in the fragment`** in `openspec/specs/session-workflow/spec.md`. Connecting a remote and making the first commit are discharged once at setup, so by that requirement they belong to the capability that owns project setup, not to the fragment. At most the fragment's opening assumption may need a pointer to where they are established, or an acknowledgement that the trunk's first commit precedes the pull-request rule.
- **`move-setup-gates-to-project-setup`** in `docs/backlog.md` records other one-time setup obligations without a home yet ("`project-foundation`'s checklist, `scripts/project-init`, or both"). This change may be folded into it, or land first and give it a home to extend. Decide which before proposing.
- **`name-initial-branch-main`** (branch and worktree exist, not yet merged) makes `project-init` start a created repository on `init.defaultBranch` or `main`. The first commit lands on that branch, so this change builds on it.
- `project-init` is deliberately deterministic and makes no judgment about the project. Creating a hosted repository needs a forge, an owner, a name and a visibility, which are judgments, so they are more likely `project-foundation`'s to elicit, or the operator's to do, than the script's.

## What it must not undo

- `project-init` stays deterministic: no prompts, no network calls it cannot report on, no forge-specific assumptions baked into the script.
- The initial commit stays offered, not made: the skill waits for the operator's confirmation.
- The fragment keeps the rule that every change reaches the trunk through pull requests. The exception for the first commit must be stated narrowly enough that it cannot be read as permission for any later direct push.
