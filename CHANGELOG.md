# Changelog

All notable changes to Boardy are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Boardy follows the project versioning policy in
[`docs/API_STABILITY_1X.md`](docs/API_STABILITY_1X.md): a minimum-platform increase may ship in a
minor release, while source/API removals require a separately approved major update. This policy is
not strict Semantic Versioning.

## [Unreleased]

No changes have been assigned beyond the 1.62.0 release.

## [1.62.0] - 2026-08-02

A correctness and hygiene release. No public declaration was removed, no new
deprecation was introduced, and no release-build behavior changed for callers who
were not already hitting one of the defects below.

Verified by hosted CI on every commit: build, 73 tests, `pod lib lint`, and
public-API verification against the 1.61.0 baseline.

### Fixed

- `TaskBoard` and `ResultTaskBoard` ran their executor more than once under
  concurrent activation. Claiming the activation slot read the counter and wrote
  it back as two separate locked operations, so simultaneous callers all saw an
  idle board. Measured before the fix with 100 concurrent activations: the
  executor ran 4 times on `TaskBoard` and 5 on `ResultTaskBoard`.
- A duplicate executor completion drove `TaskBoard`'s counter below zero and left
  the board permanently reporting `isProcessing`. Releasing the slot is now
  idempotent, so the second completion is a no-op — matching the terminal-event
  behavior `BlockTaskBoard` already guaranteed.
- `Motherboard.flows` was a plain array read during flow dispatch while
  registration appended to it. Because boards deliberately send output from
  whichever executor their work finished on, that read is not a main-thread-only
  path; the storage is now locked and readers take a snapshot. No caller
  obligation is added.
- `BoardProducer` scanned its registration sets linearly on every lookup even
  though `BoardRegistration` hashes on identifier alone. Lookups are now O(1).

### Added

- `registerBoard(_:replacingExisting:factory:)` on `BoardDynamicProducer`. The two
  built-in producers disagree on duplicate registration — `BoardProducer` keeps the
  first factory, `BoardContainer` keeps the last — and always have. Both defaults
  are preserved; this states the intent explicitly and means the same thing on
  either. The protocol requirement ships with a default implementation so existing
  external conformers keep compiling.
- DEBUG diagnostics for paths that previously dropped work silently: duplicate
  board registration, activations discarded by a barrier whose owner was released,
  activations a barrier board could not interpret, and data reaching
  `ChainDataHandler` with no matching handler and no fallback.

### Changed

- The deprecation on the zero-width-space `GatewayBarrierRegistration.exempt`
  spelling now explains the invisible character. `renamed:` offered a fix-it that
  rendered identically to the problem, which made the warning unactionable.
- `ContinuousBoard` carries documentation and a once-per-process DEBUG note
  pointing at `ModernContinuableBoard`. It is deliberately **not** deprecated:
  `init(identifier:motherboard:)` accepts a caller-assembled motherboard and the
  modern type has no equivalent, so migrating changes construction rather than the
  type name.

### Removed

- Internal `Atomic` property wrapper and `SafeArray`, neither of which had a
  correct or a live use left.
- 4.7 MB of generated API artifacts from `docs/api/`. The digester graphs are now
  derived from the committed `.swiftinterface` files by `tools/derive-api-graph.sh`
  during CI, and the declaration inventory and verification report are published as
  run artifacts. One deleted graph was actively misleading: it was labelled
  authoritative while reporting two inherited constructors as removed and fourteen
  phantom type changes.
- Process documents (plan transcripts, living roadmap, governance records) from the
  shipped repository. Their durable content moved into `docs/COMPATIBILITY.md`,
  `SECURITY.md` and `.github/CODEOWNERS`.

## [1.61.0] - 2026-08-02

Boardy 1.61.0 is published from annotated tag `1.61.0` at the merged PR #10 commit. It remains
pre-G1: hosted CI passed on Xcode 26.4.1 / `macos-26`, but older runtimes, other devices and N-1
Xcode remain unverified; organization production support is not claimed. CocoaPods metadata and
Example lock were verified, but CocoaPods trunk publication is not claimed. The iOS 14 floor,
compatibility boundary and migration path are documented in
[`docs/MIGRATING_TO_1.61.md`](docs/MIGRATING_TO_1.61.md) and
[`docs/COMPATIBILITY.md`](docs/COMPATIBILITY.md).

No GitHub Release object was published for tag `1.61.0`. The annotated tag is the release artifact.

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
