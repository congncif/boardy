# Boardy 1.61 compatibility

This document describes the release candidate, not a CI-enforced support promise. The current
candidate is prepared for review on Xcode 26.4.1 with Swift 5 language mode and iOS 14 or newer.
Hosted CI, older runtimes, alternate devices and Swift 6 isolation are deliberately deferred.

## Candidate verification matrix

| Integration | Product | Language | Toolchain/destination | Platform floor | Evidence status |
| --- | --- | --- | --- | --- | --- |
| SwiftPM | `Boardy` umbrella, including Composable | Swift 5 | Xcode 26.4.1; selected iPhone 17 simulator only | iOS 14+ | Package + test-target compile pass; runtime row awaits CoreSimulatorService |
| SwiftPM consumer | `BoardySmoke` imports `Boardy` | Swift 5 | Xcode 26.4.1; generic iOS Simulator build | iOS 14+ | Consumer compile pass via local path |
| CocoaPods metadata | `Boardy` podspec and Example project settings | Swift 5 metadata | Podfile/project values set to iOS 14; lock refresh deferred | iOS 14+ | Prepared only; CocoaPods test/lint intentionally deferred for this review cycle |
| UIComposable prerequisite | `UIComposableCore` | Swift 5/6 already verified | Release tag `1.1.0` | iOS 12+ | Annotated tag and peeled remote SHA verified |

The matrix is an evidence boundary. It does not claim G1, organization-wide production support,
older-runtime support, N-1 Xcode support or hosted-CI coverage.

## Dependency contract

SwiftPM resolves `UIComposableCore` from the exact public tag `1.1.0`; Boardy keeps one umbrella
product and preserves `import Boardy`. CocoaPods resolves `UIComposable ~> 1.0.1` from trunk. The
UIComposable `1.0.1` and `1.1.0` tags contain identical `UIComposable/` source; `1.1.0` adds the
SwiftPM manifest and test metadata only. Boardy's SPM and CocoaPods version labels therefore differ
without shipping different Boardy-facing source. Both package paths include Boardy's Composable
surface; CocoaPods `Default` now depends on `Boardy/Composable` explicitly.

## Threading contract

Call `addBoard`, `removeBoard`, `clearActiveBoards`, `registerFlow`, `removeFlow` and `resetFlows`
on the main thread. DEBUG builds assert this contract; release builds keep the existing
caller-controlled execution and do not hop queues or add a release precondition.

The installed-board list is plain unsynchronized storage, which is why that contract exists. The
flow list is different: a board sends its output from whichever executor its work finished on —
`BlockTaskBoard` deliberately keeps its legacy completion executor — so flow *dispatch* is not a
main-thread-only path and cannot be made one without changing published behavior. That storage is
therefore locked internally and every reader takes a snapshot. No caller obligation is added by
this; sending output off the main thread was always supported and remains so.

## CocoaPods publication

Boardy 1.61.0 is published to the CocoaPods trunk. A consumer that depends on Boardy without a
version bound resolves it and inherits the iOS 14 floor.

The owner's disposition: every known consumer already targets iOS 14 or newer, so this is not a
migration event. An application that must stay below iOS 14 pins `~> 1.60`, which continues to serve
the iOS 12 line.

Templates that generate podspecs should still emit a bounded Boardy dependency; an unbounded one
hands every scaffolded module whatever floor the newest release happens to carry.

## Compatibility policy

Boardy 1.61.0 raises the deployment floor from iOS 12 to iOS 14 under the project policy that a
minimum-platform increase may ship in a minor release. Major versions remain reserved for a big
update. Existing synchronous APIs, `Any?` transport and the caller-controlled `BlockTaskBoard`
executor/order remain unchanged; no MainActor annotation, main-thread precondition or automatic
queue hop is introduced.
