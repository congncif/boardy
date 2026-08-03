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
#if canImport(CwlPreconditionTesting)
    import CwlPreconditionTesting
#endif
import UIKit
import XCTest

// MARK: - Fixtures for nested-flow tests

private extension BoardID {
    static let child: BoardID = "child"
}

/// Produces exactly one identifier, via one factory. Enough for a sub-motherboard to activate
/// something real instead of falling through to `NoBoard` (which presents an alert and traps
/// without a UIKit context).
private final class SingleBoardProducer: ActivatableBoardProducer {
    private let identifier: BoardID
    private let factory: (BoardID) -> ActivatableBoard

    init(identifier: BoardID, factory: @escaping (BoardID) -> ActivatableBoard) {
        self.identifier = identifier
        self.factory = factory
    }

    func produceBoard(identifier requested: BoardID) -> ActivatableBoard? {
        requested == identifier ? factory(requested) : nil
    }
}

/// A minimal `ModernContinuableBoard`: `ActivatableBoard` conformance is only what's needed to
/// install it into a containing `Motherboard`, since `addBoard` requires it.
private final class ParentContinuableBoard: ModernContinuableBoard, ActivatableBoard {
    func activate(withOption _: Any?) {}
}

/// A `BoardFlowAction` a child board can raise, to be traced up through `forwardActionFlow`.
private struct TestFlowAction: BoardFlowAction, Equatable {
    let payload: String
}

/// Raises whatever `BoardFlowAction` it's activated with, via `sendFlowAction`.
private final class ActionRaisingBoard: Board, ActivatableBoard {
    func activate(withOption option: Any?) {
        guard let action = option as? BoardFlowAction else { return }
        sendFlowAction(action)
    }
}

/// Declares `InputType = String` with no override, to exercise the shared default conversion —
/// the difference under test lives entirely in `DedicatedBoard`/`GuaranteedBoard`'s own
/// `activate(withOption:)`, not in any custom adapter.
private final class TypedDedicatedBoard: Board, DedicatedBoard {
    typealias InputType = String

    private(set) var receivedInputs: [String?] = []

    func activate(withInput input: String?) {
        receivedInputs.append(input)
    }
}

private final class TypedGuaranteedBoard: Board, GuaranteedBoard {
    typealias InputType = String

    private(set) var receivedInputs: [String] = []

    func activate(withGuaranteedInput input: String) {
        receivedInputs.append(input)
    }
}

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

    // MARK: - Root context installation

    func testInstallIntoRootViewControllerPutsBoardIntoThatContext() {
        let screen = UIViewController()
        let board = RecordingBoard(identifier: "board")

        board.installIntoRootViewController(screen)

        XCTAssertTrue(board.rootViewController === screen)
    }

    func testInstallIntoWindowPutsBoardIntoThatContext() {
        let host = UIHost()
        let board = RecordingBoard(identifier: "board")

        board.installIntoWindow(host.window)

        XCTAssertTrue(board.window === host.window)
    }

    func testRootViewControllerWithNoContextAssertsInDebug() throws {
        let board = RecordingBoard(identifier: "board")

        #if canImport(CwlPreconditionTesting)
            var assertionCalled = false

            let exceptionGuard: CwlPreconditionTesting.BadInstructionException? = CwlPreconditionTesting.catchBadInstruction {
                assertionCalled = true
                _ = board.rootViewController
            }

            XCTAssertNotNil(exceptionGuard)
            XCTAssertTrue(assertionCalled)
        #else
            throw XCTSkip("CwlPreconditionTesting is only available in the CocoaPods/Xcode test host")
        #endif
    }

    // MARK: - Nested flow (ModernContinuableBoard)

    func testMountBuildsSubMotherboardAndInstallsIntoContext() {
        let parentBoard = ParentContinuableBoard(identifier: "parent", boardProducer: NoBoardProducer())
        let context = UIViewController()

        let sub = parentBoard.mountContinuousMotherboard(to: context)

        XCTAssertTrue(sub.context === context)
    }

    func testMountBuildOverloadReturnsCallersMotherboardType() {
        let parentBoard = ParentContinuableBoard(identifier: "parent", boardProducer: NoBoardProducer())
        let context = UIViewController()

        // Typing `sub` as the concrete `Motherboard` (not `FlowMotherboard`) only compiles if the
        // `build:` overload actually returns the caller's own type rather than an existential.
        let sub: Motherboard = parentBoard.mountContinuousMotherboard(to: context) { producer in
            Motherboard(identifier: "custom-sub", boardProducer: producer)
        }

        XCTAssertEqual(sub.identifier, "custom-sub")
        XCTAssertTrue(sub.context === context)
    }

    func testAttachRetainsMotherboardOnContextUnlikeMount() {
        let parentBoard = ParentContinuableBoard(identifier: "parent", boardProducer: NoBoardProducer())
        let mountContext = UIViewController()
        let attachContext = UIViewController()

        let mounted = parentBoard.mountContinuousMotherboard(to: mountContext)
        let attached = parentBoard.attachContinuousMotherboard(to: attachContext)

        XCTAssertTrue(attachContext.attachedObjects().contains { $0 === attached as AnyObject })
        XCTAssertFalse(mountContext.attachedObjects().contains { $0 === mounted as AnyObject })
    }

    func testFlowRegisteredInsideSubMotherboardDoesNotFireOnParent() {
        let topMotherboard = Motherboard()
        let parentBoard = ParentContinuableBoard(
            identifier: "parent",
            boardProducer: SingleBoardProducer(identifier: .child) { identifier in
                SyncEmittingBoard<String>(identifier: identifier)
            }
        )
        topMotherboard.addBoard(parentBoard)

        let sibling = SyncEmittingBoard<String>(identifier: "sibling")
        topMotherboard.addBoard(sibling)

        var subFlowFired = false
        let sub = parentBoard.mountContinuousMotherboard(to: UIViewController()) { subMotherboard in
            subMotherboard.registerGeneralFlow(uniqueOutputType: String.self) { _ in
                subFlowFired = true
            }
        }

        // A board outside the sub-motherboard sends the same output type the sub's flow matches —
        // it must not reach a flow registered on the sub.
        sibling.activate(withGuaranteedInput: "from outside")
        XCTAssertFalse(subFlowFired, "a flow registered on the sub-motherboard must not react to boards outside it")

        // Confirm the flow does fire for a board that is actually inside the sub, so the negative
        // result above isn't just a flow that never fires at all.
        sub.activateBoard(identifier: .child, withOption: "from inside")
        XCTAssertTrue(subFlowFired)
    }

    func testFlowActionRaisedInSubMotherboardForwardsToParentBoard() {
        let topMotherboard = Motherboard()
        let parentBoard = ParentContinuableBoard(
            identifier: "parent",
            boardProducer: SingleBoardProducer(identifier: .child) { identifier in
                ActionRaisingBoard(identifier: identifier)
            }
        )
        topMotherboard.addBoard(parentBoard)

        var receivedActions: [TestFlowAction] = []
        topMotherboard.registerGeneralFlow(uniqueOutputType: TestFlowAction.self) {
            receivedActions.append($0)
        }

        let sub = parentBoard.mountContinuousMotherboard(to: UIViewController())
        sub.activateBoard(identifier: .child, withOption: TestFlowAction(payload: "up"))

        XCTAssertEqual(receivedActions, [TestFlowAction(payload: "up")])
    }

    // MARK: - DedicatedBoard versus GuaranteedBoard

    func testDedicatedBoardReceivesNilOnMismatchedOptionWithoutTrapping() {
        let board = TypedDedicatedBoard(identifier: "dedicated")

        board.activate(withOption: 42) // Int, mismatched against the declared String InputType

        XCTAssertEqual(board.receivedInputs, [nil])
    }

    func testGuaranteedBoardReportsMismatchedOptionInsteadOfSilentlyActivating() throws {
        let board = TypedGuaranteedBoard(identifier: "guaranteed")

        #if canImport(CwlPreconditionTesting)
            var assertionCalled = false

            let exceptionGuard: CwlPreconditionTesting.BadInstructionException? = CwlPreconditionTesting.catchBadInstruction {
                assertionCalled = true
                board.activate(withOption: 42) // Int, mismatched against the declared String InputType
            }

            XCTAssertNotNil(exceptionGuard)
            XCTAssertTrue(assertionCalled)
            XCTAssertTrue(board.receivedInputs.isEmpty)
        #else
            throw XCTSkip("CwlPreconditionTesting is only available in the CocoaPods/Xcode test host")
        #endif
    }
}
