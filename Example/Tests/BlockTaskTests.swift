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
        let blockTask = BlockTaskBoard<String, String>(identifier: "block-task", executingType: .onlyResult, executor: { _, input, completion in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                completion(.success(input))
            }
            return BlockTaskCanceler.none
        })

        motherboard.installBoard(blockTask)

        let expectation = expectation(description: "block-task-expectation")
        var result: String?
        let input = "ABC"
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
        let input2 = "ABC2"
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
        var invokedCancelCount = 0
        var invokedCancelParameters: [String] = []

        let blockTask = BlockTaskBoard<String, String>(identifier: "block-task", executingType: .latest, executor: { _, input, completion in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                completion(.success(input))
            }
            return .default {
                invokedCancelCount += 1
                invokedCancelParameters.append(input)
            }
        })

        motherboard.installBoard(blockTask)

        let expectation = expectation(description: "block-task-expectation")
        var result: String?
        let input = "ABC"
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
        let input2 = "ABC2"
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak motherboard] in
            motherboard?.activateBoard(.target("block-task", parameter2))
        }

        waitForExpectations(timeout: 3, handler: nil)

        XCTAssertEqual(status, .cancelled)
        XCTAssertNil(result)
        XCTAssertEqual(invokedCancelCount, 1)
        XCTAssertEqual(invokedCancelParameters.first, input)

        XCTAssertEqual(status2, .done)
        XCTAssertEqual(result2, input2)
    }

    func testBlockTaskDefault() throws {
        let blockTask = BlockTaskBoard<String, String>(identifier: "block-task", executingType: .default, executor: { _, input, completion in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                completion(.success(input))
            }
            return .none
        })

        motherboard.installBoard(blockTask)

        let expectation = expectation(description: "block-task-expectation")
        var result: String?
        let input = "ABC"
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
        let input2 = "ABC2"
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
        var blockTask: BlockTaskBoard<String, String>? = BlockTaskBoard<String, String>(identifier: "block-task", executingType: .queue, executor: { _, input, completion in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                completion(.success(input))
            }
            return .none
        })

        motherboard.installBoard(blockTask!)

        let expectation = expectation(description: "block-task-expectation")
        var result: String?
        let input = "ABC"
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
        let input2 = "ABC2"
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
        let blockTask: BlockTaskBoard<String, String>? = BlockTaskBoard<String, String>(identifier: "block-task", executingType: .concurrent(max: 2), executor: { _, input, completion in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                completion(.success(input))
            }
            return .none
        })
        motherboard.installBoard(blockTask!)

        let expectation = expectation(description: "block-task-expectation")
        var result: String?
        let input = "ABC"
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
        let input2 = "ABC2"
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
        let input3 = "ABC3"
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

    func testBlockTaskInputAdapter() throws {
        let blockTask = BlockTaskBoard<String, String>(identifier: "block-task", executingType: .default, executor: { _, input, completion in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                completion(.success(input))
            }
            return .none
        })

        motherboard.installBoard(blockTask)

        let expectation = expectation(description: #function)
        var result: String?
        let input = "ABC"

        (motherboard as FlowManageable).matchedFlow("block-task", with: String.self)
            .handle { value in
                result = value
            }

        (motherboard as FlowManageable).completionFlow("block-task").handle { _ in
            expectation.fulfill()
        }

        (motherboard as MotherboardType)
            .blockActivation("block-task", with: BlockTaskParameter<String, String>.self)
            .activate(with: input)

        waitForExpectations(timeout: 3, handler: nil)

        XCTAssertEqual(result, input)
    }
}
