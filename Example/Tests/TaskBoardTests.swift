//
//  TaskBoardTests.swift
//  Boardy_Tests
//
//  Created by NGUYEN CHI CONG on 8/30/21.
//  Copyright © 2021 [iF] Solution. All rights reserved.
//

import Boardy
import XCTest

class TaskBoardTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        var isLoading = false
        var results: [String?] = []

        let expectation = expectation(description: "expectation")

        let board = TaskBoard<Int, String>(identifier: "test-board") { _, input, completion in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                print("🚧 \(String(input))")
                DispatchQueue.main.async {
                    completion(.success(String(input)))
                }
            }
        }
        processingHandler: { board in isLoading = board.isProcessing }
        completionHandler: { board in
            if board.isCompleted {
                expectation.fulfill()
            }
        }

        let motherboard: FlowMotherboard = Motherboard(boards: [board])

        motherboard.matchedFlow("test-board", with: String.self).handle { output in
            results.append(output)
        }

        motherboard.activation("test-board", with: Int.self).activate(with: 1)
        motherboard.activation("test-board", with: Int.self).activate(with: 2)
        motherboard.activation("test-board", with: Int.self).activate(with: 3)

        waitForExpectations(timeout: 6, handler: nil)

        XCTAssertEqual(isLoading, false)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(motherboard.boards.count, 0)
    }

    /// Claiming the activation slot must be one indivisible operation.
    ///
    /// `activate` reads the activation counter, decides the board is idle, and only then writes it
    /// back. Two concurrent callers can both read the idle value and both run the executor, which
    /// is exactly the duplicate activation the guard exists to prevent.
    func testConcurrentActivationRunsTheExecutorExactlyOnce() {
        let lock = NSLock()
        var executions = 0

        // This executor never calls its completion, so the slot stays claimed for the whole test
        // and every activation after the first one must be rejected.
        let board = TaskBoard<Int, Int>(identifier: "task-board-race") { _, _, _ in
            lock.lock()
            executions += 1
            lock.unlock()
        }

        DispatchQueue.concurrentPerform(iterations: 100) { _ in
            board.activate(withGuaranteedInput: 1)
        }

        XCTAssertEqual(executions, 1)
        XCTAssertTrue(board.isProcessing)
    }

    /// The counter must also survive concurrent release. Each executor completion decrements it,
    /// and a lost decrement would strand the board in `isProcessing` forever.
    func testConcurrentCompletionReturnsTheBoardToIdle() {
        var completions: [(Result<Int, Error>) -> Void] = []
        let lock = NSLock()

        let board = TaskBoard<Int, Int>(identifier: "task-board-release") { _, _, completion in
            lock.lock()
            completions.append(completion)
            lock.unlock()
        }

        board.activate(withGuaranteedInput: 1)
        XCTAssertEqual(completions.count, 1)

        // The same completion delivered concurrently must not drive the counter below zero.
        let completion = completions[0]
        DispatchQueue.concurrentPerform(iterations: 50) { _ in
            completion(.success(1))
        }

        XCTAssertTrue(board.isCompleted)
        XCTAssertFalse(board.isProcessing)
    }
}
