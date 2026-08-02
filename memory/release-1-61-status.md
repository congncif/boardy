---
name: release-1-61-status
description: Boardy 1.61.0 release status and evidence boundary
metadata:
  type: project
---

Boardy 1.61.0 merged through PR #10 at `eba3b311b28066c604dd878f92df799d99ed06f0`, with annotated remote tag `1.61.0` peeling to that merge SHA. Hosted CI run `30728752451` passed on `macos-26` with Xcode 26.4.1, including build/test and CocoaPods lint. CocoaPods trunk publication, signed release, SBOM/provenance, older runtime/device evidence, N-1 Xcode evidence, and organization production support remain deferred. GitHub Release API returned 404 for tag `1.61.0` on 2026-08-02; do not claim release-object publication until verified.

**Why:** Release and plan status must distinguish annotated tag, hosted CI, and GitHub Release object.
**How to apply:** Keep `CHANGELOG.md`, `RELEASING.md`, `docs/BOARDY_LIVING_ROADMAP.md`, and Option A plan aligned with verified remote evidence.
