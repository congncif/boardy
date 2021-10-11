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
        var isLoading: Bool = false
        var results: [String?] = []
        
        let expectation = self.expectation(description: "expectation")
        
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
        
        self.waitForExpectations(timeout: 6, handler: nil)
        
        XCTAssertEqual(isLoading, false)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(motherboard.boards.count, 0)
    }
}
