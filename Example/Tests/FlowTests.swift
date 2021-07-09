import Boardy
import CwlPreconditionTesting
import XCTest

final class TestBoard: Board, ActivatableBoard {
    func activate(withOption option: Any?) {
        sendToMotherboard()
    }
}

final class Test2Board: Board, ActivatableBoard {
    func activate(withOption option: Any?) {
        sendToMotherboard()
    }
}

final class Test3Board: Board, ActivatableBoard {
    var activatedCount: Int = 0
    func activate(withOption option: Any?) {
        activatedCount += 1
    }
}

final class FlowTests: XCTestCase {
    private let testId: BoardID = "test"
    private let testId2: BoardID = "test2"
    private let testId3: BoardID = "test3"
    
    var testBoard: TestBoard!
    var motherboard: Motherboard!
    
    override func setUp() {
        super.setUp()
        
        testBoard = TestBoard(identifier: testId)
        motherboard = Motherboard(boards: [testBoard])
    }
    
    override func tearDown() {
        super.tearDown()
        motherboard.resetFlows()
    }
    
    func testChainFlow() {
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
    
    func testGuaranteedFlow() throws {
        var result: (FlowTests, String)?
        
        motherboard.registerGuaranteedFlow(matchedIdentifiers: [testId], target: self, uniqueOutputType: String.self) {
            result = ($0, $1)
        }
        
        testBoard.sendToMotherboard(data: "text")
        
        let validResult = try XCTUnwrap(result)
        XCTAssertEqual(validResult.0, self)
        XCTAssertEqual(validResult.1, "text")
        
        var assertionCalled: Bool = false
        var assertionPassed: Bool = false
        
        let exceptionGuard: CwlPreconditionTesting.BadInstructionException? = CwlPreconditionTesting.catchBadInstruction { [unowned self] in
            assertionCalled = true
            
            self.testBoard.sendToMotherboard()
            
            assertionPassed = true
        }
        
        XCTAssertNotNil(exceptionGuard)
        XCTAssertTrue(assertionCalled)
        XCTAssertFalse(assertionPassed)
    }
    
    func testCompleteFlow() {
        XCTAssertEqual(motherboard.boards.count, 1)
        testBoard.complete()
        XCTAssertEqual(motherboard.boards.count, 0)
    }
    
    func testFlowSteps() {
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
}
