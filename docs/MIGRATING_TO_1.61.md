# Migrating to Boardy 1.61.0

Boardy 1.61.0 is an opt-in release candidate prepared for iOS 14+. It keeps the public umbrella
module and the synchronous caller-controlled execution model. Review the candidate evidence in
[`COMPATIBILITY.md`](COMPATIBILITY.md) before changing an application dependency.

## Platform floor

The minimum deployment target moves from iOS 12 to iOS 14. Before upgrading, set the application,
test target and every Boardy consumer target to iOS 14 or newer. A consumer that must remain on iOS
12/13 should stay on the existing release line; because no CocoaPods publication is being made in
this cycle, do not silently upgrade such a consumer.

## SwiftPM installation

```swift
dependencies: [
    .package(url: "https://github.com/congncif/boardy.git", exact: "1.61.0")
]
```

The package exposes one `Boardy` library product and includes the Composable surface through the
exact `UIComposableCore` 1.1.0 dependency. CocoaPods remains available as a prepared transition
path, but its publication is intentionally deferred.

## Existing activation code remains synchronous

The normal 1.x activation shape is unchanged:

```swift
motherboard.activateBoard(
    identifier: .pubCheckout,
    withOption: input
)
```

1.61.0 adds no `@MainActor` or other global-actor annotation, main-thread precondition or automatic
queue hop. UIKit callers remain responsible for calling UI-facing boards from the main thread;
non-UI Boardy APIs continue to execute on the caller-controlled synchronous executor.

The complete `BlockTaskBoard` terminal sequence—including success/error, processing false,
completion and Board completion messages—stays on the legacy completion executor in its existing
observable order. `Any?` remains the runtime transport behind the typed façades.

## Small source adjustments

- Prefer the non-deprecated `GatewayBarrierRegistration.exempt` spelling. The legacy zero-width
  spelling remains available during the 1.x compatibility window.
- `PluginLauncher` URL opening continues to return matched candidates; it is not an asynchronous
  success/failure result API.
- Do not add actor isolation or broad `Sendable` constraints as an application-side workaround.
  Swift 6 isolation is a separate follow-up plan.

## Behavior changes that can reach existing apps

These are observable changes in the 1.61 release line. Each one is backed by a regression test in
the 1.61 test suite.

**`BlockTaskBoard.latest` and `BlockTaskBoard` `deinit` actually cancel in-flight tasks now.**
Earlier releases discarded the `BlockTaskCanceler` returned by the direct executor on four of the
six executing types; cancellation from `cancelPendingTasksIfNeeded()` or `deinit` was a no-op for
`.default`, `.only`, `.onlyResult` and `.queue`. A task that used to run to completion will now
short-circuit. Move terminal callback delivery to the main queue if your cancel path interacts with
UIKit or the motherboard storage described in [COMPATIBILITY.md](COMPATIBILITY.md).

**Class-conforming `ModuleBuilderPlugin`s are now retained for the lifetime of the producer.**
Previously, the lazy factory held the plugin through a weak box and could `preconditionFailure` if
the plugin was a class instance released after `apply(for:)`. The plugin is now strongly captured
instead. Plugins that themselves retain the `MainComponent`/`ActivatableBoardProducer` will form a
retain cycle: review yours and prefer struct conformance where possible.

**`Motherboard.getBoard(identifier:)` is now a pure lookup.** It no longer produces and installs a
board. Activation paths now call `Motherboard.getOrProduceBoard(identifier:)`, which preserves the
old behavior. Read paths — interaction commands, completer, the new IO completion flow — use
`getBoard(identifier:)` and report an unknown identifier as a diagnostic instead of installing a
placeholder `NoBoard`. No code change is required in apps that did not rely on the placeholder side
effect.

## Review boundary

The candidate is prepared for maintainer review, not yet tagged or published as Boardy 1.61.0.
Hosted CI, older runtimes/devices, N-1 Xcode and CocoaPods test/lint evidence remain explicit
follow-up work.
