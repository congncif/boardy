//
//  ServiceMapTests.swift
//  Boardy_Tests
//
//  SLICE S4 — ServiceMap and bulk board registration.
//  See docs/02-working-docs/review/2026-08-02-coverage-plan.md §4 items 1.4 and 1.9.
//

@testable import Boardy
#if canImport(CwlPreconditionTesting)
    import CwlPreconditionTesting
#endif
import XCTest

// MARK: - Local ServiceMap fixtures

private final class AlphaServiceMap: ServiceMap {}

private final class BetaServiceMap: ServiceMap {}

private extension ServiceMap {
    var modAlpha: AlphaServiceMap { link() }
    var modBeta: BetaServiceMap { link() }
}

private extension AlphaServiceMap {
    var ioAlpha: MainboardDestination { mainboard.ioDestination(.alpha) }
}

private extension BetaServiceMap {
    var ioBeta: MainboardDestination { mainboard.ioDestination(.beta) }
}

private extension BoardID {
    static let alpha: BoardID = "alpha"
    static let beta: BoardID = "beta"
    static let gamma: BoardID = "gamma"
    static let delta: BoardID = "delta"
    static let epsilon: BoardID = "epsilon"
    static let orphan: BoardID = "orphan"
}

// MARK: - Tests

final class ServiceMapTests: XCTestCase {
    // MARK: Contract 1 — ServiceMap reachability

    /// motherboard.serviceMap is reachable on any FlowMotherboard, and the returned map's
    /// mainboard is that motherboard.
    func testMotherboardServiceMapExposesThatMotherboard() {
        let motherboard = Motherboard()
        let map = motherboard.serviceMap
        XCTAssertTrue(map.mainboard === motherboard)
    }

    /// board.serviceMap reaches the same map through the board's motherboard — install a board,
    /// then assert its serviceMap.mainboard is the motherboard it was installed into.
    func testInstalledBoardServiceMapReachesTheMotherboard() {
        let motherboard = Motherboard()
        let installed = RecordingBoard(identifier: .alpha)
        motherboard.addBoard(installed)
        XCTAssertTrue(installed.serviceMap.mainboard === motherboard)
    }

    /// A board with no motherboard traps. preconditionFailure is the documented precondition,
    /// so assert it fires — catch it with CwlPreconditionTesting.catchBadInstruction.
    func testUninstalledBoardServiceMapTrapsWithPrecondition() throws {
        let orphan = RecordingBoard(identifier: .orphan)

        #if canImport(CwlPreconditionTesting)
            var assertionCalled = false
            let exceptionGuard: CwlPreconditionTesting.BadInstructionException? =
                CwlPreconditionTesting.catchBadInstruction {
                    assertionCalled = true
                    _ = orphan.serviceMap
                }

            XCTAssertNotNil(exceptionGuard)
            XCTAssertTrue(assertionCalled)
        #else
            throw XCTSkip("CwlPreconditionTesting is only available in the CocoaPods/Xcode test host")
        #endif
    }

    // MARK: Contract 2 — Module extension pattern

    /// A ServiceMap subclass reached via link() shares the same mainboard instance as the parent
    /// map.
    func testLinkedModuleMapSharesTheParentMotherboard() {
        let motherboard = Motherboard()
        let parent = motherboard.serviceMap
        let linked = parent.modAlpha

        XCTAssertTrue(linked.mainboard === parent.mainboard)
        XCTAssertTrue(linked.mainboard === motherboard)
    }

    /// An accessor added on the subclass returns a destination pointing at the identifier the
    /// subclass's extension asked for.
    func testSubclassAccessorReturnsDestinationWithExpectedIdentifier() {
        let motherboard = Motherboard()
        let destination = motherboard.serviceMap.modAlpha.ioAlpha
        XCTAssertEqual(destination.destinationID, .alpha)
    }

    /// Two different module maps linked from the same ServiceMap both see that one
    /// motherboard. The second half of this contract — that neither exposes the other's
    /// accessors — is a compile-time property and cannot be asserted at runtime.
    func testTwoModuleMapsLinkedFromSameServiceMapShareTheMotherboard() {
        let motherboard = Motherboard()
        let parent = motherboard.serviceMap

        let alpha = parent.modAlpha
        let beta = parent.modBeta

        XCTAssertTrue(alpha.mainboard === beta.mainboard)
        XCTAssertTrue(alpha.mainboard === motherboard)
        XCTAssertTrue(beta.mainboard === motherboard)
    }

    // MARK: Contract 3 — link(_:) semantics

    /// link() constructs a new instance of the requested subclass each call, sharing mainboard.
    /// Two reads must therefore produce distinct objects with the same mainboard — pin this so
    /// a future change to caching does not slip through unnoticed.
    func testLinkReturnsFreshInstanceEachCallSharingMainboard() {
        let motherboard = Motherboard()

        let first = motherboard.serviceMap.modAlpha
        let second = motherboard.serviceMap.modAlpha

        XCTAssertFalse(first === second)
        XCTAssertTrue(first.mainboard === second.mainboard)
        XCTAssertTrue(first.mainboard === motherboard)
    }

    // MARK: Contract 4 — registerBoards (BoardContainer only)

    /// Several identifiers can share one factory: register three, then produce each and assert
    /// each comes back.
    func testRegisterBoardsSharesOneFactoryAcrossIdentifiers() {
        let container = BoardContainer()
        container.registerBoards(.alpha, .beta, .gamma) { identifier in
            RecordingBoard(identifier: identifier)
        }

        XCTAssertNotNil(container.produceBoard(identifier: .alpha))
        XCTAssertNotNil(container.produceBoard(identifier: .beta))
        XCTAssertNotNil(container.produceBoard(identifier: .gamma))
    }

    /// Each identifier produces its own instance — the factory receives the identifier being
    /// produced, so assert the produced boards carry the right identifiers and are not the
    /// same object.
    func testRegisterBoardsProducesDistinctInstancesPerIdentifier() {
        let container = BoardContainer()
        container.registerBoards(.alpha, .beta) { identifier in
            RecordingBoard(identifier: identifier)
        }

        guard
            let alpha = container.produceBoard(identifier: .alpha) as? RecordingBoard,
            let beta = container.produceBoard(identifier: .beta) as? RecordingBoard
        else {
            XCTFail("Expected RecordingBoard instances for both identifiers")
            return
        }

        XCTAssertEqual(alpha.identifier, .alpha)
        XCTAssertEqual(beta.identifier, .beta)
        XCTAssertFalse(alpha === beta)
    }

    /// The variadic form and the array form agree.
    ///
    /// Both forms are given the *same* identifiers, so the comparison is between the two overloads
    /// rather than between two unrelated registrations — a divergence in either direction shows up
    /// as a mismatch instead of as a silent pass.
    func testRegisterBoardsVariadicAndArrayFormsAgree() {
        let identifiers: [BoardID] = [.alpha, .beta, .gamma]

        let variadic = BoardContainer()
        variadic.registerBoards(.alpha, .beta, .gamma) { identifier in
            RecordingBoard(identifier: identifier)
        }

        let array = BoardContainer()
        array.registerBoards(identifiers) { identifier in
            RecordingBoard(identifier: identifier)
        }

        for identifier in identifiers {
            XCTAssertEqual(
                variadic.produceBoard(identifier: identifier)?.identifier,
                array.produceBoard(identifier: identifier)?.identifier,
                "the two overloads must register \(identifier) identically"
            )
            XCTAssertEqual(variadic.produceBoard(identifier: identifier)?.identifier, identifier)
        }

        // Neither form registers anything it was not given.
        XCTAssertNil(variadic.produceBoard(identifier: .delta))
        XCTAssertNil(array.produceBoard(identifier: .delta))
    }
}
