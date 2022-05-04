//
//  AdapterTests.swift
//  Boardy_Tests
//
//  Created by NGUYEN CHI CONG on 8/28/21.
//  Copyright © 2021 [iF] Solution. All rights reserved.
//

import Boardy
import XCTest

class DesBoard: Board, GuaranteedBoard, GuaranteedOutputSendingBoard {
    typealias InputType = String
    typealias OutputType = String

    func activate(withGuaranteedInput input: String) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [unowned self] in
            self.sendOutput(input)
        }
    }
}

class AdapterTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAdapterBoard() throws {
        let board = DesBoard(identifier: "board-to-test")
        let adapter = AdapterBoard<DesBoard, Int, Int>(
            destination: board,
            inputMapper: { String($0) },
            outputMapper: { Int($0) ?? 0 }
        )

        let motherboard: FlowMotherboard = Motherboard(boards: [adapter])

        let expectation = self.expectation(description: "flow-test-expectation")
        var result: Int?

        (motherboard as FlowMotherboard).matchedFlow("board-to-test", with: Int.self).handle { output in
            result = output
            expectation.fulfill()
        }

        motherboard.activation("board-to-test", with: Int.self).activate(with: 1)

        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertEqual(result, 1)

        board.complete(true)
        XCTAssertEqual(motherboard.boards.count, 0)
    }
}
