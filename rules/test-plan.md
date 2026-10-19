---
kind: standing-constraint
version: 3
---

# Read the test plan before implementing

If an OpenSpec change has been passed to `change-test-writer`, its change root carries a `test-plan.md` alongside `proposal.md`, `design.md`, and `tasks.md`. Read it before implementing.

`test-plan.md` is not an artifact the OpenSpec schema defines, so it is not among the files `openspec instructions apply` surfaces automatically — finding it takes a deliberate look at the change root, not a step the tooling takes for you.

It names, per task, which tests must go from failing to passing, which existing tests are now obsolete and why (never edited or deleted — that judgment is yours), and any project questions the agent couldn't resolve on its own.

Its **Missing shared arrangement** section lists the builders, fixtures, fakes and stubs the agent declared inside its own test files because the project's shared test arrangement lacked them. Deal with each entry in the same change: promote it into the shared test arrangement and move the derived tests onto it, or keep it local with a recorded reason. Write the disposition — promoted, or kept and why — against the entry in that section; it is where review looks for it. Moving derived tests onto promoted arrangement changes only where they take their arrangement from, never what they assert.
