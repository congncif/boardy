//
//  BlockTaskTests.swift
//  Boardy_Tests
//
//  Created by NGUYEN CHI CONG on 8/20/21.
//  Copyright © 2021 [iF] Solution. All rights reserved.
//

@testable import Boardy
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
        let blockTask = BlockTaskBoard<String, String>(identifier: "block-task", executingType: .onlyResult) { _, input, completion in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                completion(.success(input))
            }
        }

        motherboard.installBoard(blockTask)

        let expectation = self.expectation(description: "block-task-expectation")
        var result: String?
        let input: String = "ABC"
        var status: TaskCompletionStatus?

        let parameter = BlockTaskParameter<String, String>(input: input)
            .onSuccess { _, output in
                result = output
            }
            .onCompletion { newStatus in
                status = newStatus
                expectation.fulfill()
            }

        let expectation2 = self.expectation(description: "block-task-expectation-2")
        var result2: String?
        let input2: String = "ABC2"
        var status2: TaskCompletionStatus?

        let parameter2 = BlockTaskParameter<String, String>(input: input2)
            .onSuccess { _, output in
                result2 = output
            }
            .onCompletion { newStatus in
                status2 = newStatus
                expectation2.fulfill()
            }

        motherboard.activateBoard(.target("block-task", parameter))
        motherboard.activateBoard(.target("block-task", parameter2))

        waitForExpectations(timeout: 3, handler: nil)

        XCTAssertEqual(status, .done)
        XCTAssertEqual(result, input)

        XCTAssertEqual(status2, .done)
        XCTAssertEqual(result2, input)
    }

    func testBlockTaskLatest() throws {
        let blockTask = BlockTaskBoard<String, String>(identifier: "block-task", executingType: .latest) { _, input, completion in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                completion(.success(input))
            }
        }

        motherboard.installBoard(blockTask)

        let expectation = self.expectation(description: "block-task-expectation")
        var result: String?
        let input: String = "ABC"
        var status: TaskCompletionStatus?

        let parameter = BlockTaskParameter<String, String>(input: input)
            .onSuccess { _, output in
                result = output
            }
            .onCompletion { newStatus in
                status = newStatus
                expectation.fulfill()
            }

        let expectation2 = self.expectation(description: "block-task-expectation-2")
        var result2: String?
        let input2: String = "ABC2"
        var status2: TaskCompletionStatus?

        let parameter2 = BlockTaskParameter<String, String>(input: input2)
            .onSuccess { _, output in
                result2 = output
            }
            .onCompletion { newStatus in
                status2 = newStatus
                expectation2.fulfill()
            }

        motherboard.activateBoard(.target("block-task", parameter))
        motherboard.activateBoard(.target("block-task", parameter2))

        waitForExpectations(timeout: 3, handler: nil)

        XCTAssertEqual(status, .cancelled)
        XCTAssertNil(result)

        XCTAssertEqual(status2, .done)
        XCTAssertEqual(result2, input2)
    }

    func testBlockTaskDefault() throws {
        let blockTask = BlockTaskBoard<String, String>(identifier: "block-task", executingType: .default) { _, input, completion in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                completion(.success(input))
            }
        }

        motherboard.installBoard(blockTask)

        let expectation = self.expectation(description: "block-task-expectation")
        var result: String?
        let input: String = "ABC"
        var status: TaskCompletionStatus?

        let parameter = BlockTaskParameter<String, String>(input: input)
            .onSuccess { _, output in
                result = output
            }
            .onCompletion { newStatus in
                status = newStatus
                expectation.fulfill()
            }

        let expectation2 = self.expectation(description: "block-task-expectation-2")
        var result2: String?
        let input2: String = "ABC2"
        var status2: TaskCompletionStatus?

        let parameter2 = BlockTaskParameter<String, String>(input: input2)
            .onSuccess { _, output in
                result2 = output
            }
            .onCompletion { newStatus in
                status2 = newStatus
                expectation2.fulfill()
            }

        motherboard.activateBoard(.target("block-task", parameter))
        motherboard.activateBoard(.target("block-task", parameter2))

        waitForExpectations(timeout: 3, handler: nil)

        XCTAssertEqual(status, .done)
        XCTAssertEqual(result, input)

        XCTAssertEqual(status2, .done)
        XCTAssertEqual(result2, input2)
    }

    func testBlockTaskQueue() throws {
        var blockTask: BlockTaskBoard<String, String>? = BlockTaskBoard<String, String>(identifier: "block-task", executingType: .queue) { _, input, completion in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                completion(.success(input))
            }
        }

        motherboard.installBoard(blockTask!)

        let expectation = self.expectation(description: "block-task-expectation")
        var result: String?
        let input: String = "ABC"
        var status: TaskCompletionStatus?

        let parameter = BlockTaskParameter<String, String>(input: input)
            .onSuccess { _, output in
                result = output
            }
            .onCompletion { newStatus in
                status = newStatus
                expectation.fulfill()
            }

        let expectation2 = self.expectation(description: "block-task-expectation-2")
        var result2: String?
        let input2: String = "ABC2"
        var status2: TaskCompletionStatus?

        let parameter2 = BlockTaskParameter<String, String>(input: input2)
            .onSuccess { _, output in
                result2 = output
            }
            .onCompletion { newStatus in
                status2 = newStatus
                expectation2.fulfill()
            }

        motherboard.activateBoard(.target("block-task", parameter))
        motherboard.activateBoard(.target("block-task", parameter2))

        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) { [weak motherboard] in
            motherboard?.removeBoard(withIdentifier: "block-task")
            blockTask = nil
        }

        waitForExpectations(timeout: 3, handler: nil)

        XCTAssertEqual(status, .done)
        XCTAssertEqual(result, input)

        XCTAssertEqual(status2, .cancelled)
        XCTAssertNil(result2)
    }

    func testConcurrentExecuting() {
        var blockTask: BlockTaskBoard<String, String>? = BlockTaskBoard<String, String>(identifier: "block-task", executingType: .concurrent(max: 2)) { _, input, completion in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                completion(.success(input))
            }
        }
        motherboard.installBoard(blockTask!)

        let expectation = self.expectation(description: "block-task-expectation")
        var result: String?
        let input: String = "ABC"
        var status: TaskCompletionStatus?

        let parameter = BlockTaskParameter<String, String>(input: input)
            .onSuccess { _, output in
                result = output
            }
            .onCompletion { newStatus in
                status = newStatus
                expectation.fulfill()
            }

        let expectation2 = self.expectation(description: "block-task-expectation-2")
        var result2: String?
        let input2: String = "ABC2"
        var status2: TaskCompletionStatus?

        let parameter2 = BlockTaskParameter<String, String>(input: input2)
            .onSuccess { _, output in
                result2 = output
            }
            .onCompletion { newStatus in
                status2 = newStatus
                expectation2.fulfill()
            }

        let expectation3 = self.expectation(description: "block-task-expectation-3")
        var result3: String?
        let input3: String = "ABC3"
        var status3: TaskCompletionStatus?

        let parameter3 = BlockTaskParameter<String, String>(input: input3)
            .onSuccess { _, output in
                result3 = output
            }
            .onCompletion { newStatus in
                status3 = newStatus
                expectation3.fulfill()
            }

        motherboard.activateBoard(.target("block-task", parameter))
        motherboard.activateBoard(.target("block-task", parameter2))
        motherboard.activateBoard(.target("block-task", parameter3))

//        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) { [weak motherboard] in
//            motherboard?.removeBoard(withIdentifier: "block-task")
//            blockTask = nil
//        }

        waitForExpectations(timeout: 3, handler: nil)

        XCTAssertEqual(status, .done)
        XCTAssertEqual(result, input)

        XCTAssertEqual(status2, .done)
        XCTAssertEqual(result2, input2)

        XCTAssertEqual(status3, .done)
        XCTAssertEqual(result3, input3)
    }
}
