# Boardy 1.x API stability policy

Applies to Boardy 1.61.0 and later supported 1.x releases.

## Positioning

Boardy 1.x is a legacy-compatible modular orchestration framework with typed input/output façades over a runtime `Any?` transport. The typed façades reduce mistakes but do not make the central transport end-to-end type safe.

## Surface classifications

- **Supported:** documented Board/Motherboard, flow, producer, plugin, ComponentKit, Attachable and Composable declarations shipped by the `Boardy` module.
- **Deprecated:** declarations carrying a compiler deprecation attribute and a documented replacement. Deprecation is a migration signal, not immediate removal permission.
- **Legacy-compatible:** public behavior intentionally preserved for 1.x, including `Any?` transport, synchronous entry points and callback-based task execution.
- **Experimental/deferred:** proposals that are not part of the supported 1.x contract, including typed-route core, async/await task API and public activation identity.

The exhaustive declaration-keyed inventory is generated from the Swift API Digester graph later in the release. The immutable baseline artifacts are:

- [`api/Boardy-1.60.1.swiftinterface`](api/Boardy-1.60.1.swiftinterface)
- [`api/Boardy-1.60.1.api.json`](api/Boardy-1.60.1.api.json)
- [`api/BASELINE_PROVENANCE.md`](api/BASELINE_PROVENANCE.md)

## Compatibility rules

Within 1.x, an existing public declaration must not be removed, renamed, made less visible, gain a stricter generic/`Sendable` constraint, change sync/throwing semantics or gain a global-actor annotation without a separately approved breaking-release plan.

Additive APIs and conformances require API review, tests and inventory classification. Fixing an implementation bug is allowed when the intended behavior is documented and protected by a regression test.

Executor identity, callback order, main-thread preconditions and whether a callback is synchronous are public behavioral contracts even when absent from a Swift signature. Changes to those behaviors require consumer evidence and migration disclosure.

No newly deprecated declaration is removed during 1.x. Removal requires a separately approved major-update migration window and a documented replacement. Existing deprecated compatibility spellings remain available through that window.

## Project versioning policy

The requester-approved policy allows a minimum-platform increase in a minor release; major versions are reserved for a big product update. Therefore Boardy 1.61.0 raises the floor from iOS 12 to iOS 14 and prominently discloses the impact. This is a project policy and is not described as strict Semantic Versioning.

Source/API removals still require a major-update decision. The platform exception does not authorize declaration or executor breaks.

## Concurrency policy for 1.61.0

The sole owner is designated and approved this policy, the iOS 14 support matrix and the
caller-controlled compatibility contract on 2026-07-14. Known consumers below iOS 14 remain on
their current release line because 1.61.0 is GitHub-only; a later CocoaPods publication requires
their migration, `< 1.61` ceiling or retirement disposition. Gate A1 is therefore approved. The
selected contract is:

- No MainActor/global-actor isolation, main-thread precondition or automatic queue hop is added in
  1.61.0.
- Existing synchronous APIs preserve caller-controlled execution. UIKit callers remain responsible
  for main-thread use according to UIKit's contract.
- The full `BlockTaskBoard` terminal sequence preserves its legacy completion executor and
  observable order, including Board messages.
- Shared synchronous storage uses audited compound lock operations and never invokes handlers while locked.
- Swift 6 language-mode, framework-wide/public Sendable and actor-isolation work is deferred to a
  separately approved follow-up plan; narrowly audited lock-backed internal conformances remain.
  Swift 6 readiness is not a 1.61.0 release claim.

The final 1.61.0 interface and API graph must be compared to the immutable baseline with `tools/verify-public-api.sh` before tagging.
