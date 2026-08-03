//
//  FlowRegistrationTests.swift
//  Boardy_Tests
//
//  Coverage plan items 1.7 and 1.8 — the flow-registration overloads that no test reached.
//  See docs/02-working-docs/review/2026-08-02-coverage-plan.md §4.
//
//  1.7 The four registration overloads at 0%: the `target:` form of `registerGeneralFlow`, both
//      `registerFlow(matchedIdentifiers:…)` forms, and `registerCompletionFlow`. What distinguishes
//      them is not that they route data — every flow does — but *what they decline to route*: a
//      general flow ignores the sender's identity and keys only off the output type, a dedicated flow
//      skips a type mismatch silently where its guaranteed sibling reports one, and a completion flow
//      answers only to `CompleteAction`.
//
//  1.8 `bindToBus:` and `sendOutputThrough:`, in both the dedicated and guaranteed forms. These are
//      the composition primitives: one forwards a board's output onto a Bus, the other makes another
//      board re-emit it as its own.
//

@testable import Boardy
import XCTest

// MARK: - Fixtures

private extension BoardID {
    static let sender: BoardID = "sender"
    static let otherSender: BoardID = "other-sender"
    static let relay: BoardID = "relay"
}

private struct Payload: Equatable {
    let text: String
}

private struct OtherPayload: Equatable {
    let number: Int
}

/// A class target, so `ObjectBox` stores it weakly — the reference-type case is the one the
/// `target:` overloads are written for.
private final class Collector {
    private(set) var received: [Payload] = []
    private(set) var completions: [Bool] = []

    func collect(_ payload: Payload) {
        received.append(payload)
    }
}

/// Raises a `CompleteAction` instead of a value, which is what `registerCompletionFlow` listens for.
private final class CompletingBoard: Board, ActivatableBoard {
    func activate(withOption option: Any?) {
        complete((option as? Bool) ?? true)
    }
}

// MARK: - Item 1.7 — the uncovered registration overloads

final class FlowRegistrationTests: XCTestCase {
    // MARK: registerGeneralFlow(target:uniqueOutputType:)

    /// "A General Flow doesn't check identifier of sender." Two boards with different identifiers
    /// emit the same type; both must reach the handler, or the flow is not general.
    func testGeneralFlowWithTargetIgnoresSenderIdentity() {
        let motherboard = Motherboard()
        let first = SyncEmittingBoard<Payload>(identifier: .sender)
        let second = SyncEmittingBoard<Payload>(identifier: .otherSender)
        motherboard.addBoard(first)
        motherboard.addBoard(second)

        let collector = Collector()
        motherboard.registerGeneralFlow(target: collector, uniqueOutputType: Payload.self) { target, output in
            target.collect(output)
        }

        first.activate(withGuaranteedInput: Payload(text: "from first"))
        second.activate(withGuaranteedInput: Payload(text: "from second"))

        XCTAssertEqual(collector.received, [Payload(text: "from first"), Payload(text: "from second")])
    }

    /// The type is the whole filter: an output of another type from a matching sender is dropped
    /// without reaching the handler and without trapping.
    func testGeneralFlowWithTargetSkipsAnotherOutputType() {
        let motherboard = Motherboard()
        let payloadBoard = SyncEmittingBoard<Payload>(identifier: .sender)
        let otherBoard = SyncEmittingBoard<OtherPayload>(identifier: .otherSender)
        motherboard.addBoard(payloadBoard)
        motherboard.addBoard(otherBoard)

        let collector = Collector()
        motherboard.registerGeneralFlow(target: collector, uniqueOutputType: Payload.self) { target, output in
            target.collect(output)
        }

        otherBoard.activate(withGuaranteedInput: OtherPayload(number: 7))
        XCTAssertTrue(collector.received.isEmpty, "a general flow must key off the output type alone")

        // Positive control: the same flow does deliver its own type, so the empty result above is a
        // filter doing its job rather than a flow that never fires.
        payloadBoard.activate(withGuaranteedInput: Payload(text: "matching"))
        XCTAssertEqual(collector.received, [Payload(text: "matching")])
    }

    /// The target is boxed weakly, so a released target silences the flow instead of resurrecting it
    /// or crashing. This is what lets a screen register a flow without owning its own teardown.
    func testGeneralFlowHoldsAClassTargetWeakly() {
        let motherboard = Motherboard()
        let sender = SyncEmittingBoard<Payload>(identifier: .sender)
        motherboard.addBoard(sender)

        var collector: Collector? = Collector()
        weak var weakCollector = collector
        var handlerCalls = 0

        motherboard.registerGeneralFlow(target: collector!, uniqueOutputType: Payload.self) { target, output in
            handlerCalls += 1
            target.collect(output)
        }

        sender.activate(withGuaranteedInput: Payload(text: "alive"))
        XCTAssertEqual(handlerCalls, 1, "the handler must run while the target is alive")
        XCTAssertEqual(collector?.received, [Payload(text: "alive")])

        collector = nil
        XCTAssertNil(weakCollector, "the flow must not retain its target")

        sender.activate(withGuaranteedInput: Payload(text: "after release"))
        XCTAssertEqual(handlerCalls, 1, "the handler must not run once the target is released")
    }

    // MARK: registerFlow(matchedIdentifiers:uniqueOutputType:nextHandler:)

    /// Unlike the general form, this one filters on identifier as well as type.
    func testDedicatedFlowMatchesOnlyListedIdentifiers() {
        let motherboard = Motherboard()
        let listed = SyncEmittingBoard<Payload>(identifier: .sender)
        let unlisted = SyncEmittingBoard<Payload>(identifier: .otherSender)
        motherboard.addBoard(listed)
        motherboard.addBoard(unlisted)

        var received: [Payload] = []
        motherboard.registerFlow(matchedIdentifiers: [.sender], uniqueOutputType: Payload.self) {
            received.append($0)
        }

        unlisted.activate(withGuaranteedInput: Payload(text: "unlisted"))
        XCTAssertTrue(received.isEmpty, "an unlisted sender must not reach the flow")

        listed.activate(withGuaranteedInput: Payload(text: "listed"))
        XCTAssertEqual(received, [Payload(text: "listed")])
    }

    /// The documented difference from `registerGuaranteedFlow`: "If data matches with Output type,
    /// handler will be executed, otherwise the handler will be skipped." Skipped, not asserted — so
    /// a listed sender emitting another type must pass through quietly.
    func testDedicatedFlowSkipsMismatchedTypeWithoutTrapping() {
        let motherboard = Motherboard()
        let sender = SyncEmittingBoard<OtherPayload>(identifier: .sender)
        motherboard.addBoard(sender)

        var received: [Payload] = []
        motherboard.registerFlow(matchedIdentifiers: [.sender], uniqueOutputType: Payload.self) {
            received.append($0)
        }

        sender.activate(withGuaranteedInput: OtherPayload(number: 1))

        XCTAssertTrue(received.isEmpty, "a mismatched type must be skipped, not delivered")
    }

    // MARK: registerFlow(matchedIdentifiers:target:uniqueOutputType:nextHandler:)

    /// The `target:` variant filters the same way and, like the general form, holds the target weakly.
    func testDedicatedFlowWithTargetFiltersAndHoldsTargetWeakly() {
        let motherboard = Motherboard()
        let listed = SyncEmittingBoard<Payload>(identifier: .sender)
        let unlisted = SyncEmittingBoard<Payload>(identifier: .otherSender)
        motherboard.addBoard(listed)
        motherboard.addBoard(unlisted)

        var collector: Collector? = Collector()
        weak var weakCollector = collector
        var handlerCalls = 0

        motherboard.registerFlow(
            matchedIdentifiers: [.sender],
            target: collector!,
            uniqueOutputType: Payload.self
        ) { target, output in
            handlerCalls += 1
            target.collect(output)
        }

        unlisted.activate(withGuaranteedInput: Payload(text: "unlisted"))
        XCTAssertEqual(handlerCalls, 0, "an unlisted sender must not reach the flow")

        listed.activate(withGuaranteedInput: Payload(text: "listed"))
        XCTAssertEqual(collector?.received, [Payload(text: "listed")])

        collector = nil
        XCTAssertNil(weakCollector, "the flow must not retain its target")

        listed.activate(withGuaranteedInput: Payload(text: "after release"))
        XCTAssertEqual(handlerCalls, 1, "the handler must not run once the target is released")
    }

    // MARK: registerCompletionFlow(matchedIdentifiers:)

    /// A completion flow answers only to `CompleteAction`, and hands the caller its `isDone`.
    ///
    /// Each outcome needs its own board: `complete()` is documented as "complete this board & ask to
    /// be removed", so the motherboard detaches the sender as it forwards the action. A second
    /// `complete()` on the same instance has no motherboard left to reach — which the next test pins
    /// directly, since a completion flow's whole job is to observe that moment.
    func testCompletionFlowDeliversIsDoneForBothOutcomes() {
        for outcome in [true, false] {
            let motherboard = Motherboard()
            let board = CompletingBoard(identifier: .sender)
            motherboard.addBoard(board)

            var completions: [Bool] = []
            motherboard.registerCompletionFlow(matchedIdentifiers: [.sender]) { isDone in
                completions.append(isDone)
            }

            board.activate(withOption: outcome)

            XCTAssertEqual(completions, [outcome], "isDone must arrive as sent for outcome \(outcome)")
        }
    }

    /// Completing removes the sender, so the flow fires exactly once however often the board tries.
    func testCompletionFlowFiresOnceBecauseCompletingRemovesTheSender() {
        let motherboard = Motherboard()
        let board = CompletingBoard(identifier: .sender)
        motherboard.addBoard(board)

        var completions: [Bool] = []
        motherboard.registerCompletionFlow(matchedIdentifiers: [.sender]) { isDone in
            completions.append(isDone)
        }

        board.activate(withOption: true)
        XCTAssertFalse(
            motherboard.boards.contains { $0.identifier == .sender },
            "completing must remove the board from its motherboard"
        )

        board.activate(withOption: false)
        XCTAssertEqual(completions, [true], "a removed board has no motherboard left to notify")
    }

    /// A value output from the same identifier is not a completion, so the flow must ignore it.
    func testCompletionFlowIgnoresValueOutputFromTheSameIdentifier() {
        let motherboard = Motherboard()
        let emitter = SyncEmittingBoard<Payload>(identifier: .sender)
        motherboard.addBoard(emitter)

        var completions: [Bool] = []
        motherboard.registerCompletionFlow(matchedIdentifiers: [.sender]) { isDone in
            completions.append(isDone)
        }

        emitter.activate(withGuaranteedInput: Payload(text: "not a completion"))

        XCTAssertTrue(completions.isEmpty, "only a CompleteAction may reach a completion flow")
    }

    /// The variadic form is a thin forward to the array form; both must accept the same identifier.
    func testCompletionFlowVariadicAndArrayFormsAgree() {
        var results: [String: [Bool]] = [:]

        for form in ["variadic", "array"] {
            let motherboard = Motherboard()
            let board = CompletingBoard(identifier: .sender)
            motherboard.addBoard(board)

            if form == "variadic" {
                motherboard.registerCompletionFlow(matchedIdentifiers: .sender) { isDone in
                    results[form, default: []].append(isDone)
                }
            } else {
                motherboard.registerCompletionFlow(matchedIdentifiers: [.sender]) { isDone in
                    results[form, default: []].append(isDone)
                }
            }

            board.activate(withOption: true)
        }

        XCTAssertEqual(results["variadic"], [true])
        XCTAssertEqual(results["array"], results["variadic"], "the two overloads must behave identically")
    }
}

// MARK: - Item 1.8 — bindToBus: and sendOutputThrough:

extension FlowRegistrationTests {
    /// `bindToBus:` transports a matched board's output onto the Bus, reaching every connected cable.
    func testBindToBusTransportsMatchedOutputToEveryConnectedCable() {
        let motherboard = Motherboard()
        let sender = SyncEmittingBoard<Payload>(identifier: .sender)
        motherboard.addBoard(sender)

        let bus = Bus<Payload>()
        var firstCable: [Payload] = []
        var secondCable: [Payload] = []
        bus.deliver { firstCable.append($0) }
        bus.deliver { secondCable.append($0) }

        motherboard.registerFlow(matchedIdentifiers: .sender, bindToBus: bus)

        sender.activate(withGuaranteedInput: Payload(text: "onto the bus"))

        XCTAssertEqual(firstCable, [Payload(text: "onto the bus")])
        XCTAssertEqual(secondCable, [Payload(text: "onto the bus")])
    }

    /// The identifier filter still applies: an unmatched sender's output never reaches the Bus.
    func testBindToBusIgnoresUnmatchedSenders() {
        let motherboard = Motherboard()
        let matched = SyncEmittingBoard<Payload>(identifier: .sender)
        let unmatched = SyncEmittingBoard<Payload>(identifier: .otherSender)
        motherboard.addBoard(matched)
        motherboard.addBoard(unmatched)

        let bus = Bus<Payload>()
        var delivered: [Payload] = []
        bus.deliver { delivered.append($0) }

        motherboard.registerFlow(matchedIdentifiers: .sender, bindToBus: bus)

        unmatched.activate(withGuaranteedInput: Payload(text: "unmatched"))
        XCTAssertTrue(delivered.isEmpty, "only the listed identifier may feed the bus")

        matched.activate(withGuaranteedInput: Payload(text: "matched"))
        XCTAssertEqual(delivered, [Payload(text: "matched")])
    }

    /// `sendOutputThrough:` makes a second board re-emit the first board's output as its own — so a
    /// flow keyed on the *relay's* identifier sees it. That re-attribution is the whole point:
    /// downstream boards depend on the relay, not on whoever produced the value.
    func testSendOutputThroughReEmitsUnderTheRelayIdentifier() {
        let motherboard = Motherboard()
        let sender = SyncEmittingBoard<Payload>(identifier: .sender)
        let relay = SyncEmittingBoard<Payload>(identifier: .relay)
        motherboard.addBoard(sender)
        motherboard.addBoard(relay)

        var fromRelay: [Payload] = []
        motherboard.registerFlow(matchedIdentifiers: [.relay], uniqueOutputType: Payload.self) {
            fromRelay.append($0)
        }

        motherboard.registerFlow(matchedIdentifiers: .sender, sendOutputThrough: relay)

        sender.activate(withGuaranteedInput: Payload(text: "relayed"))

        XCTAssertEqual(fromRelay, [Payload(text: "relayed")])
        XCTAssertTrue(relay.activatedValues.isEmpty, "the relay re-emits without being activated")
    }

    /// The guaranteed sibling of `bindToBus:` delivers the same way for a matching type.
    func testGuaranteedBindToBusTransportsMatchedOutput() {
        let motherboard = Motherboard()
        let sender = SyncEmittingBoard<Payload>(identifier: .sender)
        motherboard.addBoard(sender)

        let bus = Bus<Payload>()
        var delivered: [Payload] = []
        bus.deliver { delivered.append($0) }

        motherboard.registerGuaranteedFlow(matchedIdentifiers: .sender, bindToBus: bus)

        sender.activate(withGuaranteedInput: Payload(text: "guaranteed"))

        XCTAssertEqual(delivered, [Payload(text: "guaranteed")])
    }

    /// The guaranteed sibling of `sendOutputThrough:`.
    func testGuaranteedSendOutputThroughReEmitsUnderTheRelayIdentifier() {
        let motherboard = Motherboard()
        let sender = SyncEmittingBoard<Payload>(identifier: .sender)
        let relay = SyncEmittingBoard<Payload>(identifier: .relay)
        motherboard.addBoard(sender)
        motherboard.addBoard(relay)

        var fromRelay: [Payload] = []
        motherboard.registerFlow(matchedIdentifiers: [.relay], uniqueOutputType: Payload.self) {
            fromRelay.append($0)
        }

        motherboard.registerGuaranteedFlow(matchedIdentifiers: .sender, sendOutputThrough: relay)

        sender.activate(withGuaranteedInput: Payload(text: "guaranteed relay"))

        XCTAssertEqual(fromRelay, [Payload(text: "guaranteed relay")])
    }

    /// `bindToBus:` routes through the same `target:` machinery as every other overload here, and
    /// `ObjectBox` stores a class weakly. A `Bus` is a class, so the flow does **not** keep it alive:
    /// the caller owns the Bus's lifetime, and dropping it stops delivery rather than leaking it.
    /// Worth pinning — a consumer who builds a Bus inline at the registration site gets silence, and
    /// a change to strong boxing would show up as a leak instead of as this failure.
    func testFlowDoesNotKeepTheBusAliveOnTheCallersBehalf() {
        let motherboard = Motherboard()
        let sender = SyncEmittingBoard<Payload>(identifier: .sender)
        motherboard.addBoard(sender)

        var delivered: [Payload] = []
        var bus: Bus<Payload>? = Bus<Payload>()
        bus?.deliver { delivered.append($0) }
        motherboard.registerFlow(matchedIdentifiers: .sender, bindToBus: bus!)

        sender.activate(withGuaranteedInput: Payload(text: "while the caller holds it"))
        XCTAssertEqual(delivered, [Payload(text: "while the caller holds it")])

        weak var weakBus = bus
        bus = nil
        XCTAssertNil(weakBus, "the flow must not retain the bus")

        sender.activate(withGuaranteedInput: Payload(text: "after the caller let go"))
        XCTAssertEqual(delivered.count, 1, "delivery stops once the caller's bus is gone")
    }
}
