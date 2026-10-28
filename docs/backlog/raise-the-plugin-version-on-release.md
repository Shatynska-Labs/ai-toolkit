---
priority: normal
kind: change
waits_on: []
design_with: []
workstream: keep-projects-on-the-current-workflow
recorded_by: one-file-per-backlog-entry
re_checked: 2026-10-28
---

`.claude-plugin/plugin.json` carried `version: 0.2.0` from August until `list-what-a-project-receives` set it to `1.0.0`, and nothing raises it after that. The installed plugin is cached by that version, so `/plugin update` finds nothing new after a merge that leaves it unchanged: confirming `one-file-per-backlog-entry` needed an uninstall and a reinstall. Decide when the version rises (every merge that changes `skills/`, `agents/`, `rules/` or `scripts/`, or only a release), state it in `AGENTS.md`, and enforce it with a test that fails where such a diff leaves the version unchanged.

- **Kind**: it needs the operator's decision on when the version rises, and owes a `toolkit-structure` delta to *Repository is an installable plugin*.
- **Recorded by**: `one-file-per-backlog-entry`, whose confirmation found the August copy installed; recorded rather than folded in, since it touches files that change does not edit and needs a decision.
