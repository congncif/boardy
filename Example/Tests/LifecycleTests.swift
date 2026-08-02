//
//  LifecycleTests.swift
//  Boardy_Tests
//
//  Created by NGUYEN CHI CONG on 2/4/21.
//  Copyright © 2021 [iF] Solution. All rights reserved.
//

@testable import Boardy
import XCTest

final class ContiBoard: ContinuousBoard, ActivatableBoard {
    func activate(withOption _: Any?) {}
}

final class SingleBoard: Board, ActivatableBoard {
    func activate(withOption _: Any?) {}
}

/// Gateway barrier that never calls `complete()`, leaving the pending activation queued forever.
private final class StuckGatewayBoard: Board, ActivatableBoard {
    func activate(withOption _: Any?) {}
}

/// Destination guarded by the stuck gateway. It must not be activated while the gate is pending.
private final class GuardedBoard: Board, ActivatableBoard {
    private(set) var activationCount = 0

    func activate(withOption _: Any?) {
        activationCount += 1
    }
}

private final class LifecycleRecordingBoard: Board, DedicatedBoard {
    typealias InputType = String

    private(set) var receivedInputs: [String?] = []

    func activate(withInput input: String?) {
        receivedInputs.append(input)
    }
}

class LifecycleTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /// A board completed by one of its siblings is released.
    ///
    /// This used to be the whole of `testBoardShouldBeReleasedAfterCompleted`, with the direct
    /// `complete()` call commented out — so the name promised the self-completion path while the
    /// body only ever exercised this one. The two paths are now separate tests.
    func testBoardIsReleasedWhenCompletedBySibling() throws {
        let motherboard: FlowMotherboard = Motherboard(boards: [SingleBoard(identifier: "1"), ContiBoard(identifier: "2", motherboard: Motherboard())])
        weak var singleBoard = motherboard.boards.first { $0.identifier == "1" }
        weak var contiBoard = motherboard.boards.first { $0.identifier == "2" }

        XCTAssertNotNil(singleBoard)
        XCTAssertNotNil(contiBoard)

        // Board "2" completes board "1" through the shared motherboard, not by touching it.
        contiBoard?.completer("1").complete()
        XCTAssertNil(singleBoard)
        XCTAssertNotNil(contiBoard)
        XCTAssertEqual(motherboard.boards.map(\.identifier), ["2"])

        motherboard.completer("2").complete()
        XCTAssertNil(contiBoard)
        XCTAssertTrue(motherboard.boards.isEmpty)
    }

    /// A board that completes itself is released.
    func testBoardIsReleasedWhenItCompletesItself() throws {
        let motherboard: FlowMotherboard = Motherboard(boards: [SingleBoard(identifier: "1"), SingleBoard(identifier: "2")])
        weak var firstBoard = motherboard.boards.first { $0.identifier == "1" }
        weak var secondBoard = motherboard.boards.first { $0.identifier == "2" }

        XCTAssertNotNil(firstBoard)
        XCTAssertNotNil(secondBoard)

        firstBoard?.complete()

        XCTAssertNil(firstBoard)
        XCTAssertNotNil(secondBoard)
        XCTAssertEqual(motherboard.boards.map(\.identifier), ["2"])
    }

    func testActivateAllBoardsWithDefaultInputContinuesAfterMissingInput() {
        let firstBoard = LifecycleRecordingBoard(identifier: "1")
        let secondBoard = LifecycleRecordingBoard(identifier: "2")
        let thirdBoard = LifecycleRecordingBoard(identifier: "3")
        let motherboard: FlowMotherboard = Motherboard(boards: [firstBoard, secondBoard, thirdBoard])

        motherboard.activateAllBoards(
            withInputs: [
                BoardInput(target: firstBoard.identifier, input: "first"),
                BoardInput(target: thirdBoard.identifier, input: "third"),
            ],
            defaultInput: "default"
        )

        XCTAssertEqual(firstBoard.receivedInputs, ["first"])
        XCTAssertEqual(secondBoard.receivedInputs, ["default"])
        XCTAssertEqual(thirdBoard.receivedInputs, ["third"])
    }

    func testActivateAllBoardsWithoutDefaultInputContinuesAfterMissingInput() {
        let firstBoard = LifecycleRecordingBoard(identifier: "1")
        let secondBoard = LifecycleRecordingBoard(identifier: "2")
        let thirdBoard = LifecycleRecordingBoard(identifier: "3")
        let motherboard: FlowMotherboard = Motherboard(boards: [firstBoard, secondBoard, thirdBoard])

        motherboard.activateAllBoards(withInputs: [
            BoardInput(target: firstBoard.identifier, input: "first"),
            BoardInput(target: thirdBoard.identifier, input: "third"),
        ])

        XCTAssertEqual(firstBoard.receivedInputs, ["first"])
        XCTAssertEqual(secondBoard.receivedInputs.count, 1)
        XCTAssertNil(secondBoard.receivedInputs[0])
        XCTAssertEqual(thirdBoard.receivedInputs, ["third"])
    }

    /// `getBoard(identifier:)` is a lookup and must have no side effect.
    ///
    /// It used to produce and permanently install a board. With the default `NoBoardProducer` that
    /// means a single read of a mistyped identifier installs a placeholder `NoBoard`, which then
    /// shadows the real board forever — every later activation of that identifier finds the
    /// placeholder first and shows "Feature Not Found".
    func testGetBoardDoesNotInstallBoardForUnknownIdentifier() {
        let motherboard = Motherboard(boards: [SingleBoard(identifier: "known")])

        _ = motherboard.getBoard(identifier: "mistyped")

        XCTAssertEqual(
            motherboard.boards.map(\.identifier),
            ["known"],
            "A read path installed a placeholder board"
        )
    }

    /// The activation path still produces on demand — lazy registration must keep working.
    func testGetOrProduceBoardStillInstallsProducedBoard() {
        let producer = BoardProducer()
        producer.registerBoard("lazy") { identifier in
            SingleBoard(identifier: identifier)
        }
        let motherboard = Motherboard(boardProducer: producer)

        let produced = motherboard.getOrProduceBoard(identifier: "lazy")

        XCTAssertNotNil(produced)
        XCTAssertEqual(motherboard.boards.map(\.identifier), ["lazy"])
    }

    /// A gateway barrier that never completes must not retain its Motherboard.
    ///
    /// The pending activation closure captured `board` and `self` strongly, forming
    /// motherboard -> mainboard -> gatewayBarrierBoard -> pendingTask -> closure -> motherboard.
    func testStuckGatewayBarrierDoesNotRetainMotherboard() {
        let guardedID: BoardID = "guarded"

        weak var weakMotherboard: Motherboard?
        weak var weakGuardedBoard: GuardedBoard?

        autoreleasepool {
            let producer = BoardProducer()
            producer.registerGatewayBoard(guardedID) { identifier in
                StuckGatewayBoard(identifier: identifier)
            }

            let guardedBoard = GuardedBoard(identifier: guardedID)
            let motherboard = Motherboard(boardProducer: producer, boards: [guardedBoard])

            weakMotherboard = motherboard
            weakGuardedBoard = guardedBoard

            // The gateway never completes, so this activation stays pending forever.
            motherboard.activateBoard(identifier: guardedID, withOption: "payload")

            XCTAssertEqual(guardedBoard.activationCount, 0, "Gate is still pending")
        }

        XCTAssertNil(weakMotherboard, "Motherboard leaked through the pending gateway activation")
        XCTAssertNil(weakGuardedBoard, "Guarded board leaked through the pending gateway activation")
    }
}
