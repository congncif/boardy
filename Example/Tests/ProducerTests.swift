//
//  ProducerTests.swift
//  Boardy_Tests
//
//  Created by NGUYEN CHI CONG on 10/1/21.
//  Copyright © 2021 [iF] Solution. All rights reserved.
//

@testable import Boardy
import XCTest

private class StubBoard: Board, ActivatableBoard {
    func activate(withOption option: Any?) {}
}

class ProducerTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBoxedProducer() throws {
        var producer: BoardProducer? = BoardProducer(registrations: [])

        let boxedProducer = BoardDynamicProducerBox(producer: producer)
        XCTAssertNotNil(boxedProducer.producer)

        boxedProducer.registerBoard("add-one") { id in
            StubBoard(identifier: id)
        }

        let regBoard = producer?.produceBoard(identifier: "add-one")
        XCTAssertNotNil(regBoard)

        producer = nil
        XCTAssertNil(boxedProducer.producer)
    }
}
