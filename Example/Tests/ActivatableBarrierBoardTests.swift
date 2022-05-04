//
//  ActivatableBarrierBoardTests.swift
//  Boardy_Tests
//
//  Created by CONGNC7 on 04/05/2022.
//  Copyright © 2022 [iF] Solution. All rights reserved.
//

@testable import Boardy
import XCTest

final class BarrierAuthBoard: Board, GuaranteedBoard {
    typealias InputType = Void

    var activated: Bool = false
    var stubIsDone: Bool = true

    func activate(withGuaranteedInput _: Void) {
        if activated {
            complete(stubIsDone)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                guard let self = self else { return }
                self.activated = true
                self.complete(self.stubIsDone)
            }
        }
    }
}

final class BarrierSutBoard: Board, GuaranteedBoard {
    typealias InputType = String

    var activatedValue: String?
    var stubActivationBarrier: ActivationBarrier?

    func activationBarrier(withOption _: Any?) -> ActivationBarrier? {
        stubActivationBarrier
    }

    func activate(withGuaranteedInput input: String) {
        activatedValue = input
    }
}

class ActivatableBarrierBoardTests: XCTestCase {
    var sutMotherboard: Motherboard!
    var sutBoard: BarrierSutBoard!
    var sut2Board: BarrierSutBoard!
    var authBoard: BarrierAuthBoard!

    override func setUpWithError() throws {
        sutBoard = BarrierSutBoard(identifier: sampleBarrierSutID)
        sut2Board = BarrierSutBoard(identifier: sampleBarrierSutID2)
        authBoard = BarrierAuthBoard(identifier: sampleBarrierAuthID)

        sutMotherboard = Motherboard(registrationsBuilder: { _ in
            sutBoard
            authBoard
            sut2Board
        })
    }

    override func tearDownWithError() throws {}

    func testActivationBarrierDone() throws {
        let activation = sutBoard.activation(sampleBarrierAuthID, with: Void.self)
        sutBoard.stubActivationBarrier = activation.barrier()
        sut2Board.stubActivationBarrier = activation.barrier()

        let expectation = expectation(description: #function)

        sutMotherboard.activateBoard(identifier: sampleBarrierSutID, withOption: sampleInputValue)
        sutMotherboard.activateBoard(identifier: sampleBarrierSutID2, withOption: sampleInputValue)

        let barrierBoard = sutMotherboard.getBoard(identifier: sampleBarrierAuthID.appending("___PRIVATE_BARRIER___")) as? ActivatableBarrierBoard
        XCTAssertNotNil(barrierBoard)
        XCTAssertTrue(barrierBoard?.isProcessing == true)
        XCTAssertEqual(barrierBoard?.pendingActivations.count, 2)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)

        XCTAssertTrue(authBoard.activated)
        XCTAssertEqual(sutBoard.activatedValue, sampleInputValue)
        XCTAssertEqual(sut2Board.activatedValue, sampleInputValue)
    }

    func testActivationBarrierNotDone() throws {
        let activation = sutBoard.activation(sampleBarrierAuthID, with: Void.self)
        sutBoard.stubActivationBarrier = activation.barrier()
        sut2Board.stubActivationBarrier = activation.barrier()

        authBoard.stubIsDone = false

        let expectation = expectation(description: #function)

        sutMotherboard.activateBoard(identifier: sampleBarrierSutID, withOption: sampleInputValue)
        sutMotherboard.activateBoard(identifier: sampleBarrierSutID2, withOption: sampleInputValue)

        let barrierBoard = sutMotherboard.getBoard(identifier: sampleBarrierAuthID.appending("___PRIVATE_BARRIER___")) as? ActivatableBarrierBoard
        XCTAssertNotNil(barrierBoard)
        XCTAssertTrue(barrierBoard?.isProcessing == true)
        XCTAssertEqual(barrierBoard?.pendingActivations.count, 2)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)

        XCTAssertTrue(authBoard.activated)
        XCTAssertEqual(sutBoard.activatedValue, nil)
        XCTAssertEqual(sut2Board.activatedValue, nil)
    }
}

let sampleBarrierAuthID: BoardID = "id.board.barrier"
let sampleBarrierSutID: BoardID = "id.board.sut"
let sampleBarrierSutID2: BoardID = "id.board.sut2"
let sampleInputValue = "SAMPLE_INPUT_VALUE"
