# Contributing to Boardy

Thank you for helping improve Boardy. This guide describes the contributor contract for the 1.61.0
release candidate. The canonical architecture and compatibility constraints are documented in
[`AGENTS.md`](AGENTS.md) and [`docs/API_STABILITY_1X.md`](docs/API_STABILITY_1X.md).
The [actor-isolation ADR](docs/adr/0001-boardy-1x-main-actor.md) is deferred decision history, not
an implementation contract for 1.61.0.

## Before you start

- Search existing issues and pull requests before opening a new one.
- Use the bug template for reproducible defects and the feature template for proposals.
- Do not disclose suspected vulnerabilities in an issue or pull request. Follow
  [`SECURITY.md`](SECURITY.md) instead.
- Discuss a change before implementation if it affects a public declaration, observable executor or
  callback order, minimum platform, dependency, module boundary, deprecation or versioning policy.

## Local setup

The approved 1.61 candidate toolchain is Xcode 26.4.1 with the fixed iPhone 17 simulator
(`714C9786-1327-41DF-A093-73359C82E0C2`) on the installed iOS 26.4.x runtime, and the selected
release floor is iOS 14. The current review cycle is SPM-first; CocoaPods test/lint is intentionally
deferred. Local executable tests must not target or start another simulator or device.

Clone the repository and confirm the installed Xcode selected by `xcode-select`:

```sh
git clone https://github.com/congncif/boardy.git
cd boardy
xcode-select -p
xcodebuild -version
```

The version output must be `Xcode 26.4.1`. `DEVELOPER_DIR` is optional and is only needed when
multiple Xcode installations are present; this repository uses the default `xcode-select` path
when it is unset.

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
available or a hosted/CI-enforced support matrix. Current execution evidence is the CI run for the
commit under review ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)); the recorded boundary
is [`docs/COMPATIBILITY.md`](docs/COMPATIBILITY.md).

| Integration | Language mode | Destination | Expected signal |
|---|---|---|---|
| SwiftPM `Boardy` | Swift 5 language mode | iPhone 17 / iOS 26.4 | All package tests pass |
| SwiftPM clean consumer | Swift 5 language mode | Generic iOS Simulator | Consumer imports and builds Boardy |
| Distribution metadata | SwiftPM Swift 5 / iOS 14+ | No executable destination | Package resolution and metadata checks pass |

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

Canonical SPM commands and the deferred release-only checks live in [`RELEASING.md`](RELEASING.md).
Swift 6 language mode, MainActor isolation, older runtime/device rows, N-1 Xcode and hosted CI are
intentionally deferred; do not describe local success as G1 or production support.

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
