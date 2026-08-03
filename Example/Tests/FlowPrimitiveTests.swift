//
//  FlowPrimitiveTests.swift
//  Boardy_Tests
//
//  SLICE S2 / item 1.6 — flow primitives. See
//  docs/02-working-docs/review/slice-S2-flow-primitives-brief.md.
//
//  Verifies the four contracts the brief enumerates:
//    1. IDMatchBoardFlow.match(with:) — identifier filtering.
//    2. DataMatchBoardFlow.doNext(with:) — type unwrap + silent-data escape.
//    3. IDGenericBoardFlow<Out> — six initialisers, including weak target.
//    4. BoardActivateFlow — four uncovered initialisers (matcher/identifier ×
//       outputNextHandler/dedicatedNextHandler).
//  Plus the optional item 5 for GenericBoardFlow<Out>.
//
//  Everything is synchronous — no wall-clock waits. Assertion traps are caught
//  with CwlPreconditionTesting, mirroring FlowTests.test_guaranteedFlow.
//

@testable import Boardy
#if canImport(CwlPreconditionTesting)
    import CwlPreconditionTesting
#endif
import XCTest

final class FlowPrimitiveTests: XCTestCase {
    // MARK: - Contract 1 — IDMatchBoardFlow.match(with:)

    func testIdentifierFiltering_acceptsEveryListedIdentifier() {
        let flow = IDGenericBoardFlow<String>(matchedBoardIDs: ["a", "b"]) { _ in }
        XCTAssertTrue(flow.match(with: OutputModel(identifier: "a", data: "x")))
        XCTAssertTrue(flow.match(with: OutputModel(identifier: "b", data: "x")))
    }

    func testIdentifierFiltering_rejectsIdentifierNotInList() {
        let flow = IDGenericBoardFlow<String>(matchedBoardIDs: ["a", "b"]) { _ in }
        XCTAssertFalse(flow.match(with: OutputModel(identifier: "c", data: "x")))
    }

    func testIdentifierFiltering_matchesNothingWhenListIsEmpty() {
        let flow = IDGenericBoardFlow<String>(matchedBoardIDs: []) { _ in }
        XCTAssertFalse(flow.match(with: OutputModel(identifier: "a", data: "x")))
        XCTAssertFalse(flow.match(with: OutputModel(identifier: "anything", data: nil)))
    }

    // MARK: - Contract 2 — DataMatchBoardFlow.doNext(with:)

    func testDoNextWithMatchingType_deliversUnwrappedTypedValue() {
        var received: String?
        let flow = IDGenericBoardFlow<String>(matchedBoardIDs: ["a"]) { value in
            received = value
        }

        XCTAssertTrue(flow.match(with: OutputModel(identifier: "a", data: "hello")))
        flow.doNext(with: OutputModel(identifier: "a", data: "hello"))

        XCTAssertEqual(received, "hello")
    }

    func testDoNextWithMismatchedNonSilentType_trapsOnAssertionFailure() throws {
        let flow = IDGenericBoardFlow<String>(matchedBoardIDs: ["a"]) { _ in }

        #if canImport(CwlPreconditionTesting)
            var didEnter = false

            let exception: CwlPreconditionTesting.BadInstructionException? =
                CwlPreconditionTesting.catchBadInstruction {
                    didEnter = true
                    flow.doNext(with: OutputModel(identifier: "a", data: 42))
                }

            XCTAssertNotNil(exception, "expected a trap from assertionFailure on type mismatch")
            XCTAssertTrue(didEnter, "expected the guarded block to begin executing before the trap")
        #else
            throw XCTSkip("CwlPreconditionTesting is only available in the CocoaPods/Xcode test host")
        #endif
    }

    func testDoNextWithMismatchedSilentType_returnsWithoutAssertingOrCallingHandler() {
        // The whole point of this branch: a typed flow sees an unrelated
        // BoardFlowAction slip through (a UI element action, say) and must
        // silently drop it rather than crash the app.
        var handlerCalls = 0
        let flow = IDGenericBoardFlow<String>(matchedBoardIDs: ["a"]) { _ in
            handlerCalls += 1
        }

        flow.doNext(with: OutputModel(identifier: "a", data: _SilentAction.tick))

        XCTAssertEqual(handlerCalls, 0, "silent data must not reach the typed handler")
    }

    // MARK: - Contract 3 — IDGenericBoardFlow<Out> six initialisers

    func testIDGenericBoardFlowArrayAndVariadicInits_produceSameMatchingBehaviour() {
        var fromArray: Int?
        var fromVariadic: Int?
        let array = IDGenericBoardFlow<Int>(matchedBoardIDs: ["a", "b"]) { fromArray = $0 }
        let variadic = IDGenericBoardFlow<Int>(matchedBoardIDs: "a", "b") { fromVariadic = $0 }

        XCTAssertEqual(array.matchedBoardIDs, variadic.matchedBoardIDs)

        let payload = OutputModel(identifier: "a", data: 7)
        XCTAssertEqual(array.match(with: payload), variadic.match(with: payload))
        XCTAssertTrue(array.match(with: payload))
        XCTAssertTrue(variadic.match(with: payload))
        XCTAssertFalse(array.match(with: OutputModel(identifier: "c", data: 7)))
        XCTAssertFalse(variadic.match(with: OutputModel(identifier: "c", data: 7)))

        array.doNext(with: payload)
        variadic.doNext(with: payload)
        XCTAssertEqual(fromArray, 7)
        XCTAssertEqual(fromVariadic, 7)
    }

    func testIDGenericBoardFlowWithTarget_holdsTargetWeakly() {
        final class Sink {
            var received: String?
        }
        var target: Sink? = Sink()
        weak var weakRef: Sink? = target
        XCTAssertNotNil(weakRef)

        var captured: Sink?
        let flow = IDGenericBoardFlow<String>(matchedBoardIDs: ["a"], target: target!) { t, value in
            captured = t
            t.received = value
        }

        // Target alive: handler fires and the closure receives the same instance.
        flow.doNext(with: OutputModel(identifier: "a", data: "first"))
        XCTAssertNotNil(captured)
        XCTAssertTrue(captured === target)
        XCTAssertEqual(captured?.received, "first")

        // Drop the only strong reference; the weak probe must clear, proving
        // the instance deallocated. The flow's ObjectBox held it weakly.
        captured = nil
        target = nil
        XCTAssertNil(weakRef)

        // Delivering another output must not invoke the handler and must not crash.
        flow.doNext(with: OutputModel(identifier: "a", data: "second"))
    }

    func testIDGenericBoardFlowOfTypeInits_inferOutputFromBoardType() {
        // SyncEmittingBoard<String>.OutputType == String; Out is inferred from
        // the board type, so the handler signature must be (String) -> Void.
        var receivedNoTarget: String?
        let board = SyncEmittingBoard<String>(identifier: "a")
        var receivedTarget: SyncEmittingBoard<String>?
        var receivedValueWithTarget: String?

        let noTarget = IDGenericBoardFlow<String>(
            matchedBoardID: "a",
            of: SyncEmittingBoard<String>.self
        ) { value in
            receivedNoTarget = value
        }
        let withTarget = IDGenericBoardFlow<String>(
            matchedBoardID: "a",
            of: SyncEmittingBoard<String>.self,
            target: board
        ) { t, value in
            receivedTarget = t
            receivedValueWithTarget = value
        }

        XCTAssertTrue(noTarget.match(with: OutputModel(identifier: "a", data: "inferred")))
        XCTAssertTrue(withTarget.match(with: OutputModel(identifier: "a", data: "inferred")))

        noTarget.doNext(with: OutputModel(identifier: "a", data: "inferred"))
        withTarget.doNext(with: OutputModel(identifier: "a", data: "inferred"))

        XCTAssertEqual(receivedNoTarget, "inferred")
        XCTAssertEqual(receivedValueWithTarget, "inferred")
        XCTAssertTrue(receivedTarget === board)
    }

    func testIDGenericBoardFlowVariadicTargetInit_agreesWithArrayFormAndHoldsTargetWeakly() {
        final class Sink {
            var received: String?
        }
        var target: Sink? = Sink()
        weak var weakRef: Sink? = target

        var fromArray: String?
        var fromVariadic: String?

        let array = IDGenericBoardFlow<String>(matchedBoardIDs: ["a"], target: target!) { _, value in
            fromArray = value
        }
        let variadic = IDGenericBoardFlow<String>(matchedBoardIDs: "a", target: target!) { _, value in
            fromVariadic = value
        }

        XCTAssertEqual(array.matchedBoardIDs, variadic.matchedBoardIDs)

        array.doNext(with: OutputModel(identifier: "a", data: "via-array"))
        variadic.doNext(with: OutputModel(identifier: "a", data: "via-variadic"))
        XCTAssertEqual(fromArray, "via-array")
        XCTAssertEqual(fromVariadic, "via-variadic")

        target = nil
        XCTAssertNil(weakRef)

        array.doNext(with: OutputModel(identifier: "a", data: "after-release"))
        variadic.doNext(with: OutputModel(identifier: "a", data: "after-release"))
        XCTAssertEqual(fromArray, "via-array", "array form must stop calling after target deallocates")
        XCTAssertEqual(fromVariadic, "via-variadic", "variadic form must stop calling after target deallocates")
    }

    // MARK: - Contract 4 — BoardActivateFlow four uncovered initialisers

    func testBoardActivateFlowWithMatcher_deliversWholeBoardOutputModel() {
        var receivedIdentifier: BoardID?
        var receivedData: Any?
        let flow = BoardActivateFlow(matcher: { $0.identifier == "a" }) { output in
            receivedIdentifier = output.identifier
            receivedData = output.data
        }

        XCTAssertTrue(flow.match(with: OutputModel(identifier: "a", data: "payload")))
        XCTAssertFalse(flow.match(with: OutputModel(identifier: "b", data: "payload")))

        flow.doNext(with: OutputModel(identifier: "a", data: "payload"))

        XCTAssertEqual(receivedIdentifier, "a")
        XCTAssertEqual(receivedData as? String, "payload")
    }

    func testBoardActivateFlowWithMatcher_dedicatedHandlerYieldsNilOnTypeMismatch() {
        var nils = 0
        var values: [String] = []
        let flow = BoardActivateFlow(matcher: { $0.identifier == "a" }) { (value: String?) in
            if let value {
                values.append(value)
            } else {
                nils += 1
            }
        }

        // Mismatched type must not assert; the handler is just called with nil.
        flow.doNext(with: OutputModel(identifier: "a", data: 42))
        // Matching type unwraps normally.
        flow.doNext(with: OutputModel(identifier: "a", data: "ok"))

        XCTAssertEqual(nils, 1, "mismatched type should surface as nil, not an assertion")
        XCTAssertEqual(values, ["ok"])
    }

    func testBoardActivateFlowWithMatchedIdentifiers_deliversWholeBoardOutputModel() {
        var receivedIdentifier: BoardID?
        var receivedData: Any?
        let flow = BoardActivateFlow(matchedIdentifiers: ["x", "y"]) { output in
            receivedIdentifier = output.identifier
            receivedData = output.data
        }

        XCTAssertTrue(flow.match(with: OutputModel(identifier: "x", data: "v")))
        XCTAssertTrue(flow.match(with: OutputModel(identifier: "y", data: "v")))
        XCTAssertFalse(flow.match(with: OutputModel(identifier: "z", data: "v")))

        flow.doNext(with: OutputModel(identifier: "y", data: "v2"))

        XCTAssertEqual(receivedIdentifier, "y")
        XCTAssertEqual(receivedData as? String, "v2")
    }

    func testBoardActivateFlowWithMatchedIdentifiers_dedicatedHandlerYieldsNilOnTypeMismatch() {
        var nils = 0
        var values: [String] = []
        let flow = BoardActivateFlow(matchedIdentifiers: ["a"]) { (value: String?) in
            if let value {
                values.append(value)
            } else {
                nils += 1
            }
        }

        // Identifier matches but data type does not → dedicated handler receives nil.
        flow.doNext(with: OutputModel(identifier: "a", data: 99))
        flow.doNext(with: OutputModel(identifier: "a", data: "hi"))

        XCTAssertEqual(nils, 1)
        XCTAssertEqual(values, ["hi"])
    }

    // MARK: - Contract 5 (optional) — GenericBoardFlow<Out>

    func testGenericBoardFlowDefaultMatcher_acceptsAnyOutput() {
        var received: Int?
        let flow = GenericBoardFlow<Int>(nextHandler: { received = $0 })

        XCTAssertTrue(flow.match(with: OutputModel(identifier: "x", data: 7)))
        XCTAssertTrue(flow.match(with: OutputModel(identifier: "y", data: 8)))
        XCTAssertTrue(flow.match(with: OutputModel(identifier: "z", data: nil)))

        flow.doNext(with: OutputModel(identifier: "x", data: 7))
        XCTAssertEqual(received, 7)
    }

    func testGenericBoardFlowWithTarget_holdsTargetWeakly() {
        final class Sink {
            var received: Int?
        }
        var target: Sink? = Sink()
        weak var weakRef: Sink? = target
        XCTAssertNotNil(weakRef)

        var captured: Sink?
        let flow = GenericBoardFlow<Int>(
            matcher: { _ in true },
            target: target!
        ) { t, value in
            captured = t
            t.received = value
        }

        flow.doNext(with: OutputModel(identifier: "a", data: 1))
        XCTAssertNotNil(captured)
        XCTAssertTrue(captured === target)
        XCTAssertEqual(captured?.received, 1)

        captured = nil
        target = nil
        XCTAssertNil(weakRef)

        // No handler call and no crash after the target has been released.
        flow.doNext(with: OutputModel(identifier: "a", data: 2))
    }

    // MARK: - Test doubles

    /// Conforming type used to prove the silent-data escape branch in
    /// `DataMatchBoardFlow.doNext(with:)`. `isSilentData` flags any
    /// `BoardFlowAction`-conforming value.
    private enum _SilentAction: BoardFlowAction {
        case tick
    }
}
