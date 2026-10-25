---
kind: fix
waits_on: []
design_with: []
recorded_by: add-change-code-reviewer
re_checked: 2026-10-18
---

`tests/cases/workflow-fragment-build-binding-verdict-acts.sh` passes the binding to `awk -v`, which interprets backslash escapes, and its `has` helper matches act words as case-insensitive substrings, so "nonstop" satisfies "stop". Pass the text through `ENVIRON` or stdin, and match whole words.

- **Kind**: A test-only edit with no delta and no decision.
- **Recorded by**: `add-change-code-reviewer`'s code review, rounds 1 and 2; not applied there because a separate test author derived the case.
