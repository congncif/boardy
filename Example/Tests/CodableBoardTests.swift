//
//  CodableBoardTests.swift
//  Boardy_Tests
//
//  Created by NGUYEN CHI CONG on 11/29/21.
//  Copyright © 2021 [iF] Solution. All rights reserved.
//

import Boardy
import XCTest

private struct TestData: Encodable, Decodable {
    let strValue: String
    let intValue: Int
}

private class TestBoard: Board, GuaranteedBoard, GuaranteedOutputSendingBoard {
    func activate(withGuaranteedInput input: TestData) {
        sendEncodedOutput(input)
    }

    typealias OutputType = TestData
    typealias InputType = TestData
}

class CodableBoardTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCodableData() throws {
        let senderBoard = TestBoard(identifier: "sender")
        let receiverBoard = TestBoard(identifier: "receiver")
        let mainboard = Motherboard(boards: [senderBoard, receiverBoard])

        mainboard.registerFlowSteps("sender" ->> "receiver")

        var data: Data?
        mainboard.registerGuaranteedFlow(matchedIdentifiers: "receiver", target: self) { _, output in
            data = output
        }

        senderBoard.activate(withGuaranteedInput: TestData(strValue: "String", intValue: 100))

        XCTAssertNotNil(data)

        let decoder = JSONDecoder()
        let output = try? decoder.decode(TestData.self, from: data!)
        XCTAssertEqual(output?.strValue, "String")
        XCTAssertEqual(output?.intValue, 100)
    }

    func testDictionaryData() throws {
        let receiverBoard = TestBoard(identifier: "receiver")
        let mainboard = Motherboard(boards: [receiverBoard])

        var data: Data?
        mainboard.registerGuaranteedFlow(matchedIdentifiers: "receiver", target: self) { _, output in
            data = output
        }

        mainboard.activateBoard(identifier: "receiver", withOption: [
            "strValue": "String",
            "intValue": 100,
        ])

        XCTAssertNotNil(data)

        let decoder = JSONDecoder()
        let output = try? decoder.decode(TestData.self, from: data!)
        XCTAssertEqual(output?.strValue, "String")
        XCTAssertEqual(output?.intValue, 100)
    }
}
