# Releasing Boardy

This document is the maintainer checklist for Boardy 1.x. It separates candidate preparation,
production release and CocoaPods publication because each has a different gate and authority.

Boardy 1.61.0 is currently a release candidate. Local success is not G1: production publication
remains blocked until the later hosted-CI plan is approved and green, the backup owner's GitHub
identity/release access is confirmed, consumer dispositions are approved and all final gates pass.
The technical owner, backup owner and private security contact are recorded in
[`docs/governance/OWNERSHIP.md`](docs/governance/OWNERSHIP.md). The current execution is
Git/GitHub-only and does not authorize CocoaPods trunk publication.

## Versioning policy

Boardy uses a project-specific 1.x policy rather than claiming strict Semantic Versioning:

- A minimum-platform increase may ship in a minor release when its consumer impact and migration
  path are documented. Boardy 1.61.0 therefore raises the floor from iOS 12 to iOS 14.
- Major versions are reserved for a separately approved big update.
- Removing or renaming a public declaration, making it less visible, tightening generic or
  `Sendable` constraints, changing synchronous/throwing semantics, or adding a global actor to an
  existing declaration still requires a separately approved major-update plan.
- Observable executor, ordering, callback and main-thread behavior is part of the compatibility
  contract even when it is absent from a Swift signature.
- Deprecation is not removal permission. A deprecated 1.x declaration remains available through the
  documented major migration window.

See [`docs/API_STABILITY_1X.md`](docs/API_STABILITY_1X.md) for the normative contract.

## 1. Confirm authority and gates

Before creating a production tag or GitHub Release:

- [ ] The technical owner and backup owner are explicitly designated in
      [`docs/governance/OWNERSHIP.md`](docs/governance/OWNERSHIP.md).
- [ ] A private security reporting contact/channel exists in `SECURITY.md`.
- [ ] `CODEOWNERS` contains confirmed GitHub handles; no handle was inferred from repository access.
- [ ] The compatibility matrix and consumer dispositions are owner-approved.
- [ ] The hosted-CI plan is approved, green on the exact candidate SHA and satisfies G1.
- [ ] The final joined consistency review and its single corrective batch are complete.
- [ ] The release actor has explicit authority for commit, push, signed tag and GitHub Release.
- [ ] Any CocoaPods publication, if planned later, has separate explicit authority.

If any item is missing, continue candidate work but do not claim production support or create the
production release.

## 2. Set the release contract

For 1.61.0, confirm all normative locations agree:

- [ ] `Boardy.podspec` has version `1.61.0`, Swift `5.0` and iOS `14.0`.
- [ ] `Package.swift` uses Swift tools 5.9, iOS 14 and the `Boardy` umbrella product.
- [ ] SwiftPM resolves `UIComposableCore` from the exact public UIComposable `1.1.0` tag.
- [ ] The Example Podfile/project and generated Pods use iOS 14.
- [ ] `README.md`, `CHANGELOG.md`, `docs/COMPATIBILITY.md` and
      `docs/MIGRATING_TO_1.61.md` exist and describe the same version, platform and toolchain.
- [ ] The changelog still labels 1.61.0 as a candidate until the release date is known.

Do not add a branch dependency or move an existing public tag to make resolution pass.

## 3. Resolve dependencies reproducibly

Use Xcode 26.4.1 explicitly and keep project-scoped state under the ignored `.build-local`
directory on the repository drive:

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild -version
mkdir -p .build-local/DerivedData
mkdir -p .build-local/SourcePackages
mkdir -p .build-local/Results
pod update UIComposable --project-directory=Example
pod install --project-directory=Example
xcodebuild -resolvePackageDependencies \
  -scheme Boardy \
  -clonedSourcePackagesDirPath .build-local/SourcePackages \
  -disablePackageRepositoryCache
```

The version output must be `Xcode 26.4.1`. Do not use an empty custom `-packageCachePath` with this
toolchain. Record the resolved UIComposable versions and verify that no mutable branch or local path
remains in the release manifest or lock state.

## 4. Run the local candidate matrix

Every executable test in the current execution must target only iPhone 17 / iOS 26.4. Use unique
DerivedData and result paths under `.build-local`, disable parallel simulator destinations and do not
start another runtime or device.

Run these rows with `-clonedSourcePackagesDirPath .build-local/SourcePackages` and
`-disablePackageRepositoryCache`:

1. CocoaPods `Boardy_Tests` in Swift 5 with complete strict-concurrency checking.
2. SwiftPM `Boardy` tests in Swift 5 with complete strict-concurrency checking and no Boardy-owned
   warning.
3. SwiftPM `Boardy` tests in Swift 6 strict mode with warnings as errors.
4. Generic iOS Simulator build with `IPHONEOS_DEPLOYMENT_TARGET=14.0`.
5. `Examples/SwiftPMSmoke` generic consumer build in Swift 6 strict mode with warnings as errors.
6. UIComposable 1.1.0 package tests in Swift 5 and Swift 6 strict modes.

Then validate CocoaPods metadata without publishing:

```sh
pod lib lint Boardy.podspec --verbose
git diff --check
git status --short
```

Retain Xcode version, destination, logs and result bundles under `.build-local/Results`. Local results
are evidence for the candidate only; older-runtime/device, N-1 Xcode and hosted results must not be
inferred from them.

## 5. Verify public API and documentation

- [ ] Capture final `docs/api/Boardy-1.61.0.swiftinterface` and
      `docs/api/Boardy-1.61.0.api.json` from the final resolved CocoaPods lock state.
- [ ] Run `tools/verify-public-api.sh` against the immutable 1.60.1 interface and API graph.
- [ ] Confirm zero removed/renamed declarations and no global-actor annotation added to an existing
      declaration.
- [ ] Generate `docs/api/PUBLIC_API_1_61.md` and run
      `tools/render-api-inventory.rb verify` so every eligible declaration is classified exactly
      once.
- [ ] Confirm migration guidance covers the iOS floor, MainActor compatibility boundary,
      callback executors/order, `BlockTaskBoard`, `GatewayBarrierRegistration.exempt`, URL matching
      and CocoaPods-to-SwiftPM migration.
- [ ] Confirm no document describes the typed façade over `Any?` as end-to-end typed transport.

Any source, package dependency or public-declaration correction invalidates the corresponding API
capture. Recapture and rerun the affected verification before selecting the release SHA.

## 6. Select and review the candidate SHA

- [ ] Commit complete semantic changes and push the candidate branch using the separately granted
      Git authority.
- [ ] Confirm the working tree is clean, including untracked files.
- [ ] Record the exact candidate SHA.
- [ ] Run the one final independent consistency review over the complete branch diff.
- [ ] Apply accepted in-scope P0/P1 findings in one corrective batch and rerun only affected
      executable/API checks.
- [ ] Record the final reviewed SHA and verify hosted G1 checks ran against that exact SHA.

Do not tag an earlier green commit after a corrective change. Do not replace hosted final-SHA
evidence with local logs.

## 7. Finalize changelog and create the GitHub release

Only after all production gates pass:

1. Replace `Release candidate` in the 1.61.0 changelog heading with the actual release date.
2. Verify release notes prominently disclose the iOS 14 floor, migration guide, compatibility
   evidence boundary, executor contract and absence of CocoaPods publication.
3. Commit the release metadata and rerun required final-SHA checks if the protected workflow treats
   that commit as a new candidate.
4. Create a cryptographically signed annotated tag at the reviewed release SHA and verify it locally:

   ```sh
   git tag -s 1.61.0 <reviewed-release-sha> -m 'Boardy 1.61.0'
   git tag -v 1.61.0
   ```

5. Push the tag without force, verify the remote peeled tag equals the reviewed SHA, then create the
   GitHub Release from that exact tag.
6. Verify the public release URL and attached release notes. Never move or replace a published tag.

If signing is unavailable or an existing tag points elsewhere, stop. Do not downgrade to a
lightweight tag, force-push or silently create a release from another SHA.

## 8. CocoaPods transition checklist

CocoaPods trunk publication is excluded from the current execution. Do not run `pod trunk push`,
register a trunk session or describe the candidate as available from CocoaPods 1.61.0.

For a later, separately approved CocoaPods publication:

- [ ] Confirm UIComposable dependency availability and the exact Boardy pod constraint.
- [ ] Migrate or version-cap every known consumer below iOS 14 in
      [`docs/governance/CONSUMER_INVENTORY.md`](docs/governance/CONSUMER_INVENTORY.md).
- [ ] Re-resolve the Example lock, rerun the CocoaPods test row and pass `pod lib lint` from a clean
      tagged checkout.
- [ ] Confirm the podspec source tag is the signed public `1.61.0` tag and its peeled SHA matches the
      reviewed release commit.
- [ ] Obtain explicit CocoaPods publication authority and record the release actor.
- [ ] Publish through the approved CocoaPods process, then verify the public podspec and install it
      in a disposable consumer.

A GitHub Release does not imply a CocoaPods release, and successful pod lint does not authorize
publication.

## 9. Post-release verification

- [ ] Verify local and remote signed tag objects peel to the reviewed SHA.
- [ ] Verify the GitHub Release is public and its notes match the changelog.
- [ ] Resolve SwiftPM by exact version from a clean external consumer.
- [ ] Record any deferred CocoaPods publication and hosted compatibility follow-up without rewriting
      the released evidence.
- [ ] If rollback is required, publish a new corrective version; never move the existing tag.
