import Boardy
#if canImport(CwlPreconditionTesting)
    import CwlPreconditionTesting
#endif
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

        #if canImport(CwlPreconditionTesting)
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
        #else
            throw XCTSkip("CwlPreconditionTesting is only available in the CocoaPods/Xcode test host")
        #endif
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

        waitForExpectations(timeout: hangGuardTimeout, handler: nil)

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

        waitForExpectations(timeout: hangGuardTimeout, handler: nil)

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

        waitForExpectations(timeout: hangGuardTimeout, handler: nil)

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
        waitForExpectations(timeout: hangGuardTimeout, handler: nil)
        XCTAssertEqual(result, Action.ok)
    }

    // MARK: - Bus re-entrancy

    /// `transport` iterated the stored cable array directly while `connect` appended to it, so a
    /// handler that connected to the same bus tripped Swift's exclusivity check:
    /// "Simultaneous accesses to ..., but modification requires exclusive access".
    ///
    /// Fanning out to a newly connected target from inside a handler is an ordinary thing to do,
    /// and `Bus` is fully public.
    func testBusHandlerCanConnectToTheSameBus() {
        let bus = Bus<String>()
        var received: [String] = []

        bus.connect(BusCable<String> { value in
            received.append("first:\(value)")
            if value == "one" {
                bus.connect(BusCable<String> { later in
                    received.append("second:\(later)")
                })
            }
        })

        bus.transport(input: "one")
        bus.transport(input: "two")

        // The cable added mid-transport takes effect from the next transport, not retroactively.
        XCTAssertEqual(received, ["first:one", "first:two", "second:two"])
    }

    /// A handler that invalidates its own cable must not disturb the transport in progress.
    func testBusHandlerCanInvalidateItsOwnCableDuringTransport() {
        let bus = Bus<String>()
        var received: [String] = []

        let once = BusCable<String> { received.append("once:\($0)") }
        bus.connect(once)
        bus.connect(BusCable<String> { value in
            received.append("always:\(value)")
            once.invalidate()
        })

        bus.transport(input: "one")
        bus.transport(input: "two")

        XCTAssertEqual(received, ["once:one", "always:one", "always:two"])
    }

    /// Re-entering `transport` from a handler must not trap either.
    func testBusHandlerCanReenterTransport() {
        let bus = Bus<String>()
        var received: [String] = []

        bus.connect(BusCable<String> { value in
            received.append(value)
            if value == "outer" {
                bus.transport(input: "inner")
            }
        })

        bus.transport(input: "outer")

        XCTAssertEqual(received, ["outer", "inner"])
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

private final class OutputBoard: Board, ActivatableBoard {
    let result: String?

    init(identifier: BoardID, result: String?) {
        self.result = result
        super.init(identifier: identifier)
    }

    func activate(withOption _: Any?) {
        DispatchQueue.global().async { [weak self] in
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
        DispatchQueue.main.async { [weak self] in
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
