//
//  CombineFlowTests.swift
//  Boardy_Tests
//
//  Created by NGUYEN CHI CONG on 10/7/21.
//  Copyright © 2021 [iF] Solution. All rights reserved.
//

@testable import Boardy
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

        let expectation = expectation(description: "test-expectation")

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

    func testDoNextPreservesBoxedNilInIdentifierOrder() throws {
        var receivedBatches: [[Any]] = []
        let flow = OutputCombinedFlow(matchedIdentifiers: ["b1", "b2"]) { values in
            receivedBatches.append(values)
        }
        let nilString: String? = nil

        flow.doNext(with: OutputModel(identifier: "b1", data: nilString))
        flow.doNext(with: OutputModel(identifier: "b2", data: 101))

        XCTAssertEqual(receivedBatches.count, 1)
        let values = try XCTUnwrap(receivedBatches.first)
        XCTAssertEqual(values.count, 2)
        let nilValue = Mirror(reflecting: values[0])
        XCTAssertEqual(nilValue.displayStyle, .optional)
        XCTAssertTrue(nilValue.children.isEmpty)
        XCTAssertEqual(values[1] as? Int, 101)
    }

    func testHandlerCanReenterFlowWithSecondBatch() throws {
        let secondInvocation = expectation(description: "handler receives the reentrant batch")
        var invocationCount = 0
        var secondBatch: [Any]?
        let flowStorage = Locked<OutputCombinedFlow?>(nil)
        defer { flowStorage.withLock { $0 = nil } }

        let flow = OutputCombinedFlow(matchedIdentifiers: ["b1", "b2"]) { values in
            invocationCount += 1

            if invocationCount == 1 {
                let reentrantFlow = flowStorage.withLock { $0 }
                reentrantFlow?.doNext(with: OutputModel(identifier: "b1", data: "second"))
                reentrantFlow?.doNext(with: OutputModel(identifier: "b2", data: 202))
            } else if invocationCount == 2 {
                secondBatch = values
                secondInvocation.fulfill()
            }
        }
        flowStorage.withLock { $0 = flow }

        DispatchQueue.global(qos: .userInitiated).async {
            let backgroundFlow = flowStorage.withLock { $0 }
            backgroundFlow?.doNext(with: OutputModel(identifier: "b1", data: "first"))
            backgroundFlow?.doNext(with: OutputModel(identifier: "b2", data: 101))
        }

        wait(for: [secondInvocation], timeout: 1)

        XCTAssertEqual(invocationCount, 2)
        let values = try XCTUnwrap(secondBatch)
        XCTAssertEqual(values[0] as? String, "second")
        XCTAssertEqual(values[1] as? Int, 202)
    }
}
