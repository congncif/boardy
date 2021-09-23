//
//  InteractableTests.swift
//  Boardy_Tests
//
//  Created by NGUYEN CHI CONG on 8/28/21.
//  Copyright © 2021 [iF] Solution. All rights reserved.
//

import Boardy
import XCTest

class MockInteractableBoard: Board, ActivatableBoard, InteractableBoard {
    var cmd: Any?

    func activate(withOption option: Any?) {}

    func interact(command: Any?) {
        self.cmd = command
    }
}

class InteractableTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInteractableBoard() throws {
        let board = MockInteractableBoard(identifier: "board-to-test")
        let otherBoard = TestBoard(identifier: "other-board")
        let motherboard: FlowMotherboard = Motherboard(boards: [board, otherBoard])

        let expectedValue = "COMMAND"
        motherboard.interaction("board-to-test").send(command: expectedValue)
        XCTAssertEqual(expectedValue, board.cmd as? String)

        let otherValue = "OTHER"
        otherBoard.interaction("board-to-test").send(command: otherValue)
        XCTAssertEqual(otherValue, board.cmd as? String)
    }
}

private final class TestBoard: Board, ActivatableBoard {
    func activate(withOption option: Any?) {
        sendToMotherboard()
    }
}
