# Contributing to Boardy

Thank you for helping improve Boardy. This guide describes the contributor contract for the 1.61.0
release candidate. The canonical architecture and compatibility constraints are documented in
[`AGENTS.md`](AGENTS.md), [`docs/API_STABILITY_1X.md`](docs/API_STABILITY_1X.md) and
[`docs/adr/0001-boardy-1x-main-actor.md`](docs/adr/0001-boardy-1x-main-actor.md).

## Before you start

- Search existing issues and pull requests before opening a new one.
- Use the bug template for reproducible defects and the feature template for proposals.
- Do not disclose suspected vulnerabilities in an issue or pull request. Follow
  [`SECURITY.md`](SECURITY.md) instead.
- Discuss a change before implementation if it affects a public declaration, observable executor or
  callback order, minimum platform, dependency, module boundary, deprecation or versioning policy.

## Local setup

The approved 1.61 candidate toolchain is Xcode 26.4.1 with an iPhone 17 simulator on iOS 26.4, and
the selected release floor is iOS 14. Until the candidate metadata and distribution tasks land,
these values describe the target contract rather than a published package. Local executable tests
for this candidate must not target or start another simulator or device.

Clone the repository and select the installed Xcode explicitly:

```sh
git clone https://github.com/congncif/boardy.git
cd boardy
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild -version
```

The version output must be `Xcode 26.4.1`. If that path selects another version, set
`DEVELOPER_DIR` to the actual Xcode 26.4.1 developer directory rather than changing the candidate
matrix.

Keep project-scoped build products, package checkouts and result bundles on the repository's drive:

```sh
mkdir -p .build-local/DerivedData
mkdir -p .build-local/SourcePackages
mkdir -p .build-local/Results
mkdir -p .build-local/tmp
```

These directories are ignored by Git. Do not move or symlink macOS-managed CoreSimulator state.

Install CocoaPods dependencies from the repository root when working on the workspace integration:

```sh
pod install --project-directory=Example
```

After the Boardy Swift package manifest lands, resolve SwiftPM dependencies into the
repository-local checkout directory:

```sh
xcodebuild -resolvePackageDependencies \
  -scheme Boardy \
  -clonedSourcePackagesDirPath .build-local/SourcePackages \
  -disablePackageRepositoryCache
```

With Xcode 26.4.1, do not pass an empty custom `-packageCachePath`; that configuration can produce
an empty package graph. Use `-clonedSourcePackagesDirPath` with
`-disablePackageRepositoryCache` as shown above.

## Target candidate verification matrix

This is the matrix required before candidate completion, not a claim that every row is already
available or a hosted/CI-enforced support matrix. Current execution evidence is tracked in the
[`living roadmap`](docs/BOARDY_LIVING_ROADMAP.md).

| Integration | Language mode | Destination | Expected signal |
|---|---|---|---|
| CocoaPods `Boardy_Tests` | Swift 5 with complete strict-concurrency checking | iPhone 17 / iOS 26.4 | All workspace tests pass |
| SwiftPM `Boardy` | Swift 5 with complete strict-concurrency checking | iPhone 17 / iOS 26.4 | All package tests pass; no Boardy-owned warning |
| SwiftPM `Boardy` | Swift 6 strict, warnings as errors | iPhone 17 / iOS 26.4 | All package tests pass |
| SwiftPM clean consumer | Swift 6 strict, warnings as errors | Generic iOS Simulator | Consumer imports and builds Boardy |
| Distribution metadata | CocoaPods Swift 5 / iOS 14+ | No executable destination | `pod lib lint` and package resolution pass |

Use this common Xcode configuration for repository-local outputs:

```sh
-derivedDataPath .build-local/DerivedData/BoardyContributor \
-clonedSourcePackagesDirPath .build-local/SourcePackages \
-disablePackageRepositoryCache
```

Executable test commands must use this destination and must not add parallel simulator
destinations:

```sh
-destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4' \
-parallel-testing-enabled NO \
-maximum-parallel-testing-workers 1 \
-maximum-concurrent-test-simulator-destinations 1
```

Canonical full commands and the release-only checks live in [`RELEASING.md`](RELEASING.md). Older
runtime/device rows, N-1 Xcode and hosted CI are intentionally deferred; do not describe local
success as G1 or production support.

## Development and testing expectations

Use full test-driven development for core orchestration behavior, activation flows, shared mutable
state and plugin initialization:

1. Add a focused regression test and observe the intended failure.
2. Make the smallest production change that corrects the behavior.
3. Run the focused test, then the relevant integration row.

Individual board implementations, controller logic and UI wiring may use test-after when the change
does not alter a core contract. Type declarations and configuration-only changes do not require a
synthetic test, but still require syntax, manifest or build validation appropriate to the file.

Tests for task and flow behavior must use deterministic synchronization. Do not add arbitrary sleeps
or execute a callback while a `Locked` value is held. Preserve the public 1.x compatibility rules,
including exactly-once terminal delivery and legacy `BlockTaskBoard` executor/order behavior.

If a change affects the public surface, regenerate the candidate API artifacts and verify them
against the immutable 1.60.1 baseline with the repository tools. A public declaration must not be
removed, renamed, made less visible or gain a new global-actor annotation or stricter generic
constraint in a 1.x minor release.

## Commits

Keep each commit to one complete semantic outcome. Use an imperative subject with a meaningful area,
for example:

```text
fix(flow): preserve nil combined outputs
build: add Boardy Swift package
docs: describe the 1.61 migration contract
```

Do not combine generated files, unrelated formatting or drive-by cleanup with the change. Never
commit `.build-local/`, `.codegraph/`, `.claude/worktrees/` or local credentials.

## ADR and RFC rule

An ADR or reviewed RFC is required before implementation when a proposal changes architecture,
public API or behavior, dependency direction, supported platform, concurrency/executor contract,
deprecation policy or release/versioning policy. Existing decisions live in [`docs/adr`](docs/adr).
Start a public design discussion through the feature-request intake; do not create a new normative
document path or silently override an accepted ADR in code.

Small internal fixes that preserve the approved contract need regression evidence and a clear pull
request explanation, but not a ceremonial ADR.

## Pull request checklist

Before requesting review, confirm that:

- [ ] The pull request explains the problem, scope and observable behavior.
- [ ] The diff contains no unrelated cleanup or generated local state.
- [ ] A regression test was observed red first for core behavior, and affected tests now pass.
- [ ] Only iPhone 17 / iOS 26.4 was used for executable candidate tests.
- [ ] SwiftPM and/or CocoaPods validation covers every integration method affected by the change.
- [ ] Public API and behavioral compatibility were assessed against the 1.x policy.
- [ ] Migration, compatibility, changelog and examples were updated when consumers are affected.
- [ ] An ADR/RFC is linked for architecture, public-contract, platform or release-policy changes.
- [ ] `git diff --check` passes and the final status contains only intended files.
- [ ] Security-sensitive details are absent from the public pull request.

Maintainers may request narrower commits or additional evidence. Test success does not grant commit,
tag, publication or release authority.
