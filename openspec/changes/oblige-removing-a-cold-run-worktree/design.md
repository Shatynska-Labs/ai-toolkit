## Context

The isolation requirement in `agent-authoring` creates a worktree in two ways. A real dispatch runs `git worktree add <wt> HEAD`, which checks out a detached `HEAD` and creates no branch, then copies the drafted definition in. The simulation uses the Agent tool's `isolation: "worktree"`, whose harness removes the worktree itself when the run left it unchanged and leaves it, with the branch it created, when the run wrote to it. Either way the worktree ends up holding untracked files: the copied definition, the run's writes, or both.

The development workflow removes a change's working tree once the change's pull requests have merged. A cold-run worktree has no change and no pull request, so that rule never reaches it.

## Goals / Non-Goals

**Goals:** every cold-run worktree has a stated point at which it is removed, and a stated party who removes it.

**Non-Goals:**
- Changing the workflow fragment's removal rules.
- Keeping a run's writes as a record. The check records its fixtures, not its outcomes (*Check fixtures are recorded; outcomes are not*), and the outcome is read before removal.
- Removing worktrees left by runs made before this change.

## Decisions

**1. The cold-run check owns the removal.** The entry offered two places: `agent-authoring`, or something else named to take the obligation. The check creates the worktree and is the only thing that knows when it is done with it, so the obligation sits with the requirement that creates it. Extending the workflow's rule to working trees with no change was rejected: its conditions are merges and unpushed commits, none of which a cold-run worktree has, so it would need a second rule inside the first.

**2. Removed once its outcome is read, whatever the outcome.** The run's writes are evidence: a relative-path write that lands in the worktree is how the check reports missing absolute-path discipline. So the worktree is read first and removed after, on a pass, a failure or an abort. Removal comes before the agent is reported complete, because completion is the last point at which the authoring session is still holding the check.

**3. A failing run's worktree does not carry over to the revised run.** The failure-to-revision mapping revises the body and runs the check again. A reused worktree would hold the previous run's writes and an outdated copy of the definition, so a write the revised body never made could be read as its own. The revised body runs in a fresh worktree, created and populated as for the first run.

**4. Removal is forced, from the authoring checkout, and takes the branch with it.** The worktree is dirty by construction, so `git worktree remove` without `--force` refuses it; forcing it is correct because nothing in it is to be kept. It is removed from the authoring checkout, as the workflow removes a working tree from the main one rather than from inside the tree being removed. A real dispatch's worktree has no branch; the simulation harness's has one, which is deleted with it. A worktree the harness already removed needs nothing further.

## Risks / Trade-offs

- **Forced removal discards anything put in the worktree by hand.** Accepted: the worktree is the check's scratch space, and the definition under authoring lives in the authoring checkout, not in it.
- **The obligation binds the authoring session, and nothing enforces it.** A session that stops mid-check still leaves a worktree behind. Tooling that sweeps stale worktrees would close that, and is not in scope.
