import Boardy
import CwlPreconditionTesting
import XCTest

final class FlowTests: XCTestCase {
    private let testId: BoardID = "test"
    private let testId2: BoardID = "test2"
    private let testId3: BoardID = "test3"

    private var testBoard: TestBoard!
    private var motherboard: FlowMotherboard!

    override func setUp() {
        super.setUp()

        testBoard = TestBoard(identifier: testId)
        motherboard = Motherboard(boards: [testBoard])
    }

    override func tearDown() {
        super.tearDown()
        motherboard.resetFlows()
    }

    func test_chainFlow() {
        var intResult: (FlowTests, Int)?
        var stringResult: (FlowTests, String)?
        var voidResult: (FlowTests, Any?)?

        motherboard.registerChainFlow(matchedIdentifiers: [testId], target: self)
            .handle(outputType: Int.self) {
                intResult = ($0, $1)
            }
            .handle(outputType: String.self) {
                stringResult = ($0, $1)
            }
            .eventuallyHandle {
                voidResult = ($0, $1)
            }

        testBoard.sendToMotherboard(data: 11)
        XCTAssertEqual(intResult?.0, self)
        XCTAssertEqual(intResult?.1, 11)

        testBoard.sendToMotherboard(data: "text")
        XCTAssertEqual(stringResult?.0, self)
        XCTAssertEqual(stringResult?.1, "text")

        testBoard.sendToMotherboard()
        XCTAssertEqual(voidResult?.0, self)
        XCTAssertNil(voidResult?.1)
    }

    func test_guaranteedFlow() throws {
        var result: (FlowTests, String)?

        motherboard.registerGuaranteedFlow(matchedIdentifiers: [testId], target: self, uniqueOutputType: String.self) {
            result = ($0, $1)
        }

        testBoard.sendToMotherboard(data: "text")

        let validResult = try XCTUnwrap(result)
        XCTAssertEqual(validResult.0, self)
        XCTAssertEqual(validResult.1, "text")

        var assertionCalled = false
        var assertionPassed = false

        let exceptionGuard: CwlPreconditionTesting.BadInstructionException? = CwlPreconditionTesting.catchBadInstruction { [unowned self] in
            assertionCalled = true

            self.testBoard.sendToMotherboard()

            assertionPassed = true
        }

        XCTAssertNotNil(exceptionGuard)
        XCTAssertTrue(assertionCalled)
        XCTAssertFalse(assertionPassed)
    }

    func test_completeFlow() {
        XCTAssertEqual(motherboard.boards.count, 1)
        testBoard.complete(true)
        XCTAssertEqual(motherboard.boards.count, 0)
    }

    func test_flowSteps() {
        let testBoard2 = Test2Board(identifier: testId2)
        let testBoard3 = Test3Board(identifier: testId3)

        motherboard.addBoard(testBoard2)
        motherboard.addBoard(testBoard3)

        XCTAssertEqual(motherboard.boards.count, 3)

        let beforeFlowsNumber = motherboard.flows.count
        motherboard.registerFlowSteps(testId ->> testId2 ->> testId3)
        XCTAssertEqual(motherboard.flows.count, beforeFlowsNumber + 2)

        testBoard.activate(withOption: nil)
        XCTAssertEqual(testBoard3.activatedCount, 1)
    }

    func test_ioFlowHandling() {
        let expectedValue = "OUTPUT"
        let outBoard = OutputBoard(identifier: "out-test", result: expectedValue)
        motherboard.addBoard(outBoard)

        let expectation = expectation(description: "flow-test-expectation")
        var result: String?

        motherboard.matchedFlow("out-test").handle { output in
            result = output as? String
            expectation.fulfill()
        }

        motherboard.activation("out-test").activate(with: "Input" as Any)

        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertEqual(result, expectedValue)
    }

    func test_ioFlowNextActivation() {
        let value = "VALUE"
        let outBoard = OutputBoard(identifier: "out-board", result: value)
        let inBoard = InBoard(identifier: "in-board")

        motherboard.addBoard(outBoard)
        motherboard.addBoard(inBoard)

        XCTAssertEqual(motherboard.boards.count, 3)

        let expectation = expectation(description: "flow-test-expectation")
        var result: String?

        motherboard.matchedFlow("out-board", with: String.self).activate(motherboard.activation("in-board", with: String.self))

        motherboard.matchedFlow("in-board", with: String.self).handle { output in
            result = output
            expectation.fulfill()
        }

        motherboard.activation("out-board").activate()

        waitForExpectations(timeout: 3, handler: nil)

        XCTAssertEqual(result, value)
    }

    func test_ioCompletionFlow() {
        let boardID: BoardID = "completion-board"
        let board = CompletionBoard(identifier: boardID)

        let otherBoard = InBoard(identifier: "other-board")
        motherboard.addBoard(board)

        let expectation = expectation(description: "test-expectation")
        var result: String?

        motherboard.matchedFlow(boardID, with: String.self).handle { value in
            result = value
        }

        motherboard.completionFlow(boardID).handle { _ in
            expectation.fulfill()
        }

        otherBoard.complete(true)
        motherboard.activation(boardID, with: String.self).activate(with: "VALUE")

        waitForExpectations(timeout: 3, handler: nil)

        XCTAssertEqual(result, "VALUE")
    }

    func test_ioActionFlow() {
        let id: BoardID = "sut"
        let sutBoard = SutBoard(identifier: id)
        motherboard.addBoard(sutBoard)

        let expectation = expectation(description: "test-expectation")
        var result: Action?

        motherboard.actionFlow(id, with: Action.self).handle { action in
            result = action
            expectation.fulfill()
        }

        sutBoard.sendFlowAction(Action.ok)
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(result, Action.ok)
    }

    func test_ioActionFlowKeepsBroadcastSemantics() {
        let sutID: BoardID = "sut"
        let otherID: BoardID = "other"
        let otherBoard = SutBoard(identifier: otherID)
        motherboard.addBoard(SutBoard(identifier: sutID))
        motherboard.addBoard(otherBoard)

        let expectation = expectation(description: #function)
        var result: Action?

        motherboard.actionFlow(sutID, with: Action.self).handle { action in
            result = action
            expectation.fulfill()
        }

        otherBoard.sendFlowAction(Action.nope)
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(result, .nope)
    }

    func test_ioActionFlowFromSourceFiltersByImmediateSource() {
        let sutID: BoardID = "sut"
        let otherID: BoardID = "other"
        let sutBoard = SutBoard(identifier: sutID)
        let otherBoard = SutBoard(identifier: otherID)
        motherboard.addBoard(sutBoard)
        motherboard.addBoard(otherBoard)

        let ignoredExpectation = expectation(description: "other action ignored")
        ignoredExpectation.isInverted = true
        var result: Action?

        motherboard.actionFlow(sutID, with: Action.self).handleFromSource { action in
            result = action
            ignoredExpectation.fulfill()
        }

        otherBoard.sendFlowAction(Action.nope)
        wait(for: [ignoredExpectation], timeout: 0.1)
        XCTAssertNil(result)

        let receivedExpectation = expectation(description: "sut action received")
        motherboard.actionFlow(sutID, with: Action.self).handleFromSource { action in
            result = action
            receivedExpectation.fulfill()
        }

        sutBoard.sendFlowAction(Action.ok)
        wait(for: [receivedExpectation], timeout: 1)
        XCTAssertEqual(result, .ok)
    }

    func test_busTransportsSnapshotWhileConnectingDuringDelivery() {
        let bus = Bus<Int>()
        var results: [Int] = []

        bus.deliver { value in
            results.append(value)
            bus.deliver { nextValue in
                results.append(nextValue * 10)
            }
        }

        bus.transport(input: 1)
        XCTAssertEqual(results, [1])

        bus.transport(input: 2)
        XCTAssertEqual(results, [1, 2, 20])
    }

    func test_activateAllBoardsWithDefaultInputContinuesAfterMissingInput() {
        let first = ActivatedInputBoard(identifier: "first")
        let second = ActivatedInputBoard(identifier: "second")
        let third = ActivatedInputBoard(identifier: "third")
        let motherboard: MotherboardType = Motherboard(boards: [first, second, third])

        motherboard.activateAllBoards(withInputs: [BoardInput<Int>(target: "first", input: 1)], defaultInput: 9)

        XCTAssertEqual(first.receivedInput as? Int, 1)
        XCTAssertEqual(second.receivedInput as? Int, 9)
        XCTAssertEqual(third.receivedInput as? Int, 9)
    }

    func test_activateAllBoardsWithMissingInputContinuesToRemainingBoards() {
        let first = ActivatedInputBoard(identifier: "first")
        let second = ActivatedInputBoard(identifier: "second")
        let third = ActivatedInputBoard(identifier: "third")
        let motherboard: MotherboardType = Motherboard(boards: [first, second, third])

        motherboard.activateAllBoards(withInputs: [BoardInput<Int>(target: "first", input: 1), BoardInput<Int>(target: "third", input: 3)])

        XCTAssertEqual(first.receivedInput as? Int, 1)
        XCTAssertNil(second.receivedInput)
        XCTAssertEqual(third.receivedInput as? Int, 3)
    }
}

private final class TestBoard: Board, ActivatableBoard {
    func activate(withOption _: Any?) {
        sendToMotherboard()
    }
}

private final class Test2Board: Board, ActivatableBoard {
    func activate(withOption _: Any?) {
        sendToMotherboard()
    }
}

private final class Test3Board: Board, ActivatableBoard {
    var activatedCount: Int = 0
    func activate(withOption _: Any?) {
        activatedCount += 1
    }
}

private final class ActivatedInputBoard: Board, ActivatableBoard {
    var receivedInput: Any?

    func activate(withOption option: Any?) {
        receivedInput = option
    }
}

private final class OutputBoard: Board, ActivatableBoard {
    let result: String?

    init(identifier: BoardID, result: String?) {
        self.result = result
        super.init(identifier: identifier)
    }

    func activate(withOption _: Any?) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.sendToMotherboard(data: self?.result)
        }
    }
}

private final class InBoard: Board, GuaranteedBoard, GuaranteedOutputSendingBoard {
    typealias InputType = String
    typealias OutputType = String

    func activate(withGuaranteedInput input: String) {
        sendOutput(input)
    }
}

private final class CompletionBoard: Board, GuaranteedBoard, GuaranteedOutputSendingBoard {
    typealias InputType = String
    typealias OutputType = String

    func activate(withGuaranteedInput input: String) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.sendOutput(input)
            self?.complete(true)
        }
    }
}

private class SutBoard: Board, ActivatableBoard {
    func activate(withOption _: Any?) {}
}

private enum Action: BoardFlowAction, Equatable {
    case ok
    case nope
}
