## Context

See `proposal.md` for why, and `docs/workstreams/see-a-projects-tasks.md`, Decisions, for the scope and form the operator fixed: one project, grouped by workstream, a bash tool writing one HTML file, with changes to tasks left to the `backlog` skill. The entry model is in `one-file-per-backlog-entry`'s `design.md`.

The status lookups exist today only as prose in `rules/workstreams.md`, reaching each project as a managed block, carried out by a session through the `backlog` skill. `scripts/project-init`, `project-update` and `backlog-migrate` set the form of a shipped tool: bash 3.2-compatible, ShellCheck-clean, self-locating, git environment cleared, a fixed report, exit codes 0, 1 and 2.

## Goals / Non-Goals

**Goals:**

- A page that answers the same as the `backlog` skill for any step, on a project whose workstreams block is current, and leaves no task out.
- Usable on commerce-ops's 18 workstreams, 101 entries and 838 pull requests in under ten seconds, as task 4.3 measures.

**Non-Goals:**

- A checker for malformed frontmatter. The board shows what it can read and warns on the rest; the workstream's open question stays open.
- Sorting, filtering or searching on the page. They need scripting, and the page is short enough to read and search in the browser.
- Showing done work beyond the steps of open workstreams.
- Adding the `summary` field to the rules, which is `give-tasks-a-summary`. The tool reads it where present and shows nothing where absent.
- Changing the `backlog` skill or the workstream rules.

## Decisions

### 1. Read a snapshot of the trunk

The tool runs `git fetch --quiet --no-prune origin`, overriding any `fetch.prune` setting, so that remote-only branches can be read for their stage (decision 7), then `git archive <trunk> docs/backlog docs/workstreams openspec/changes | tar -x` into a temporary directory removed on exit, and everything afterwards reads plain files. It is one git call rather than a `git show` per file, and no reader can reach the working tree by accident.

The trunk is `origin/HEAD`, else `origin/main`, else `origin/master`. Only the paths that exist are archived, since `git archive` fails on an absent one. A repository with no remote named `origin` reads `HEAD` instead.

*Alternative:* reading the working tree. Rejected: the board would differ by working tree, and the rules read status from the freshly fetched trunk.

### 2. Remote branches come from `git ls-remote`, not remote-tracking references

`git fetch` without `--prune` leaves references to deleted branches, which would read as in flight, and pruning changes more of the repository than the tool needs to. `git ls-remote --heads origin` answers what exists now and writes nothing. Local branches come from `git for-each-ref refs/heads`, excluding the trunk's own name.

### 3. One forge call per run

`gh pr list --state all --limit 5000 --json headRefName,state --template …` gives one tab-separated line per pull request, without `jq`. Looking up each name would take a call per task. commerce-ops has 838 pull requests, so the limit leaves room. Reaching it means an older merged fix could read as not merged, so the forge counts as partly read, as the spec states. On a repository past the limit the unchecked mark is permanent, which is honest and noisy; the limit is one constant if that happens.

Only a repository `gh` can resolve is reached. Any other forge reads as not reached, which the unchecked mark already covers.

### 4. Name sets, then one pass over tasks

The tool writes one sorted file per name set (archived, open, branches, open pull requests, merged pull requests, entries). Status is the ordered lookups over those sets in one function. Tasks are gathered as tab-separated records of placement, name and fields, then rendered.

The function's order is checked by one test case per lookup and per precedence pair, in a fixture repository with a stub `gh` on `PATH`. The prose in `rules/workstreams.md` remains the definition, and the two have no mechanical link: a change to the lookups has to change this function, so the tool's comment names `rules/workstreams.md` as its source. Parity with the skill on a real project is checked by task 4.3.

*Alternative:* a status mode the `backlog` skill calls, so one implementation serves both. It is the better end state, and it is left out because it changes the skill, whose next change is `group-tasks-into-workstreams`; recorded here rather than assumed.

### 5. Parsing is by line, and tolerant

- **Frontmatter:** `key: value` between the first two `---` lines, as `one-file-per-backlog-entry` fixed it. A flat form needs no YAML reader.
- **Steps:** lines matching a number, a dot and a backticked name after `**Steps**:`, up to the first line starting `- **` or `##`.
- **Proposal's workstream:** the first line starting `**Workstream**:`, taking its first backticked name. `none` or a line without one names no workstream.

A value that cannot be read never stops the run: the task is shown and warned on, because a board that refuses over one bad entry shows nothing. A numbered line in the Steps block that does not match warns too, and the report counts every warning.

### 6. Branches as tasks

A branch or open pull request becomes a task only where its name is one kebab-case word, is not the trunk's, and its status is in flight. Branch names here are change names, so the `/` that automation uses (`dependabot/...`, `renovate/...`) is the filter, with no list of tools to keep. Requiring in flight keeps out a merged branch left undeleted, which reads as done and is not work.

*Alternative:* a configurable ignore pattern. Rejected: nothing yet needs it, and the tool has no configuration.

### 7. The in-flight section is a view over the placed tasks

It is rendered from the same records as the groups, filtered by status, so it can show no status the groups do not. Links are in-page anchors, needing no script.

A task in flight is the one place the tool reads beyond the trunk, since a change lives on its branch until its first pull request merges: `git show <ref>:openspec/changes/<name>/proposal.md` and `tasks.md` for each such task, a handful of calls. The proposal gives its placement and the tasks its stage. This differs from the skill's trunk-only list of unplaced changes, deliberately: the session's status row reads the proposal on the branch too. Status stays read from the trunk, and remote branches' existence from `ls-remote`, so a stale remote-tracking reference can affect only a stage, never whether a task is in flight.

The workflow's states such as `plan:reviewing` are not in the repository, so the tool shows the nearest state `session-workflow` names, which that specification tolerates being one step off. `plan:drafting` therefore also covers a plan under review, and a fix branch, which skips `plan`, reads `plan:exploring`. *Alternative:* recording the stage in a file. Rejected: status is derived and never stored.

### 8. Layout, agreed from a prototype

`prototype/` in this change holds the generator run on this repository and commerce-ops, and the page the operator accepted: status, task, last commit and details columns, active workstreams first, the rest in one collapsed row. Run on commerce-ops it took about nine seconds with its 838 pull requests. It is a reference for `apply`, not code to port: it is Python, and it is not shipped.

The last commit comes from one `git log --name-only` over the trunk, mapped to names, and one `for-each-ref`, so its cost does not grow with the tasks. A branch at the trunk's tip counts as having no commit of its own, or a new branch would read as just touched.

### 9. HTML from a heredoc, collapsing with `<details>`

Inline CSS with a light and dark theme through `prefers-color-scheme`, no script. `<details>` gives the collapsed group and entry bodies without any scripting. Escaping is one `sed` for `&`, `<`, `>` and `"`, every value passing through it.

Status is shown as a word as well as a colour.

### 10. The default output is in the temporary directory

`${TMPDIR:-/tmp}/task-board-<project>.html`, where the project is the name of the directory holding `git rev-parse --git-common-dir`, so `.worktrees/x` gives the same page as the main tree. Two projects of one directory name share the file; `--output` separates them. A path in the project would show in `git status` or require an ignore entry in every project. `--output` serves anyone who wants it elsewhere. The file is overwritten on each run, written first beside its target and then moved, so an open page is never half written.

## Risks / Trade-offs

- **The bash status function and the skill's prose can drift.** → The cases fix the current order, and decision 4 leaves one implementation as the later path.
- **Bash and awk producing HTML is awkward code.** → The page is deliberately plain; if editing from the page is wanted, the workstream's Decision 5 expects a rewrite of this layer.
- **A project with an older workstreams block can differ from the tool, since the skill follows the project's text and the tool this library's.** → Accepted: `scripts/project-update` brings the block current, and the board states no version.
- **A long-lived branch with no `/`, such as `develop`, reads as a task.** → It leads the page as a permanent line in flight. Accepted until a project needs otherwise; `main` and `master` are excluded by name, so a repository with no `origin` does not list its trunk.
- **A snapshot goes stale.** → The page states when it was written and from which trunk commit.
- **A task-board run on a slow remote waits on fetch and `gh`.** → Both run with git's and `gh`'s own failure paths; no timeout is added, since `timeout` is not on macOS by default.

## Migration Plan

None: a new tool with nothing depending on it. Rollback is reverting the merge.
