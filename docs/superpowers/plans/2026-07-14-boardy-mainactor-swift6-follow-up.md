# Boardy MainActor and Swift 6 Follow-up Plan

> **Status:** Deferred proposal. This plan is not approved for implementation and is not part of
> Boardy 1.61.0.

## Goal

Choose and implement a coherent isolation/executor model that allows Boardy to build in Swift 6
language mode without silently changing synchronous public behavior, callback ordering or UIKit
responsibilities.

## Why this is separate

Boardy 1.x exposes synchronous APIs without executor annotations, and known consumers use both main
and background queues. Hiding MainActor isolation behind existing methods could add off-main traps,
deadlocks, reentrancy changes or asynchronous ordering changes. The requester therefore removed all
MainActor, Sendable and Swift 6 language-mode work from 1.61.0 on 2026-07-14.

The authoritative 1.61.0 baseline is:

- caller-controlled synchronous Board/Motherboard/flow/plugin execution;
- no actor annotation, main-thread precondition or automatic queue hop;
- UIKit callers remain responsible for main-thread use;
- the complete `BlockTaskBoard` terminal sequence stays on its legacy completion executor and
  preserves observable ordering;
- shared storage uses audited lock transactions with callbacks after unlock.

## Scope

- Inventory representative main/off-main call sites and callback assumptions for each consumer
  group.
- Capture Boardy-owned Swift 6 compiler diagnostics using the final 1.61 package and supported
  dependency graph.
- Compare at least these models:
  1. MainActor only for explicit UIKit-facing ownership;
  2. MainActor for broader orchestration behind an additive async/executor API;
  3. actor-per-Motherboard or another instance-owned executor;
  4. caller-controlled core with explicit executor injection.
- Select one model through an ADR/RFC that states source, runtime, executor, ordering and migration
  consequences.
- Decide whether the selected contract fits a 1.x additive release or requires the reserved big
  update/major version.
- Implement only the approved model, then update package, migration and compatibility documentation.

## Out of scope

- Any mutation to Boardy 1.61.0.
- Broad `@unchecked Sendable`, `@preconcurrency` or `nonisolated(unsafe)` suppression.
- Typed routing, lifecycle state-machine redesign or module splitting unless separately approved.
- Hosted CI implementation; the CI plan consumes the final approved matrix later.

## Assumptions and risks

- The immutable 1.60.1 API baseline and final 1.61 artifacts remain available for comparison.
- Consumer owners can validate representative call sites before executor behavior changes.
- MainActor may be rejected after investigation; it is an option, not the predetermined answer.
- A synchronous compatibility wrapper can still be behavior-breaking even when public signatures do
  not change.
- Public `Sendable` constraints and global-actor annotations may require a major-update decision.
- Queue hops can change ordering, latency and reentrancy even when tests remain functionally green.

## Required design decisions

1. Which state is UI-owned, instance-owned, shared lock-protected or background-executor-owned?
2. Which existing synchronous APIs, if any, are already contractually main-only?
3. What executor delivers every callback and Board message, including cancellation and failure?
4. Is compatibility provided by preserving old APIs, adding new async/executor APIs, or a major
   migration?
5. Which values can safely conform to `Sendable`, and what invariant justifies every narrow
   `@unchecked Sendable` conformance?
6. What version and deprecation window communicate the behavior change honestly?

No implementation starts until these decisions and the resulting complete plan are approved.

## Dependency-ordered workstreams

### 1. Consumer and compiler baseline

- Map public entry points to representative consumers and current queues.
- Record callback/order dependencies, UIKit presentation paths and synchronous return assumptions.
- Build the final 1.61 package in Swift 6 language mode to classify Boardy-owned diagnostics without
  changing source.

### 2. Isolation and API design

- Produce one ownership map for Motherboard, BoardProducer, flow, bus, plugin, URL and UIKit state.
- Evaluate the four candidate models against consumer evidence.
- Draft the selected public/executor contract, migration strategy and version consequence.
- Review the public interface diff before implementation.

### 3. Executable compatibility tests

Before production changes, add deterministic tests for every behavior the selected model could
change:

- existing off-main synchronous callers;
- UIKit-facing calls and the approved actor boundary;
- callback executor identity and complete terminal order;
- reentrancy and exactly-once completion;
- cancellation races and lock/callback separation;
- deallocation/lifetime across actor or task boundaries.

Use controlled executors, queue-specific keys and XCTest expectations tied to real events. Do not
use arbitrary sleeps.

### 4. Implementation slices

Implement in dependency order with one writer for shared core files:

1. internal ownership primitives and narrowly justified Sendable conformances;
2. explicit UIKit isolation boundary;
3. Motherboard/producer/flow/bus ownership;
4. plugin/URL composition;
5. `BlockTaskBoard` only if the approved contract explicitly changes it;
6. additive public compatibility API, if approved.

Preserve existing declarations unless the approved version plan explicitly authorizes a breaking
change.

### 5. Distribution and migration

- Build Boardy and a clean consumer in Swift 5 and Swift 6 language modes.
- Compare public API artifacts with the 1.60.1 and 1.61 baselines.
- Document actor/executor guarantees, migration examples, deprecations and supported toolchain.
- Feed the approved matrix into the separate hosted-CI plan.

### 6. Final consistency review

Run one independent review over the complete diff. It must reconcile source, tests, API artifacts,
ADR, migration guide and examples against the same executor contract. Apply accepted in-scope
findings once, rerun affected verification and stop if a finding requires a new architecture or
version decision.

## Test and verification needs

- Focused XCTest rows for each affected executor/ordering behavior.
- Full Boardy suite on the user-approved simulator matrix.
- Swift 5 compatibility build and Swift 6 strict language-mode build.
- Clean external SwiftPM consumer in both supported language modes.
- API Digester and textual public-interface comparison.
- TSan/stress verification for shared mutable paths when the approved environment supports it.

## Semantic commit boundaries

1. `docs: approve Boardy isolation and executor contract`
2. `test: characterize Boardy actor and executor boundaries`
3. `refactor(concurrency): implement approved Boardy isolation model`
4. `build: validate Boardy in Swift 6 language mode`
5. `docs: publish Boardy concurrency migration guide`

These are reviewable outcomes, not authorization to create commits or releases.

## Definition of Done

- Consumer owners and technical owner approve the isolation/executor contract.
- The ADR/RFC selects one model and records rejected alternatives and version consequences.
- Existing public APIs have an explicit compatibility or migration disposition.
- Every callback family has documented executor and ordering semantics.
- Swift 5 compatibility and Swift 6 strict builds pass for Boardy and a clean consumer.
- No unsafe suppression is present without a documented, tested invariant.
- API comparison shows only approved changes.
- Executor, reentrancy, cancellation, lifetime and UIKit-boundary tests pass.
- Migration, compatibility, README and examples describe the implemented model consistently.
- One final independent consistency review is complete.

## Approval

This document only preserves the deferred scope. A future session must update it with consumer
evidence, select the design, confirm the release/version strategy and obtain explicit approval before
execution.
