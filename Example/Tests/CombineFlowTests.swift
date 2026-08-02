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
        DispatchQueue.main.async { [weak self] in
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

        waitForExpectations(timeout: hangGuardTimeout, handler: nil)

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

        wait(for: [secondInvocation], timeout: hangGuardTimeout)

        XCTAssertEqual(invocationCount, 2)
        let values = try XCTUnwrap(secondBatch)
        XCTAssertEqual(values[0] as? String, "second")
        XCTAssertEqual(values[1] as? Int, 202)
    }
}

// MARK: - Arity coverage

/// Emits its input during `activate`, with no queue hop.
///
/// The async `SutBoard` above exists to prove a combined flow survives output arriving after
/// activation returns. These arity tests are about which value lands in which slot, so they use a
/// synchronous board and need no waiting at all.
private final class SyncSutBoard: Board, GuaranteedBoard {
    typealias InputType = Any?

    func activate(withGuaranteedInput input: InputType) {
        sendToMotherboard(data: input)
    }
}

/// Collects what a combined flow handed back, so a test can assert on slot order.
private final class CombineSpy {
    var values: [Any?] = []
    var invocations = 0

    func record(_ values: Any?...) {
        self.values = values
        invocations += 1
    }
}

extension CombineFlowTests {
    /// Builds a motherboard with one `SutBoard` per identifier and activates them all with the
    /// given values, so a combined flow of that arity fires exactly once.
    private func makeBoards(_ count: Int) -> (FlowMotherboard, [BoardID]) {
        let ids: [BoardID] = (1 ... count).map { BoardID("b\($0)") }
        let boards: [ActivatableBoard] = ids.map { SyncSutBoard(identifier: $0) }
        return (Motherboard(boards: boards), ids)
    }

    private func spec<Output>(_ motherboard: FlowMotherboard, _ id: BoardID, _: Output.Type) -> GuaranteedOutputSpecifications<Output> {
        motherboard.matchedFlow(id, with: Output.self).specifications
    }

    /// Each arity uses a different type per slot on purpose: a copy-paste error that wires spec3
    /// into the second handler parameter cannot type-check its way past this.
    func testCombinedFlow3AritySlotsAreOrdered() {
        let (motherboard, ids) = makeBoards(3)
        var result: (String, Int, Bool)?

        motherboard.registerCombinedFlow(spec(motherboard, ids[0], String.self),
                                         spec(motherboard, ids[1], Int.self),
                                         spec(motherboard, ids[2], Bool.self)) { v1, v2, v3 in
            result = (v1, v2, v3)
        }

        motherboard.activation(ids[0], with: Any?.self).activate(with: "one")
        motherboard.activation(ids[1], with: Any?.self).activate(with: 2)
        motherboard.activation(ids[2], with: Any?.self).activate(with: true)

        XCTAssertEqual(result?.0, "one")
        XCTAssertEqual(result?.1, 2)
        XCTAssertEqual(result?.2, true)
    }

    func testCombinedFlow4AritySlotsAreOrdered() {
        let (motherboard, ids) = makeBoards(4)
        var result: (String, Int, Bool, Double)?

        motherboard.registerCombinedFlow(spec(motherboard, ids[0], String.self),
                                         spec(motherboard, ids[1], Int.self),
                                         spec(motherboard, ids[2], Bool.self),
                                         spec(motherboard, ids[3], Double.self)) { v1, v2, v3, v4 in
            result = (v1, v2, v3, v4)
        }

        motherboard.activation(ids[0], with: Any?.self).activate(with: "one")
        motherboard.activation(ids[1], with: Any?.self).activate(with: 2)
        motherboard.activation(ids[2], with: Any?.self).activate(with: true)
        motherboard.activation(ids[3], with: Any?.self).activate(with: 4.5)

        XCTAssertEqual(result?.0, "one")
        XCTAssertEqual(result?.1, 2)
        XCTAssertEqual(result?.2, true)
        XCTAssertEqual(result?.3, 4.5)
    }

    func testCombinedFlow5AritySlotsAreOrdered() {
        let (motherboard, ids) = makeBoards(5)
        var result: (String, Int, Bool, Double, String)?

        motherboard.registerCombinedFlow(spec(motherboard, ids[0], String.self),
                                         spec(motherboard, ids[1], Int.self),
                                         spec(motherboard, ids[2], Bool.self),
                                         spec(motherboard, ids[3], Double.self),
                                         spec(motherboard, ids[4], String.self)) { v1, v2, v3, v4, v5 in
            result = (v1, v2, v3, v4, v5)
        }

        motherboard.activation(ids[0], with: Any?.self).activate(with: "one")
        motherboard.activation(ids[1], with: Any?.self).activate(with: 2)
        motherboard.activation(ids[2], with: Any?.self).activate(with: true)
        motherboard.activation(ids[3], with: Any?.self).activate(with: 4.5)
        motherboard.activation(ids[4], with: Any?.self).activate(with: "five")

        XCTAssertEqual(result?.0, "one")
        XCTAssertEqual(result?.1, 2)
        XCTAssertEqual(result?.2, true)
        XCTAssertEqual(result?.3, 4.5)
        XCTAssertEqual(result?.4, "five")
    }

    func testCombinedCollectionFlowDeliversEveryOutput() {
        let (motherboard, ids) = makeBoards(3)
        var batches: [[String]] = []

        motherboard.registerCombinedFlow(ids.map { spec(motherboard, $0, String.self) }) { values in
            batches.append(values)
        }

        for (index, id) in ids.enumerated() {
            motherboard.activation(id, with: Any?.self).activate(with: "v\(index)")
        }

        XCTAssertEqual(batches, [["v0", "v1", "v2"]])
    }

    // MARK: Target variants

    /// The target overloads box the target weakly. Every arity must deliver while the target is
    /// alive, and every arity must go quiet once it is gone — the box is per-overload code.
    func testTargetVariantsDeliverToALiveTarget() {
        let (motherboard, ids) = makeBoards(5)
        let spy = CombineSpy()

        motherboard.registerCombinedFlow(spec(motherboard, ids[0], String.self),
                                         spec(motherboard, ids[1], Int.self),
                                         target: spy) { target, v1, v2 in
            target.record(v1, v2)
        }

        motherboard.activation(ids[0], with: Any?.self).activate(with: "one")
        motherboard.activation(ids[1], with: Any?.self).activate(with: 2)

        XCTAssertEqual(spy.invocations, 1)
        XCTAssertEqual(spy.values[0] as? String, "one")
        XCTAssertEqual(spy.values[1] as? Int, 2)
    }

    func testTargetVariantsStopDeliveringAfterTargetIsReleased() {
        let (motherboard, ids) = makeBoards(2)
        var spy: CombineSpy? = CombineSpy()
        weak var weakSpy = spy

        motherboard.registerCombinedFlow(spec(motherboard, ids[0], String.self),
                                         spec(motherboard, ids[1], Int.self),
                                         target: spy!) { target, v1, v2 in
            target.record(v1, v2)
        }

        spy = nil
        XCTAssertNil(weakSpy, "the flow must not keep the target alive")

        motherboard.activation(ids[0], with: Any?.self).activate(with: "one")
        motherboard.activation(ids[1], with: Any?.self).activate(with: 2)
        // No crash and no delivery: the boxed target unboxes to nil and the handler returns early.
    }

    func testTargetVariant3AritySlotsAreOrdered() {
        let (motherboard, ids) = makeBoards(3)
        let spy = CombineSpy()

        motherboard.registerCombinedFlow(spec(motherboard, ids[0], String.self),
                                         spec(motherboard, ids[1], Int.self),
                                         spec(motherboard, ids[2], Bool.self),
                                         target: spy) { target, v1, v2, v3 in
            target.record(v1, v2, v3)
        }

        motherboard.activation(ids[0], with: Any?.self).activate(with: "one")
        motherboard.activation(ids[1], with: Any?.self).activate(with: 2)
        motherboard.activation(ids[2], with: Any?.self).activate(with: true)

        XCTAssertEqual(spy.invocations, 1)
        XCTAssertEqual(spy.values[0] as? String, "one")
        XCTAssertEqual(spy.values[1] as? Int, 2)
        XCTAssertEqual(spy.values[2] as? Bool, true)
    }

    func testTargetVariant4AritySlotsAreOrdered() {
        let (motherboard, ids) = makeBoards(4)
        let spy = CombineSpy()

        motherboard.registerCombinedFlow(spec(motherboard, ids[0], String.self),
                                         spec(motherboard, ids[1], Int.self),
                                         spec(motherboard, ids[2], Bool.self),
                                         spec(motherboard, ids[3], Double.self),
                                         target: spy) { target, v1, v2, v3, v4 in
            target.record(v1, v2, v3, v4)
        }

        motherboard.activation(ids[0], with: Any?.self).activate(with: "one")
        motherboard.activation(ids[1], with: Any?.self).activate(with: 2)
        motherboard.activation(ids[2], with: Any?.self).activate(with: true)
        motherboard.activation(ids[3], with: Any?.self).activate(with: 4.5)

        XCTAssertEqual(spy.invocations, 1)
        XCTAssertEqual(spy.values[0] as? String, "one")
        XCTAssertEqual(spy.values[1] as? Int, 2)
        XCTAssertEqual(spy.values[2] as? Bool, true)
        XCTAssertEqual(spy.values[3] as? Double, 4.5)
    }

    func testTargetVariant5AritySlotsAreOrdered() {
        let (motherboard, ids) = makeBoards(5)
        let spy = CombineSpy()

        motherboard.registerCombinedFlow(spec(motherboard, ids[0], String.self),
                                         spec(motherboard, ids[1], Int.self),
                                         spec(motherboard, ids[2], Bool.self),
                                         spec(motherboard, ids[3], Double.self),
                                         spec(motherboard, ids[4], String.self),
                                         target: spy) { target, v1, v2, v3, v4, v5 in
            target.record(v1, v2, v3, v4, v5)
        }

        motherboard.activation(ids[0], with: Any?.self).activate(with: "one")
        motherboard.activation(ids[1], with: Any?.self).activate(with: 2)
        motherboard.activation(ids[2], with: Any?.self).activate(with: true)
        motherboard.activation(ids[3], with: Any?.self).activate(with: 4.5)
        motherboard.activation(ids[4], with: Any?.self).activate(with: "five")

        XCTAssertEqual(spy.invocations, 1)
        XCTAssertEqual(spy.values[0] as? String, "one")
        XCTAssertEqual(spy.values[1] as? Int, 2)
        XCTAssertEqual(spy.values[2] as? Bool, true)
        XCTAssertEqual(spy.values[3] as? Double, 4.5)
        XCTAssertEqual(spy.values[4] as? String, "five")
    }

    func testCombinedCollectionFlowWithTargetDelivers() {
        let (motherboard, ids) = makeBoards(2)
        let spy = CombineSpy()

        motherboard.registerCombinedFlow(ids.map { spec(motherboard, $0, String.self) },
                                         target: spy) { target, values in
            target.record(values)
        }

        motherboard.activation(ids[0], with: Any?.self).activate(with: "a")
        motherboard.activation(ids[1], with: Any?.self).activate(with: "b")

        XCTAssertEqual(spy.invocations, 1)
        XCTAssertEqual(spy.values[0] as? [String], ["a", "b"])
    }

    // MARK: Strategy

    /// `.batchOneByOne` clears collected values once a batch fires; `.latestForever` keeps them, so
    /// a single new value produces another combined result.
    func testBatchOneByOneRequiresAFullNewBatch() {
        let (motherboard, ids) = makeBoards(2)
        var batches: [[String]] = []

        motherboard.registerCombinedFlow(ids.map { spec(motherboard, $0, String.self) },
                                         strategy: .batchOneByOne) { batches.append($0) }

        motherboard.activation(ids[0], with: Any?.self).activate(with: "a1")
        motherboard.activation(ids[1], with: Any?.self).activate(with: "b1")
        XCTAssertEqual(batches.count, 1)

        motherboard.activation(ids[0], with: Any?.self).activate(with: "a2")
        XCTAssertEqual(batches.count, 1, "a partial batch must not fire")

        motherboard.activation(ids[1], with: Any?.self).activate(with: "b2")
        XCTAssertEqual(batches, [["a1", "b1"], ["a2", "b2"]])
    }

    func testLatestForeverRefiresOnEverySubsequentValue() {
        let (motherboard, ids) = makeBoards(2)
        var batches: [[String]] = []

        motherboard.registerCombinedFlow(ids.map { spec(motherboard, $0, String.self) },
                                         strategy: .latestForever) { batches.append($0) }

        motherboard.activation(ids[0], with: Any?.self).activate(with: "a1")
        motherboard.activation(ids[1], with: Any?.self).activate(with: "b1")
        XCTAssertEqual(batches, [["a1", "b1"]])

        motherboard.activation(ids[0], with: Any?.self).activate(with: "a2")
        XCTAssertEqual(batches, [["a1", "b1"], ["a2", "b1"]], "the retained b1 must combine with the new a2")
    }
}
