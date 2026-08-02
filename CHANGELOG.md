# Changelog

All notable changes to Boardy are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Boardy follows the project versioning policy in
[`docs/API_STABILITY_1X.md`](docs/API_STABILITY_1X.md): a minimum-platform increase may ship in a
minor release, while source/API removals require a separately approved major update. This policy is
not strict Semantic Versioning.

## [Unreleased]

No changes have been assigned beyond the 1.61.0 candidate.

## [1.61.0] - Unreleased release candidate

Boardy 1.61.0 is a maintainer-review candidate and has not passed the hosted-CI/G1
organization-support gate. It is not tagged or published. Verification is limited to Xcode
26.4.1 on an iPhone 17 simulator running iOS 26.4; older runtimes, other devices, N-1 Xcode and
hosted CI remain deferred. SwiftPM is the current verification path; CocoaPods test/lint and
publication remain deferred. The current evidence boundary is recorded in the
[`living roadmap`](docs/BOARDY_LIVING_ROADMAP.md).

### Added

- An immutable Boardy 1.60.1 public-API baseline and a self-verifying compatibility check.
- API-stability, ownership, consumer-inventory, contribution, conduct, support, security and
  release-governance documentation for the 1.x line.
- Structured GitHub issue forms and a pull-request checklist for compatibility-aware intake.

### Changed

- Selected iOS 14 as the 1.61 candidate floor under the project-specific minor-version policy;
  SwiftPM metadata, a local consumer smoke package and migration documentation are prepared for
  maintainer review.
- Recorded preservation of the legacy `BlockTaskBoard` executor and complete terminal-event order
  as the approved 1.x compatibility branch.
- Deferred MainActor, framework-wide/public Sendable migration and Swift 6 language-mode readiness
  to a separate follow-up; 1.61.0 preserves caller-controlled synchronous behavior and adds no
  release main-thread precondition or queue hop. DEBUG builds assert Motherboard storage mutations
  occur on the main thread. Narrow lock-backed conformances remain audited internals.
- Documented `PluginLauncher` URL results as matched candidates and introduced the clean
  `GatewayBarrierRegistration.exempt` spelling while retaining the deprecated legacy spelling.
- Pinned template inputs to immutable revisions and removed the permission-bypassing helper script.

### Fixed

- Made attachment, array, dictionary and activation-barrier compound operations atomic, including
  reentrant insertion and failed barrier-installation cleanup.
- Corrected activation of all matching boards when optional input is absent.
- Preserved `nil` values through `CombinedFlow` and prevented handlers from running while storage is
  locked.
- Made `BlockTaskBoard` terminal delivery exactly once across success, failure, cancellation,
  cancel-before-canceler-install and late-completion paths.
- Preserved per-activation identity for `.unidentified` activation barriers so distinct application-
  scoped requests do not coalesce behind one barrier cycle.
- Added a valid popover anchor for action-sheet presentation on iPad-class presentation contexts.
- Preserved module-plugin lifetime and lazy component behavior during plugin composition.

### Security

- No vulnerability fix, security advisory or CVE is claimed for this candidate.
- Added a private vulnerability-reporting policy. Do not disclose a suspected vulnerability in a
  public issue; follow [`SECURITY.md`](SECURITY.md).

## Earlier releases

Releases before 1.61.0 did not maintain complete public release notes. Their Git tags and commit
history remain the historical record; entries are not reconstructed here without auditable source
material.
