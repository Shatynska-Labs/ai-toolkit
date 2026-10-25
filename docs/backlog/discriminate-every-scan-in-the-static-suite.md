---
kind: change
waits_on: []
design_with: [record-the-discriminator-obligation-in-the-manifest]
recorded_by: state-the-committed-artifact-situation
re_checked: 2026-10-18
---

The four `tests/cases/testing-skill-*.sh` cases each run their check over the real tree and over one fixture built to be rejected, but one fixture trips several scans at once, so most scans would survive deletion undetected, and two negatives are green vacuously. First settle in the `testing` floor whether a case or a scan is "the check" a discriminator must falsify, then either build each fixture to trip exactly one scan or add a fixture per scan.

- **Kind**: The floor question is a decision, and every consuming project meets it.
- **Design with**: `record-the-discriminator-obligation-in-the-manifest`, which concerns the same discriminator bound.
- **Recorded by**: `state-the-committed-artifact-situation`'s third code review; the accounting limit is stated in `tests/coverage.md`.
