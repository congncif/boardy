//
//  ContextTests.swift
//  Boardy_Tests
//
//  SLICE S5 — nested flow, the UIKit context, and the DedicatedBoard difference.
//  See docs/02-working-docs/review/2026-08-02-coverage-plan.md §4 items 1.5, 1.10, 1.12.
//  DEPENDS ON: TestSupport.swift (`UIHost`).
//
//  Contracts to assert:
//
//  1.5 Nested flow (README §♻️ ContinuousBoard: Workflow Encapsulation)
//      · `mountContinuousMotherboard(to:configurationBuilder:)` builds a sub-motherboard and puts it
//        into the given context
//      · the `build:` overload uses the caller's motherboard type
//      · `attachContinuousMotherboard` differs from `mount` only in that the interface retains it
//      · a flow registered inside the sub-motherboard does not fire on the parent
//      · a flow action raised inside is forwarded up to the parent board
//
//  1.10 `DedicatedBoard` vs `GuaranteedBoard` (the documented difference)
//      · a `DedicatedBoard` activated with a mismatched option receives `nil` and does NOT trap
//      · a `GuaranteedBoard` in the same situation reports the mismatch
//
//  1.12 Root context (README §Core Concepts — "installed into any root context")
//      DONE in Phase 0, as the validation of `UIHost` — see the tests already in this file:
//      · `rootViewController` resolves from a UIWindow context and from a UIViewController context
//      · `window`, `navigationController`, `tabBarController` resolve when present
//      STILL OWNED BY THIS SLICE:
//      · `installIntoRootViewController(_:)` / `installIntoWindow(_:)`
//      · accessing `rootViewController` with no context asserts in DEBUG
//
//  API brief:
//      ModernContinuableBoard(identifier:boardProducer:) — mount/attach live in
//      Boardy/Core/Board/ContinuousBoard.swift and Boardy/Attachable/Board+Attachable.swift.
//      `attach…` requires the interface to be an `AttachableObject`; UIViewController already
//      conforms through the framework, so do not restate the conformance.
//
//  Traps:
//      · `ContinuousBoard` (legacy) takes a pre-built motherboard; `ModernContinuableBoard` takes a
//        producer and builds lazily. They are not interchangeable — that is the point of 1.5.
//      · The no-context assertion path traps in DEBUG; catch it with CwlPreconditionTesting rather
//        than letting the suite crash.
//
//  Rules: no wall-clock waits. Do not edit any file outside this one. If production code looks
//  wrong, stop and report.
//

@testable import Boardy
import UIKit
import XCTest

final class ContextTests: XCTestCase {
    // MARK: - Root context resolution

    //
    // These four also serve as the validation of `UIHost`: every later slice relies on it, so a
    // broken helper must fail here rather than inside somebody else's test.

    func testBoardResolvesRootViewControllerFromAWindowContext() {
        let host = UIHost()
        let board = RecordingBoard(identifier: "board")

        board.putIntoContext(host.window)

        XCTAssertTrue(board.rootViewController === host.navigationController)
        XCTAssertTrue(board.window === host.window)
    }

    func testBoardResolvesRootViewControllerFromAViewControllerContext() {
        let screen = UIViewController()
        let board = RecordingBoard(identifier: "board")

        board.putIntoContext(screen)

        XCTAssertTrue(board.rootViewController === screen)
    }

    func testBoardResolvesTheEnclosingNavigationController() {
        let host = UIHost()
        let board = RecordingBoard(identifier: "board")

        board.putIntoContext(host.window)

        XCTAssertTrue(board.navigationController === host.navigationController)
    }

    func testBoardResolvesTheEnclosingTabBarController() {
        let host = UIHost(tabBarBased: true)
        let board = RecordingBoard(identifier: "board")

        board.putIntoContext(host.window)

        XCTAssertTrue(board.tabBarController === host.tabBarController)
    }
}
