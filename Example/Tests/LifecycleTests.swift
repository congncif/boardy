//
//  LifecycleTests.swift
//  Boardy_Tests
//
//  Created by NGUYEN CHI CONG on 2/4/21.
//  Copyright © 2021 [iF] Solution. All rights reserved.
//

import Boardy
import XCTest

final class ContiBoard: ContinuousBoard, ActivatableBoard {
    func activate(withOption _: Any?) {}
}

final class SingleBoard: Board, ActivatableBoard {
    func activate(withOption _: Any?) {}
}

class LifecycleTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBoardShouldBeReleasedAfterCompleted() throws {
        let motherboard: FlowMotherboard = Motherboard(boards: [SingleBoard(identifier: "1"), ContiBoard(identifier: "2", motherboard: Motherboard())])
        weak var singleBoard = motherboard.boards.first { $0.identifier == "1" }
        weak var contiBoard = motherboard.boards.first { $0.identifier == "2" }

        XCTAssertNotNil(singleBoard)
        XCTAssertNotNil(contiBoard)

        contiBoard?.completer("1").complete()
//        singleBoard?.complete()
        XCTAssertNil(singleBoard)

        motherboard.completer("2").complete()
        XCTAssertNil(contiBoard)
    }
}
