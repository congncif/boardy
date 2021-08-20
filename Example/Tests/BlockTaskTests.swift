//
//  BlockTaskTests.swift
//  Boardy_Tests
//
//  Created by NGUYEN CHI CONG on 8/20/21.
//  Copyright © 2021 [iF] Solution. All rights reserved.
//

import Boardy
import XCTest

class BlockTaskTests: XCTestCase {
    var motherboard: Motherboard!

    override func setUpWithError() throws {
        motherboard = Motherboard()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBlockTask() throws {
        let blockTask = BlockTaskBoard<String, String>(identifier: "block-task") { _, input, completion in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                completion(.success(input))
            }
        }

        motherboard.installBoard(blockTask)

        let expectation = self.expectation(description: "block-task-expectation")
        var result: String?
        let input: String = "ABC"

        let parameter = BlockTaskParameter<String, String>(input: input)
            .onSuccess { _, output in
                result = output
            }
            .onCompletion { _ in
                expectation.fulfill()
            }

        let expectation2 = self.expectation(description: "block-task-expectation-2")
        var result2: String?
        let input2: String = "ABC2"

        let parameter2 = BlockTaskParameter<String, String>(input: input2)
            .onSuccess { _, output in
                result2 = output
            }
            .onCompletion { _ in
                expectation2.fulfill()
            }

        motherboard.activateBoard(.target("block-task", parameter))
        motherboard.activateBoard(.target("block-task", parameter2))

        waitForExpectations(timeout: 3, handler: nil)

        XCTAssertEqual(result, input)
        XCTAssertEqual(result2, input2)
    }
}
