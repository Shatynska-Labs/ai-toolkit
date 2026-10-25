---
priority: normal
kind: change
waits_on: []
design_with: []
workstream: none
recorded_by: one-file-per-backlog-entry
re_checked: 2026-10-25
---

`.claude-plugin/plugin.json` has carried `version: 0.2.0` since August, and the installed plugin is cached by that version, so `/plugin update` finds nothing new and every merge since then never reached an installed copy: confirming `one-file-per-backlog-entry` needed an uninstall and a reinstall. Decide when the version rises (every merge that changes `skills/`, `agents/`, `rules/` or `scripts/`, or only a release), state it in `AGENTS.md`, and enforce it with a test that fails where such a diff leaves the version unchanged.

- **Kind**: it needs the operator's decision on when the version rises, and owes a `toolkit-structure` delta to *Repository is an installable plugin*.
- **Recorded by**: `one-file-per-backlog-entry`, whose confirmation found the August copy installed; recorded rather than folded in, since it touches files that change does not edit and needs a decision.
