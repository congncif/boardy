//
//  ResultBoardTests.swift
//  Boardy_Tests
//
//  Created by NGUYEN CHI CONG on 9/5/21.
//  Copyright © 2021 [iF] Solution. All rights reserved.
//

import Boardy
import XCTest

class ResultBoardTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let board = ResultTaskBoard<String, String, Error>(identifier: "result-board") { input, callback in
            callback(.progress)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                callback(.success(input))
            }
        }

        var isLoading = false
        var results: String?

        let expectation = expectation(description: "expectation")

        let motherboard: FlowMotherboard = Motherboard(boards: [board])

        motherboard.matchedFlow("result-board", with: BoardResult<String, Error>.self).handle { result in
            switch result {
            case let .success(data):
                results = data
                isLoading = false

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    expectation.fulfill()
                }
            case .progress:
                isLoading = true
            default:
                isLoading = false

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    expectation.fulfill()
                }
            }
        }

        motherboard.activation("result-board", with: String.self).activate(with: "DATA")
        XCTAssertEqual(isLoading, true)
        waitForExpectations(timeout: 4, handler: nil)
        XCTAssertEqual(isLoading, false)
        XCTAssertEqual(results, "DATA")
        XCTAssertEqual(motherboard.boards.count, 0)
    }

    /// `guard !isActive` and `isActive = true` are two separate operations on the flag, so two
    /// concurrent callers can both observe an inactive board and both run the executor.
    func testConcurrentActivationRunsTheExecutorExactlyOnce() {
        let lock = NSLock()
        var executions = 0

        // This executor never calls back, so the board stays active for the whole test.
        let board = ResultTaskBoard<Int, Int, Error>(identifier: "result-board-race") { _, _ in
            lock.lock()
            executions += 1
            lock.unlock()
        }

        DispatchQueue.concurrentPerform(iterations: 100) { _ in
            board.activate(withGuaranteedInput: 1)
        }

        XCTAssertEqual(executions, 1)
    }
}
