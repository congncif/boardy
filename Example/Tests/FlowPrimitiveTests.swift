//
//  FlowPrimitiveTests.swift
//  Boardy_Tests
//
//  SLICE S2 — flow primitives and the registration overloads nothing exercises.
//  See docs/02-working-docs/review/2026-08-02-coverage-plan.md §4 items 1.6–1.8.
//
//  Contracts to assert:
//
//  1.6 Primitives (all at 0%, and all used by this repo's own Example app)
//      · `IDGenericBoardFlow` matches by board identifier AND output type
//        (Example: Demo/Dashboard/DashboardBoard.swift:38)
//      · `GenericBoardFlow` matches by a caller-supplied closure
//      · `DataMatchBoardFlow.doNext(with:)` passes the unwrapped data on
//      · `IDMatchBoardFlow.match(with:)` accepts only the listed identifiers
//      · `BoardActivateFlow` — all five inits
//        (Example: Deprecated/AppDelegate.swift:144)
//
//  1.7 Registration overloads at 0%
//      · `registerGeneralFlow(target:uniqueOutputType:nextHandler:)` — target held weakly
//        (Example: Demo/Main/MainBoard.swift:44)
//      · `registerFlow(matchedIdentifiers:target:uniqueOutputType:nextHandler:)`
//      · `registerFlow(matchedIdentifiers:uniqueOutputType:nextHandler:)`
//      · `registerCompletionFlow(matchedIdentifiers:nextHandler:)`
//      · the variadic form of `registerChainFlow`
//
//  1.8 Composition
//      · `bindToBus:` — a board's output reaches the bus's cables
//      · `sendOutputThrough:` — board A's output is re-emitted by board B
//
//  API brief:
//      Flow.swift declares the array forms; FLow+Variadic.swift the variadic ones. `FlowStepID` is a
//      typealias for `BoardID`. Every `register…` returns `Self`, so they chain.
//      Drive a flow without UI by calling `motherboard.board(someBoard, didSendData: value)` —
//      that is the delegate entry point flows are matched from.
//
//  Traps:
//      · An output whose type does not match a `GuaranteedBoardFlow` traps via `assertionFailure`.
//        `FlowTests` catches that deliberately with CwlPreconditionTesting; do not reproduce it
//        accidentally.
//      · Silent data (`isSilentData`) is skipped rather than delivered — assert accordingly.
//
//  Rules: no wall-clock waits; prefer `SyncEmittingBoard` so assertions need no waiting. Do not edit
//  any file outside this one. If production code looks wrong, stop and report.
//

@testable import Boardy
import XCTest

final class FlowPrimitiveTests: XCTestCase {}
