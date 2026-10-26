## MODIFIED Requirements

### Requirement: Cold runs are isolated when the agent can write

When the drafted agent's tool grant includes write, edit, or shell capability, the live half of the cold-run check SHALL run in an isolated git worktree, so that the run's path-directed writes land beside the repository the agent was authored in rather than in it.

The worktree SHALL be populated with the drafted agent before the run: the definition at `agents/<agent-name>.md`, together with any file its body references, SHALL be copied into it, and the real dispatch SHALL register the plugin from the worktree rather than from the authoring checkout. A worktree is created from a committed ref, while the agent under authoring is untracked at the moment the check runs — so a worktree left unpopulated does not contain the agent, and a dispatch by name finds nothing to dispatch. Without this step the preferred form of the check is unexecutable in exactly the case where isolation is required. The simulation fallback needs no such step, because it carries the body verbatim rather than loading it from disk.

Every path the dispatch payload carries that the agent may write to SHALL be rewritten to the worktree root before the run, and a payload naming a writable path outside the worktree SHALL abort the run rather than proceed. Without this the isolation is nominal: the standard requires absolute-path discipline, so the natural payload names the repository the agent was authored in, and an agent given that path writes to the original checkout from inside its worktree.

The abort SHALL bind writable paths only. A payload MAY name a path outside the worktree that the agent only reads, because a worktree contains writes and a rule wider than that makes the check unsatisfiable for any agent whose work legitimately reads a plugin cache, a home-directory configuration, or a sibling checkout.

The run SHALL additionally be launched with its working directory set to the worktree root, and the authoring checkout MUST NOT be made available to it as a writable directory. Rewriting the payload is not sufficient on its own: a body lacking the absolute-path discipline the system prompt standard requires resolves relative paths against the launch directory, so the very defect this check exists to detect is the one that escapes the isolation, and it escapes it before the check can report it. The mechanism differs by form — a real dispatch is started from inside the populated worktree, loads the plugin from it, and is given no additional writable directory naming the authoring checkout, while the simulation's worktree isolation already sets the subagent's working directory to the isolated root.

The standard SHALL state what the worktree does and does not contain. It redirects writes addressed by path; it is not a sandbox. An agent granted network or external-service tools reaches past it, and so does an agent granted shell capability — the same grant that makes isolation mandatory — which can address any path the process can reach. For both, the standard SHALL direct that the payload and the permission mode the run is launched under be reviewed before the run, rather than presenting the worktree as sufficient containment.

The worktree SHALL be removed once the run's outcome has been read from it, whether the run passed, failed or was aborted, and before the agent is reported complete. The obligation belongs to the check that created the worktree, because the development workflow's removal rules are keyed to a change and its pull requests, and a cold-run worktree has neither. A failing run's worktree SHALL be removed before the revised body is run, and the revised body SHALL run in a fresh worktree created and populated as for the first run, so that no write the previous run made is read as the revised body's. Removal SHALL be made from the authoring checkout, SHALL discard the worktree's contents rather than be refused because they are uncommitted, and SHALL delete any branch created with the worktree; a worktree the simulation's harness has already removed needs nothing further.

#### Scenario: Drafted agent is copied into the worktree before the run

- **WHEN** a write-capable agent is cold-run by real dispatch and the isolation worktree has just been created
- **THEN** the uncommitted definition is copied into the worktree and the plugin is loaded from there, because a worktree created from a committed ref does not contain a file that has never been committed

#### Scenario: Write-capable agent is cold-run in a worktree

- **WHEN** a drafted agent's `tools` grant includes `Write` or `Edit`
- **THEN** the live half runs in an isolated worktree rather than in the working repository

#### Scenario: Payload path is rewritten to the isolated root

- **WHEN** a dispatch contract names a repository path and the live half runs in a worktree
- **THEN** the payload carries the worktree's path rather than the authoring repository's, so the agent's writes land inside the isolation rather than beside it

#### Scenario: A body without absolute-path discipline cannot escape the isolation

- **WHEN** a write-capable agent's body names a relative output path and the live half runs in a worktree
- **THEN** the run's working directory is the worktree root, so the write lands inside the isolation and is then reported as the missing absolute-path discipline it is, rather than landing in the authoring checkout before the check reports anything

#### Scenario: Read-only path outside the worktree does not abort

- **WHEN** a write-capable agent's dispatch contract names a path it only reads, such as an installed plugin's directory, and that path lies outside the worktree
- **THEN** the run proceeds, because the abort binds writable paths and a wider rule would make the check unsatisfiable rather than protective

#### Scenario: Isolation limits are stated

- **WHEN** a drafted agent is granted a tool that reaches an external service, or a shell it could use to address a path outside the worktree
- **THEN** the standard directs that the payload and the run's permission mode be reviewed before the run, rather than treating the worktree as sufficient containment

#### Scenario: The worktree is removed once the outcome is read

- **WHEN** the live half of a write-capable agent's cold run has finished, passing or failing, and its outcome has been read from the worktree
- **THEN** the worktree is removed from the authoring checkout, with its contents discarded and any branch created with it deleted, before the agent is reported complete

#### Scenario: An aborted run's worktree is removed

- **WHEN** a run is aborted because its payload names a writable path outside the worktree
- **THEN** the worktree created for it is removed as a finished run's would be

#### Scenario: A revised body runs in a fresh worktree

- **WHEN** a cold run fails and the body is revised and run again
- **THEN** the failing run's worktree is removed and the revised body runs in a new worktree populated with the revised definition, rather than in one holding the previous run's writes
