# ADR-0001 — Boardy 1.x MainActor and compatibility boundary

- Status: Proposed — executor branch approved; remaining Gate A1 approval pending
- Date: 2026-07-14
- Release: Boardy 1.61.0
- Decision owner: `congnc.if@gmail.com`
- Release actor: `@congncif` (authenticated repository administrator)

## Context

Boardy 1.60.1 exposes synchronous orchestration and callback APIs whose declarations do not state an executor. Much of the runtime mutates Motherboard, flow, plugin or UIKit state, while `BlockTaskBoard` executors commonly finish on background queues. Swift 6 makes those implicit boundaries unsafe, but adding `@MainActor` or `Sendable` constraints directly to the existing public surface would break source compatibility.

The selected Option A release raises Boardy to iOS 14 while preserving the 1.x programming model, runtime `Any?` transport and `import Boardy`. Local consumer evidence shows substantial concurrent `BlockTaskBoard` use and explicit consumer-owned hops to the main queue, so changing its callback executor or observable ordering in a minor release has material risk.

## Proposed decision

1. Keep one public `Boardy` umbrella module and all existing public declaration signatures.
2. Use MainActor-first internal helpers for Motherboard mutation, flow/plugin composition, URL routing and UIKit presentation after an audited compatibility boundary.
3. Do not add a global-actor annotation to an existing public declaration in 1.61.0.
4. Protect truly cross-thread synchronous storage with a minimal `Locked<Value>` primitive. No callback, handler, delegate call or Board message may execute while its lock is held.
5. Preserve the complete legacy `BlockTaskBoard` terminal path on its captured completion executor: success/error, optional `sendOutput`, processing/completion handlers and optional Board `complete` retain their existing order. The requester approved this branch on 2026-07-14. This is a documented non-MainActor residual, not a hybrid split.
6. Keep legacy task `Input`/`Output` unconstrained. A narrowly scoped internal compatibility carrier may be `@unchecked Sendable`; public generic constraints do not change.
7. Raise Boardy metadata and examples to iOS 14. UIComposable publishes an additive `UIComposableCore` SwiftPM product at 1.1.0, with an iOS 12 package floor, so Boardy can ship one complete SwiftPM target without pulling DiffUI/Rx dependencies.

Gate A1 may mark this ADR Accepted only after consumer owners/dispositions, explicit policy approval, public API baseline capture and executor behavior tests are all recorded. If review requires Board messages on MainActor while consumers require legacy executor/order, execution stops and the public-contract decision returns to planning.

## Lock boundaries

- `Attachable` storage locks the complete lookup/create/add transaction and returns copies before callbacks.
- Combined-flow accumulation extracts ready work atomically and invokes handlers after unlock.
- Application-scope activation barriers keep phase, weak owner identity and pending cycles in one transaction.
- Block-task records terminalize atomically with an explicit completed/cancelled reason; pending-canceler tombstones are not active work.

## Rejected alternatives

- Annotating the whole public API with `@MainActor`: source-breaking for existing synchronous/off-main callers.
- Dispatching only `sendOutput`/`complete` to MainActor: changes observable handler/message ordering.
- Adding a new executor-selection API at Gate A1: additive public API needs a separate RFC and plan amendment.
- Applying `@unchecked Sendable` broadly: suppresses diagnostics without establishing ownership invariants.
- Splitting Boardy into public submodules in 1.x: changes imports and distribution shape beyond Option A.

## Consequences

- Consumers must target iOS 14 to adopt 1.61.0.
- Background task execution remains supported, but executor identity and ordering are now an explicit compatibility contract.
- MainActor safety improves without claiming that every legacy path is MainActor-isolated.
- SwiftPM consumers resolve only `UIComposableCore`; CocoaPods publication is intentionally deferred from this Git/GitHub release.
- Typed routing, async APIs and framework-wide activation identity remain major-update work.
