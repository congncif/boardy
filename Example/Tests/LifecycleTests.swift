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

    func testBoardShouldBeReleasedAfterCompleted() throws {
        let motherboard: FlowMotherboard = Motherboard(boards: [SingleBoard(identifier: "1"), ContiBoard(identifier: "2", motherboard: Motherboard())])
        weak var singleBoard = motherboard.boards.first { $0.identifier == "1" }
        weak var contiBoard = motherboard.boards.first { $0.identifier == "2" }

        XCTAssertNotNil(singleBoard)
        XCTAssertNotNil(contiBoard)

        contiBoard?.completer("1").complete()
//        singleBoard?.complete()
        XCTAssertNil(singleBoard)

        motherboard.completer("2").complete()
        XCTAssertNil(contiBoard)
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
