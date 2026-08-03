//
//  GatewayBarrierTests.swift
//  Boardy_Tests
//
//  SLICE S1 — Gateway Barrier. See docs/02-working-docs/review/2026-08-02-coverage-plan.md §4.
//
//  Contracts to assert (from docs/Activation Barrier.md §🛡️ and §⛳):
//
//  1.1 Conditional gateway — `GatewayBarrierRegistration.registerWithActivation`
//      · the gate is activated before the destination board is
//      · gate completes true  → destination activates, with its original option
//      · gate completes false → destination does NOT activate
//      · `withFlowRegistration` is invoked so the gate can wire its own flow
//      · the barrier board is removed once the gate resolves
//
//  1.2 Bypass
//      · a board returning `shouldBypassGatewayBarrier() == true` activates without the gate running
//      · `.exempt` registered for one identifier bypasses only that identifier
//      · `.wildcard` gateway registration applies to every other identifier
//
//  API brief — verified signatures, do not guess:
//      GatewayBarrierRegistration.registerWithActivation { (barrier: GatewayBarrierBoard, option: Any?) in }
//          .withFlowRegistration { (barrier: GatewayBarrierBoard) in }
//      PluginLauncher.with(options: .default)
//          .install(plugin:) .install(gatewayBarrier:for:) .install(gatewayBarrier:)
//          .instantiate { mainboard in } → then .activateNow { mainboard in }
//      Producer-side: BoardProducer.registerGatewayBoard(_:factory:) — note it appends
//          `.gateway` to the identifier internally; `.wildcard.gateway` is the catch-all key.
//
//  Traps already hit in this repo:
//      · Activating an identifier nothing is registered for produces a `NoBoard`, whose activation
//        presents an alert and traps in DEBUG without a UIKit context. Register every identifier a
//        test activates, or install a `UIHost`.
//      · A gateway barrier that never completes leaves the activation queued — that is the designed
//        behaviour, not a hang. Assert "not activated", never wait for it.
//
//  Rules: no wall-clock waits; use `hangGuardTimeout` for deadlock guards only; name each test after
//  the contract it asserts. Do not edit any file outside this one. If production code looks wrong,
//  stop and report — do not fix it here.
//

@testable import Boardy
import XCTest

final class GatewayBarrierTests: XCTestCase {
    // MARK: - Contract 1.1: Conditional Gateway Activation

    func testGatewayActivatesBeforeDestinationBoard() {
        let destinationID: BoardID = "gated-destination"
        let destination = RecordingBoard(identifier: destinationID)
        var gateActivatedFirst = false
        var destinationActivatedAfter = false

        let launcher = PluginLauncher.with(options: .default)
            .install(plugin: SingleBoardPlugin(board: destination))
            .install(gatewayBarrier: .registerWithActivation { barrier, _ in
                gateActivatedFirst = destination.activationCount == 0
                barrier.complete(true)
                destinationActivatedAfter = destination.activationCount == 1
            })
            .instantiate { _ in }

        launcher.activateNow { mainboard in
            mainboard.activateBoard(identifier: destinationID, withOption: "test")
        }

        XCTAssertTrue(gateActivatedFirst, "Gate must activate before destination")
        XCTAssertTrue(destinationActivatedAfter, "Destination must activate after gate completes")
        XCTAssertEqual(destination.activationCount, 1)
    }

    func testGateCompletingTrueActivatesDestinationWithOriginalOption() {
        let destinationID: BoardID = "gated-destination"
        let destination = RecordingBoard(identifier: destinationID)
        let expectedOption = "original-option"

        let launcher = PluginLauncher.with(options: .default)
            .install(plugin: SingleBoardPlugin(board: destination))
            .install(gatewayBarrier: .registerWithActivation { barrier, _ in
                barrier.complete(true)
            })
            .instantiate { _ in }

        launcher.activateNow { mainboard in
            mainboard.activateBoard(identifier: destinationID, withOption: expectedOption)
        }

        XCTAssertEqual(destination.activationCount, 1)
        XCTAssertEqual(destination.activatedOptions.first as? String, expectedOption)
    }

    func testGateCompletingFalseDoesNotActivateDestination() {
        let destinationID: BoardID = "blocked-destination"
        let destination = RecordingBoard(identifier: destinationID)

        let launcher = PluginLauncher.with(options: .default)
            .install(plugin: SingleBoardPlugin(board: destination))
            .install(gatewayBarrier: .registerWithActivation { barrier, _ in
                barrier.complete(false)
            })
            .instantiate { _ in }

        launcher.activateNow { mainboard in
            mainboard.activateBoard(identifier: destinationID, withOption: "blocked")
        }

        XCTAssertEqual(destination.activationCount, 0, "Destination must not activate when gate completes false")
    }

    func testWithFlowRegistrationIsInvoked() {
        let destinationID: BoardID = "gated-destination"
        let destination = RecordingBoard(identifier: destinationID)
        var flowRegistrationInvoked = false
        var capturedBarrier: GatewayBarrierBoard?

        let launcher = PluginLauncher.with(options: .default)
            .install(plugin: SingleBoardPlugin(board: destination))
            .install(gatewayBarrier: .registerWithActivation { barrier, _ in
                barrier.complete(true)
            }.withFlowRegistration { barrier in
                flowRegistrationInvoked = true
                capturedBarrier = barrier
            })
            .instantiate { _ in }

        launcher.activateNow { mainboard in
            mainboard.activateBoard(identifier: destinationID, withOption: nil)
        }

        XCTAssertTrue(flowRegistrationInvoked, "withFlowRegistration must be invoked")
        XCTAssertNotNil(capturedBarrier, "Barrier must be provided to flow registration")
    }

    func testBarrierBoardRemovedAfterCompletion() {
        let destinationID: BoardID = "gated-destination"
        let destination = RecordingBoard(identifier: destinationID)

        let launcher = PluginLauncher.with(options: .default)
            .install(plugin: SingleBoardPlugin(board: destination))
            .install(gatewayBarrier: .registerWithActivation { barrier, _ in
                barrier.complete(true)
            })
            .instantiate { _ in }

        var mainboardCapture: FlowMotherboard?
        launcher.activateNow { mainboard in
            mainboardCapture = mainboard
            mainboard.activateBoard(identifier: destinationID, withOption: nil)
        }

        guard let mainboard = mainboardCapture else {
            XCTFail("Mainboard not captured")
            return
        }

        // `getGatewayBoard` installs two boards: the gateway board itself, and the private
        // activation barrier that serialises pending activations. Resolving the gate must retire
        // both — asserting only the first would leave the second free to leak unnoticed.
        let remaining = mainboard.boards.map(\.identifier)
        XCTAssertFalse(
            remaining.contains(destinationID.gateway),
            "the gateway board must be removed once the gate resolves"
        )
        XCTAssertFalse(
            remaining.contains { $0.rawValue.contains("___PRIVATE_BARRIER___") },
            "the private activation barrier must be removed once the gate resolves"
        )
        XCTAssertEqual(remaining, [destinationID], "only the destination board may survive the gate")
    }

    // MARK: - Contract 1.2: Bypass Mechanisms

    func testBoardReturningTrueBypassesGateway() {
        let destinationID: BoardID = "bypassing-destination"
        var gateActivationCount = 0

        let bypassingBoard = BypassingBoard(identifier: destinationID)

        let launcher = PluginLauncher.with(options: .default)
            .install(plugin: SingleBoardPlugin(board: bypassingBoard))
            .install(gatewayBarrier: .registerWithActivation { barrier, _ in
                gateActivationCount += 1
                barrier.complete(true)
            })
            .instantiate { _ in }

        launcher.activateNow { mainboard in
            mainboard.activateBoard(identifier: destinationID, withOption: "bypass")
        }

        XCTAssertEqual(gateActivationCount, 0, "Gate must not activate for bypassing board")
        XCTAssertEqual(bypassingBoard.activationCount, 1, "Bypassing board must activate directly")
    }

    func testExemptRegistrationBypassesSpecificIdentifier() {
        let exemptID: BoardID = "exempt-destination"
        let gatedID: BoardID = "gated-destination"

        let exemptBoard = RecordingBoard(identifier: exemptID)
        let gatedBoard = RecordingBoard(identifier: gatedID)

        var gateActivationCount = 0

        let launcher = PluginLauncher.with(options: .default)
            .install(plugin: SingleBoardPlugin(board: exemptBoard))
            .install(plugin: SingleBoardPlugin(board: gatedBoard))
            .install(gatewayBarrier: .exempt, for: exemptID)
            .install(gatewayBarrier: .registerWithActivation { barrier, _ in
                gateActivationCount += 1
                barrier.complete(true)
            })
            .instantiate { _ in }

        launcher.activateNow { mainboard in
            mainboard.activateBoard(identifier: exemptID, withOption: "exempt")
            mainboard.activateBoard(identifier: gatedID, withOption: "gated")
        }

        XCTAssertEqual(exemptBoard.activationCount, 1, "Exempt board must activate")
        XCTAssertEqual(gatedBoard.activationCount, 1, "Gated board must activate after gate")
        XCTAssertEqual(gateActivationCount, 1, "Gate must activate only for non-exempt board")
    }

    func testWildcardGatewayAppliesToNonSpecificIdentifiers() {
        let specificID: BoardID = "specific-exempt"
        let wildcardID1: BoardID = "wildcard-destination-1"
        let wildcardID2: BoardID = "wildcard-destination-2"

        let specificBoard = RecordingBoard(identifier: specificID)
        let wildcardBoard1 = RecordingBoard(identifier: wildcardID1)
        let wildcardBoard2 = RecordingBoard(identifier: wildcardID2)

        var wildcardGateCount = 0

        let launcher = PluginLauncher.with(options: .default)
            .install(plugin: SingleBoardPlugin(board: specificBoard))
            .install(plugin: SingleBoardPlugin(board: wildcardBoard1))
            .install(plugin: SingleBoardPlugin(board: wildcardBoard2))
            .install(gatewayBarrier: .exempt, for: specificID)
            .install(gatewayBarrier: .registerWithActivation { barrier, _ in
                wildcardGateCount += 1
                barrier.complete(true)
            })
            .instantiate { _ in }

        launcher.activateNow { mainboard in
            mainboard.activateBoard(identifier: specificID, withOption: nil)
            mainboard.activateBoard(identifier: wildcardID1, withOption: nil)
            mainboard.activateBoard(identifier: wildcardID2, withOption: nil)
        }

        XCTAssertEqual(specificBoard.activationCount, 1)
        XCTAssertEqual(wildcardBoard1.activationCount, 1)
        XCTAssertEqual(wildcardBoard2.activationCount, 1)
        XCTAssertEqual(wildcardGateCount, 2, "Wildcard gate must apply to both non-exempt boards")
    }
}

// MARK: - Test Support

private class SingleBoardPlugin: ModulePlugin {
    let identifier: BoardID
    let board: ActivatableBoard

    init(board: ActivatableBoard) {
        identifier = board.identifier
        self.board = board
    }

    func apply(for main: MainComponent) {
        main.producer.registerBoard(board.identifier) { [board] _ in board }
    }
}

private final class BypassingBoard: Board, ActivatableBoard {
    private(set) var activationCount = 0

    func activate(withOption _: Any?) {
        activationCount += 1
    }

    func shouldBypassGatewayBarrier() -> Bool {
        true
    }
}
