//
//  ComponentKitTests.swift
//  Boardy_Tests
//
//  SLICE S3 — the two documented ComponentKit components with no verification.
//  See docs/02-working-docs/review/2026-08-02-coverage-plan.md §4 items 1.3 and 1.11.
//  DEPENDS ON: TestSupport.swift (`UIHost`).
//
//  Contracts to assert:
//
//  1.3 `FlowBoard` (docs/ComponentKit.md — "a Board with flow registrations only", 0% covered)
//      · the registration closure runs and its flows are live
//      · the activation closure receives the board and the typed input
//      · the interaction closure receives a typed command
//      · `shouldBypassGatewayBarrier()` follows `allowBypassGatewayBarrier`
//
//  1.11 `AlertBoard`
//      · presents a `UIAlertController` with the documented style
//      · an action's handler runs when that action is invoked
//      · `activateAlert(_:)` is equivalent to activating the board directly
//      · the target-based `AlertAction` init holds its target weakly
//
//  API brief — FlowBoard's init is not obvious:
//      FlowBoard<Input, Output, Command, Action>(
//          identifier: BoardID,
//          producer: ActivatableBoardProducer,        // a producer, NOT a motherboard
//          allowBypassGatewayBarrier: Bool = true,
//          flowRegistration: (FlowBoard) -> Void,     // called from init, via registerFlows()
//          flowActivation: (FlowBoard, Input) -> Void,
//          flowInteraction: (FlowBoard, Command) -> Void = <debug-logging default>)
//      `Action` must conform to `BoardFlowAction`.
//      AlertBoard: `Alert(title:message:style:actions:)`, `AlertAction(title:style:shouldBePreferred:handler:)`.
//
//  Traps:
//      · `flowRegistration` runs during `init`, before the board is installed. A registration that
//        assumes a delegate will not see one.
//      · `AlertBoard` presents through `rootViewController`; without a `UIHost` it traps in DEBUG.
//      · Presentation completes synchronously only when the host window is key and visible — `UIHost`
//        does that by default.
//
//  Rules: no wall-clock waits. Do not edit any file outside this one. If production code looks
//  wrong — likely here, since FlowBoard has never executed in a test — stop and report, do not fix.
//

@testable import Boardy
import UIKit
import XCTest

// MARK: - Test Helpers

private enum TestFlowAction: BoardFlowAction {
    case didActivate
    case didInteract
}

private struct TestInput {
    let value: String
}

private struct TestOutput {
    let result: String
}

private struct TestCommand {
    let command: String
}

// MARK: - FlowBoard Tests

final class ComponentKitTests: XCTestCase {}

extension ComponentKitTests {
    // MARK: FlowBoard - flowRegistration runs and flows are live

    func test_flowRegistration_closureRunsDuringInitAndFlowsAreLive() {
        var registrationCalled = false
        var registeredBoard: FlowBoard<TestInput, TestOutput, TestCommand, TestFlowAction>?

        let producer = BoardProducer()
        let board = FlowBoard<TestInput, TestOutput, TestCommand, TestFlowAction>(
            identifier: .flow,
            producer: producer,
            flowRegistration: { board in
                registrationCalled = true
                registeredBoard = board
                board.motherboard.registerGeneralFlow { (_: TestOutput) in }
            },
            flowActivation: { _, _ in }
        )

        XCTAssertTrue(registrationCalled, "flowRegistration should run during init")
        XCTAssertNotNil(registeredBoard, "flowRegistration should receive the board")
        XCTAssertEqual(registeredBoard?.identifier, .flow, "Registration should receive the correct board")
        XCTAssertFalse(board.motherboard.flows.isEmpty, "Flows registered in flowRegistration should be live")
    }

    // MARK: FlowBoard - flowActivation receives board and typed input

    func test_flowActivation_receivesBoardAndTypedInput() {
        var receivedBoard: FlowBoard<TestInput, TestOutput, TestCommand, TestFlowAction>?
        var receivedInput: TestInput?

        let producer = BoardProducer()
        let board = FlowBoard<TestInput, TestOutput, TestCommand, TestFlowAction>(
            identifier: .flow,
            producer: producer,
            flowRegistration: { _ in },
            flowActivation: { board, input in
                receivedBoard = board
                receivedInput = input
            }
        )

        let input = TestInput(value: "test-input")
        board.activate(withGuaranteedInput: input)

        XCTAssertNotNil(receivedBoard, "flowActivation should receive the board")
        XCTAssertEqual(receivedBoard?.identifier, .flow, "flowActivation should receive the correct board")
        XCTAssertEqual(receivedInput?.value, "test-input", "flowActivation should receive the typed input")
    }

    // MARK: FlowBoard - flowInteraction receives typed command

    func test_flowInteraction_receivesTypedCommand() {
        var receivedBoard: FlowBoard<TestInput, TestOutput, TestCommand, TestFlowAction>?
        var receivedCommand: TestCommand?

        let producer = BoardProducer()
        let board = FlowBoard<TestInput, TestOutput, TestCommand, TestFlowAction>(
            identifier: .flow,
            producer: producer,
            flowRegistration: { _ in },
            flowActivation: { _, _ in },
            flowInteraction: { board, command in
                receivedBoard = board
                receivedCommand = command
            }
        )

        let command = TestCommand(command: "test-command")
        board.interact(guaranteedCommand: command)

        XCTAssertNotNil(receivedBoard, "flowInteraction should receive the board")
        XCTAssertEqual(receivedBoard?.identifier, .flow, "flowInteraction should receive the correct board")
        XCTAssertEqual(receivedCommand?.command, "test-command", "flowInteraction should receive the typed command")
    }

    // MARK: FlowBoard - shouldBypassGatewayBarrier follows allowBypassGatewayBarrier

    func test_shouldBypassGatewayBarrier_returnsTrueByDefault() {
        let producer = BoardProducer()
        let board = FlowBoard<TestInput, TestOutput, TestCommand, TestFlowAction>(
            identifier: .flow,
            producer: producer,
            flowRegistration: { _ in },
            flowActivation: { _, _ in }
        )

        XCTAssertTrue(board.shouldBypassGatewayBarrier(), "shouldBypassGatewayBarrier should return true by default")
    }

    func test_shouldBypassGatewayBarrier_returnsFalseWhenSetToFalse() {
        let producer = BoardProducer()
        let board = FlowBoard<TestInput, TestOutput, TestCommand, TestFlowAction>(
            identifier: .flow,
            producer: producer,
            allowBypassGatewayBarrier: false,
            flowRegistration: { _ in },
            flowActivation: { _, _ in }
        )

        XCTAssertFalse(board.shouldBypassGatewayBarrier(), "shouldBypassGatewayBarrier should return false when set to false")
    }

    func test_shouldBypassGatewayBarrier_returnsTrueWhenSetToTrue() {
        let producer = BoardProducer()
        let board = FlowBoard<TestInput, TestOutput, TestCommand, TestFlowAction>(
            identifier: .flow,
            producer: producer,
            allowBypassGatewayBarrier: true,
            flowRegistration: { _ in },
            flowActivation: { _, _ in }
        )

        XCTAssertTrue(board.shouldBypassGatewayBarrier(), "shouldBypassGatewayBarrier should return true when set to true")
    }
}

// MARK: - AlertBoard Tests

extension ComponentKitTests {
    // MARK: AlertBoard - presents UIAlertController with documented style (.alert)

    func test_alertBoard_presentsAlertControllerWithAlertStyle() {
        let host = UIHost()
        let producer = BoardProducer()

        let alertBoard = AlertBoard(identifier: .alert)
        let motherboard = Motherboard(identifier: .main, boardProducer: producer, boards: [alertBoard])
        motherboard.putIntoContext(host.window)

        let alert = Alert(
            title: "Test Title",
            message: "Test Message",
            style: .alert,
            actions: [AlertAction(title: "OK", handler: nil)]
        )

        alertBoard.activate(withGuaranteedInput: alert)

        let presented = host.root.presentedViewController as? UIAlertController
        XCTAssertNotNil(presented, "AlertBoard should present a UIAlertController")
        XCTAssertEqual(presented?.title, "Test Title", "Alert title should match")
        XCTAssertEqual(presented?.message, "Test Message", "Alert message should match")
        XCTAssertEqual(presented?.preferredStyle, .alert, "Alert style should be .alert")
    }

    // MARK: AlertBoard - presents UIAlertController with documented style (.actionSheet)

    func test_alertBoard_presentsAlertControllerWithActionSheetStyle() {
        let host = UIHost()
        let producer = BoardProducer()

        let alertBoard = AlertBoard(identifier: .alert)
        let motherboard = Motherboard(identifier: .main, boardProducer: producer, boards: [alertBoard])
        motherboard.putIntoContext(host.window)

        let alert = Alert(
            title: "Sheet Title",
            message: "Sheet Message",
            style: .actionSheet,
            actions: [AlertAction(title: "Action", handler: nil)]
        )

        alertBoard.activate(withGuaranteedInput: alert)

        let presented = host.root.presentedViewController as? UIAlertController
        XCTAssertNotNil(presented, "AlertBoard should present a UIAlertController")
        XCTAssertEqual(presented?.preferredStyle, .actionSheet, "Alert style should be .actionSheet")
    }

    // MARK: AlertBoard - actions have matching titles

    func test_alertBoard_actionsHaveMatchingTitles() {
        let host = UIHost()
        let producer = BoardProducer()

        let alertBoard = AlertBoard(identifier: .alert)
        let motherboard = Motherboard(identifier: .main, boardProducer: producer, boards: [alertBoard])
        motherboard.putIntoContext(host.window)

        let alert = Alert(
            title: nil,
            message: nil,
            style: .alert,
            actions: [
                AlertAction(title: "First", handler: nil),
                AlertAction(title: "Second", handler: nil),
                AlertAction(title: "Third", handler: nil),
            ]
        )

        alertBoard.activate(withGuaranteedInput: alert)

        let presented = host.root.presentedViewController as? UIAlertController
        XCTAssertEqual(presented?.actions.count, 3, "Should have 3 actions")
        XCTAssertEqual(presented?.actions[0].title, "First")
        XCTAssertEqual(presented?.actions[1].title, "Second")
        XCTAssertEqual(presented?.actions[2].title, "Third")
    }

    // MARK: AlertBoard - preferredAction set when shouldBePreferred is true

    func test_alertBoard_preferredActionSetWhenShouldBePreferredIsTrue() {
        let host = UIHost()
        let producer = BoardProducer()

        let alertBoard = AlertBoard(identifier: .alert)
        let motherboard = Motherboard(identifier: .main, boardProducer: producer, boards: [alertBoard])
        motherboard.putIntoContext(host.window)

        let alert = Alert(
            title: nil,
            message: nil,
            style: .alert,
            actions: [
                AlertAction(title: "Cancel", style: .cancel, handler: nil),
                AlertAction(title: "OK", style: .default, shouldBePreferred: true, handler: nil),
            ]
        )

        alertBoard.activate(withGuaranteedInput: alert)

        let presented = host.root.presentedViewController as? UIAlertController
        XCTAssertNotNil(presented?.preferredAction, "preferredAction should be set")
        XCTAssertEqual(presented?.preferredAction?.title, "OK", "preferredAction should be the action with shouldBePreferred = true")
    }

    // MARK: AlertBoard - action handler runs when invoked

    func test_alertAction_handlerRunsWhenInvoked() {
        var handlerCalled = false

        let action = AlertAction(title: "Test", handler: {
            handlerCalled = true
        })

        action.handler?()

        XCTAssertTrue(handlerCalled, "Handler should run when invoked")
    }

    // MARK: AlertBoard - target-based init holds target weakly

    func test_alertAction_targetBasedInit_holdsTargetWeakly() {
        class TestTarget: NSObject {
            var callCount = 0
            func handle() {
                callCount += 1
            }
        }

        // The contract is that the *caller's* closure is skipped once the target is gone — count its
        // invocations rather than asserting a flag this test sets itself, which would pass either way.
        var closureInvocations = 0

        var target: TestTarget? = TestTarget()
        weak var weakTarget = target

        let action = AlertAction(title: "Test", target: target!, handler: { t in
            closureInvocations += 1
            t.handle()
        })

        // Handler should work while target is alive
        action.handler?()
        XCTAssertEqual(closureInvocations, 1, "Handler should run while the target is alive")
        XCTAssertEqual(target?.callCount, 1, "Handler should call target while alive")

        // Release the target
        target = nil
        XCTAssertNil(weakTarget, "Target should be deallocated")

        // Invoking the stored handler must not crash and must not reach the released target.
        action.handler?()
        XCTAssertEqual(closureInvocations, 1, "Handler must not run once the target is released")
    }

    // MARK: AlertBoard - activateAlert installs and presents alert

    func test_activateAlert_installsAndPresentsAlert() {
        let host = UIHost()
        let producer = BoardProducer()

        let motherboard = Motherboard(identifier: .main, boardProducer: producer, boards: [])
        motherboard.putIntoContext(host.window)

        let alert = Alert(
            title: "Via Extension",
            message: "Direct activation",
            style: .alert,
            actions: [AlertAction(title: "OK", handler: nil)]
        )

        motherboard.activateAlert(alert)

        let presented = host.root.presentedViewController as? UIAlertController
        XCTAssertNotNil(presented, "activateAlert should present a UIAlertController")
        XCTAssertEqual(presented?.title, "Via Extension", "Alert title should match")
    }
}

// MARK: - BoardID Extensions

private extension BoardID {
    static let flow = BoardID(rawValue: "test-flow")
    static let alert = BoardID(rawValue: "test-alert")
    static let main = BoardID(rawValue: "test-main")
}
