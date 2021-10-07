//
//  CombineFlowTests.swift
//  Boardy_Tests
//
//  Created by NGUYEN CHI CONG on 10/7/21.
//  Copyright © 2021 [iF] Solution. All rights reserved.
//

import Boardy
import XCTest

private final class SutBoard<Input>: Board, GuaranteedBoard {
    typealias InputType = Input

    func activate(withGuaranteedInput input: InputType) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.sendToMotherboard(data: input)
        }
    }
}

class CombineFlowTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCombined2FlowHappyCase() throws {
        let board1 = SutBoard<String?>(identifier: "b1")
        let board2 = SutBoard<Int>(identifier: "b2")

        let motherboard: FlowMotherboard = Motherboard(boards: [board1, board2])

        let expectation = self.expectation(description: "test-expectation")

        var resultStr: String?
        var resultInt: Int?

        motherboard.registerCombinedFlow(motherboard.matchedFlow("b1", with: String?.self).specifications,
                                         motherboard.matchedFlow("b2", with: Int.self).specifications) { str, integer in
            resultInt = integer
            resultStr = str

            expectation.fulfill()
        }

        motherboard.activation("b1", with: String?.self).activate(with: nil)
        motherboard.activation("b2", with: Int.self).activate(with: 101)

        waitForExpectations(timeout: 1.5, handler: nil)

        XCTAssertEqual(resultStr, nil)
        XCTAssertEqual(resultInt, 101)
    }
}
