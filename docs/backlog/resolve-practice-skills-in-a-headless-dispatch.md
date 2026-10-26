---
kind: change
waits_on: []
design_with: []
recorded_by: "run-the-remaining-arrangement-cold-runs, a backlog fix with no change of its own"
re_checked: 2026-10-26
---

In headless `claude -p` dispatches of the installed plugin's `ai-toolkit:change-code-reviewer`, the agent's `Skill` calls for `ai-toolkit:bash` and `ai-toolkit:testing` failed with "Unknown skill", and it fell back to the unprefixed `bash` and `testing` — copies in `~/.claude/skills/`, not the plugin's. `ai-toolkit:change-test-writer` loaded the unprefixed names directly. The agents themselves resolved under `ai-toolkit:`. Where no such copies exist, the bodies' qualified skill names may resolve to nothing. Establish why plugin skills are not reachable by their qualified names in that dispatch, and whether the bodies, the cold-run recipes or the installation need to change.

- **Kind**: The cause is not established, so neither the delta nor the decision it owes is known yet.
- **Recorded by**: Observed in the arrangement-variant cold runs, whose criteria it does not bear on.
