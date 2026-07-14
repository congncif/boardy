//
//  BarrierTests.swift
//  Boardy_Tests
//
//  Created by NGUYEN CHI CONG on 8/28/21.
//  Copyright © 2021 [iF] Solution. All rights reserved.
//

@testable import Boardy
import UIKit
import XCTest

class MockRequiredBoard: Board, GuaranteedBoard, GuaranteedOutputSendingBoard {
    typealias InputType = Int
    typealias OutputType = String

    func activate(withGuaranteedInput input: InputType) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.sendOutput(String(input))
        }
    }
}

class ClientBoard: Board, ActivatableBoard {
    var input: Any?

    func activate(withOption option: Any?) {
        input = option
    }
}

class BarrierTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBarrierBoard() throws {
        let requiredBoard = MockRequiredBoard(identifier: "required-board")
        let client1Board = ClientBoard(identifier: "client-1")
        let client2Board = ClientBoard(identifier: "client-2")
        let client3Board = ClientBoard(identifier: "client-3")
        let barrierBoard = BarrierBoard<String>(identifier: "barrier")

        let motherboard: FlowMotherboard = Motherboard(boards: [requiredBoard, client1Board, client2Board, client3Board, barrierBoard])

        motherboard.activation("barrier", with: BarrierBoard<String>.Action.self)
            .activate(with: .wait { [unowned motherboard] value in
                motherboard.activateBoard(identifier: "client-1", withOption: value)
            })

        motherboard.activation("barrier", with: BarrierBoard<String>.Action.self)
            .activate(with: .wait { [unowned motherboard] value in
                motherboard.activateBoard(identifier: "client-2", withOption: value)
            })

        motherboard.activation("barrier", with: BarrierBoard<String>.Action.self)
            .activate(with: .wait { [unowned motherboard] value in
                motherboard.activateBoard(identifier: "client-3", withOption: value)
            })

        motherboard.matchedFlow("required-board", with: String.self).addTarget(motherboard) { mainboard, value in
            mainboard.activation("barrier", with: BarrierBoard<String>.Action.self).activate(with: .overcome(value))
//            mainboard.activation("barrier", with: BarrierBoard<String>.Action.self).activate(with: .cancel)
        }

        let expectation = expectation(description: "expectation")

        motherboard.matchedFlow("required-board").addTarget(self) { _, _ in
            expectation.fulfill()
        }

        XCTAssertEqual(motherboard.boards.count, 5) // total 5 included Barrier

        motherboard.activateBoard(identifier: "required-board", withOption: 123)

        waitForExpectations(timeout: 3, handler: nil)

        XCTAssertEqual(client1Board.input as? String, "123")
        XCTAssertEqual(client2Board.input as? String, "123")
        XCTAssertEqual(client3Board.input as? String, "123")

//        XCTAssertNil(client1Board.input)
//        XCTAssertNil(client2Board.input)
//        XCTAssertNil(client3Board.input)

        XCTAssertEqual(motherboard.boards.count, 4) // Barrier removed
    }

    func testMissingGatewayDoesNotInstallPhantomBarrier() {
        let client = ClientBoard(identifier: "client")
        let motherboard = Motherboard(boards: [client])

        motherboard.activateBoard(identifier: client.identifier, withOption: "value")

        XCTAssertEqual(client.input as? String, "value")
        XCTAssertEqual(motherboard.boards.count, 1)
        XCTAssertTrue(motherboard.boards.first === client)
    }

    func testConfigurePopoverAnchorsActionSheetToSourceView() throws {
        let sourceView = UIView(frame: CGRect(x: 0, y: 0, width: 240, height: 120))
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        AlertBoard.configurePopover(for: alertController, sourceView: sourceView)

        let popover = try XCTUnwrap(alertController.popoverPresentationController)
        XCTAssertTrue(popover.sourceView === sourceView)
        XCTAssertEqual(
            popover.sourceRect,
            CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.midY, width: 0, height: 0)
        )
        XCTAssertEqual(popover.permittedArrowDirections, [])
    }

    func testConfigurePopoverLeavesAlertWithoutPopoverConfiguration() {
        let sourceView = UIView(frame: CGRect(x: 0, y: 0, width: 240, height: 120))
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)

        AlertBoard.configurePopover(for: alertController, sourceView: sourceView)

        XCTAssertNil(alertController.popoverPresentationController)
    }
}
