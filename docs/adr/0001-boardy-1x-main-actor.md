# ADR-0001 — Deferred actor isolation for Boardy 1.x

- Status: Deferred — removed from Boardy 1.61.0 scope by requester
- Date: 2026-07-14
- Deferred target: separately approved MainActor/Swift 6 follow-up
- Decision owner: `congnc.if@gmail.com`
- Release actor: `@congncif` (authenticated repository administrator)

## Context

Boardy 1.60.1 exposes synchronous orchestration and callback APIs whose declarations do not state
an executor. The runtime includes Motherboard, flow, plugin and UIKit state, while
`BlockTaskBoard` executors commonly finish on background queues. Swift 6 makes these implicit
boundaries harder to maintain, but adding actor annotations, main-thread preconditions, queue hops
or `Sendable` constraints can change source compatibility and observable runtime behavior.

The original Option A draft proposed MainActor-first internals for 1.61.0. Consumer evidence then
showed substantial concurrent `BlockTaskBoard` use and explicit consumer-owned hops to the main
queue. The requester decided on 2026-07-14 that MainActor introduces too many concerns for this
minor release and moved all actor-isolation work to a separate plan.

## Decision for Boardy 1.61.0

1. Keep one public `Boardy` umbrella module and all existing public declaration signatures.
2. Preserve synchronous caller-controlled execution. Do not add `@MainActor`, another global
   actor, a main-thread runtime precondition or an automatic executor hop.
3. UIKit callers remain responsible for main-thread use according to UIKit's contract; 1.61.0 does
   not introduce a Boardy isolation boundary around those calls.
4. Protect truly cross-thread synchronous storage with a minimal `Locked<Value>` primitive. No
   callback, handler, delegate call or Board message may execute while its lock is held.
5. Preserve the complete legacy `BlockTaskBoard` terminal path on its completion executor:
   success/error, optional `sendOutput`, processing/completion handlers and optional Board
   `complete` retain their existing order.
6. Keep legacy task `Input`/`Output` unconstrained. Do not add a compatibility carrier merely to
   make Swift 6 language mode compile.
7. Raise Boardy metadata and examples to iOS 14. UIComposable publishes the additive
   `UIComposableCore` SwiftPM product at 1.1.0 so Boardy can retain one complete package target.

## Deferred follow-up

MainActor, another actor model, public executor selection, framework-wide/public `Sendable`
migration and Swift 6 language-mode readiness require a separately approved plan. Narrowly audited
lock-backed internal conformances already used by 1.61 remain in scope. The follow-up must begin with consumer
call-site evidence and choose one coherent isolation/executor model before implementation.

The outline of that deferred work, recorded here so this ADR stands on its own:

- **Goal** — build in Swift 6 language mode without silently changing synchronous public behavior,
  callback ordering or UIKit responsibilities.
- **Why separate** — Boardy 1.x exposes synchronous APIs with no executor annotations, and known
  consumers call from both main and background queues. Hiding isolation behind existing methods
  could introduce off-main traps, deadlocks, reentrancy changes or asynchronous reordering.
- **Entry condition** — an inventory of representative main/off-main call sites and callback
  assumptions per consumer, before any annotation is added.
- **Baseline the work must preserve** — caller-controlled synchronous execution; no actor
  annotation, release main-thread precondition or automatic queue hop; UIKit callers responsible
  for main-thread use; the complete `BlockTaskBoard` terminal sequence on its legacy completion
  executor with observable ordering intact; shared storage using audited lock transactions that
  invoke callbacks only after unlock.

This ADR must not be changed to `Accepted` as a MainActor design by the 1.61.0 plan. Its filename is
retained as the historical path referenced by earlier plan revisions.

## Lock boundaries already selected

- `Attachable` storage locks the complete lookup/create/add transaction and returns copies before
  callbacks.
- Combined-flow accumulation extracts ready work atomically and invokes handlers after unlock.
- Application-scope activation barriers keep phase, weak owner identity and pending cycles in one
  transaction.
- Block-task records terminalize atomically with an explicit completed/cancelled reason;
  pending-canceler tombstones are not active work.

## Alternatives deferred or rejected for 1.61.0

- Annotating the whole public API with `@MainActor`: source-breaking for existing synchronous and
  off-main callers.
- Adding internal MainActor helpers behind synchronous preconditions: can introduce new off-main
  traps and has not been proven compatible across consumers.
- Dispatching only `sendOutput`/`complete` to MainActor: changes observable handler/message
  ordering.
- Adding a new executor-selection API: requires an RFC and a separately approved public-API plan.
- Applying `@unchecked Sendable` broadly: suppresses diagnostics without establishing ownership
  invariants.
- Splitting Boardy into public submodules in 1.x: changes imports and distribution shape beyond
  Option A.

## Consequences

- Consumers must target iOS 14 to adopt 1.61.0.
- Background execution, synchronous caller behavior and the complete `BlockTaskBoard` terminal
  executor/order remain supported as legacy-compatible behavior.
- Boardy 1.61.0 is validated in Swift 5 language mode on Xcode 26.4.1 and makes no Swift 6
  language-mode readiness claim.
- SwiftPM consumers resolve only `UIComposableCore`; CocoaPods publication is intentionally
  deferred from this Git/GitHub release.
- Actor isolation, typed routing, async APIs and framework-wide activation identity remain future
  work.
