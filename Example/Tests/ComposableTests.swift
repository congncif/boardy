//
//  ComposableTests.swift
//  Boardy_Tests
//
//  Covers Boardy/Composable, which had no test at all: the subsystem is excluded from the
//  CocoaPods `Default` subspec's own tests and was never exercised from the example app.
//

@testable import Boardy
import UIComposable
import UIKit
import XCTest

/// Records what a composable interface was asked to render.
private final class SpyComposableInterface: ComposableInterface {
    private(set) var composedElements: [UIElement] = []
    private(set) var compositions: [[UIElement]] = []

    func composeInterface(elements: [UIElement]) {
        composedElements = elements
        compositions.append(elements)
    }
}

/// Same, but a class the framework recognises as a `ComposableInterfaceObject` and therefore wraps
/// in `UIComposableAdapter` instead of storing directly.
private final class SpyComposableInterfaceObject: ComposableInterface, AnyObject {
    private(set) var composedElements: [UIElement] = []

    func composeInterface(elements: [UIElement]) {
        composedElements = elements
    }
}

private final class ComposingBoard: Board, ActivatableBoard {
    func activate(withOption option: Any?) {
        guard let action = option as? UIElementAction else { return }
        putToComposer(elementAction: action)
    }
}

private final class PlainBoard: Board, ActivatableBoard {
    private(set) var activationCount = 0
    func activate(withOption _: Any?) { activationCount += 1 }
}

/// A composable interface that can also hold attached objects, for the `attach…` overloads.
private final class SpyAttachableInterface: UIViewController, ComposableInterface {
    private(set) var composedElements: [UIElement] = []

    func composeInterface(elements: [UIElement]) {
        composedElements = elements
    }
}

private final class HostBoard: ModernContinuableBoard, ActivatableBoard {
    func activate(withOption _: Any?) {}
}

final class ComposableTests: XCTestCase {
    private func element(_ id: BoardID) -> UIElement {
        UIElement(identifier: id, contentViewController: UIViewController())
    }

    // MARK: - UIElement identifier overload

    /// The `BoardID` overload must unwrap to the same identifier UIComposable matches on; if it
    /// stringified the wrapper instead, every element would silently fail to match.
    func testUIElementBoardIDOverloadUsesRawValue() {
        let viewController = UIViewController()
        let composed = UIElement(identifier: BoardID("panel"), contentViewController: viewController)

        XCTAssertEqual(composed.identifier, "panel")
        XCTAssertTrue(composed.contentViewController === viewController)
    }

    // MARK: - connect(to:)

    func testConnectStoresANonObjectInterfaceDirectly() {
        let motherboard = ComposableMotherboard()
        let spy = SpyComposableInterface()

        motherboard.connect(to: spy)

        XCTAssertNotNil(motherboard.composableInterface)
    }

    func testConnectWrapsAnInterfaceObjectInAnAdapter() {
        let motherboard = ComposableMotherboard()
        let spy = SpyComposableInterfaceObject()

        motherboard.connect(to: spy)

        XCTAssertTrue(motherboard.composableInterface is UIComposableAdapter,
                      "a class interface must be adapted, not retained directly")
    }

    func testHandleUIElementActionWithoutAConnectedInterfaceIsANoOp() {
        let motherboard = ComposableMotherboard()

        // No interface connected: this must not trap.
        motherboard.handleUIElementAction(.update(element: element("panel")))
    }

    // MARK: - Board to interface

    /// The path a feature module actually uses: a board emits a UI element and the composable
    /// motherboard renders it, with no explicit wiring in between.
    func testBoardElementActionReachesTheConnectedInterface() {
        let board = ComposingBoard(identifier: "panel")
        let motherboard = ComposableMotherboard(boards: [board])
        let spy = SpyComposableInterface()
        motherboard.connect(to: spy)

        motherboard.activateBoard(identifier: "panel", withOption: UIElementAction.update(element: element("panel")))

        XCTAssertEqual(spy.compositions.count, 1)
        XCTAssertEqual(spy.composedElements.map(\.identifier), ["panel"])
    }

    func testSecondElementIsComposedAlongsideTheFirst() {
        let first = ComposingBoard(identifier: "first")
        let second = ComposingBoard(identifier: "second")
        let motherboard = ComposableMotherboard(boards: [first, second])
        let spy = SpyComposableInterface()
        motherboard.connect(to: spy)

        motherboard.activateBoard(identifier: "first", withOption: UIElementAction.update(element: element("first")))
        motherboard.activateBoard(identifier: "second", withOption: UIElementAction.update(element: element("second")))

        XCTAssertEqual(spy.composedElements.map(\.identifier), ["first", "second"])
    }

    func testRemoveContentActionUpdatesTheComposedElement() {
        let board = ComposingBoard(identifier: "panel")
        let motherboard = ComposableMotherboard(boards: [board])
        let spy = SpyComposableInterface()
        motherboard.connect(to: spy)

        motherboard.activateBoard(identifier: "panel", withOption: UIElementAction.update(element: element("panel")))
        XCTAssertNotNil(spy.composedElements.first?.contentViewController)

        motherboard.activateBoard(identifier: "panel", withOption: UIElementAction.removeContent(identifier: "panel"))

        XCTAssertEqual(spy.composedElements.map(\.identifier), ["panel"])
        XCTAssertNil(spy.composedElements.first?.contentViewController)
    }

    // MARK: - Flow registration difference

    /// `ComposableMotherboard` overrides `registerDefaultFlows` and deliberately omits the
    /// activation flow, because activation is forwarded to the parent motherboard instead. A plain
    /// `Motherboard` does register it. This is the one behavioral difference between the two, and
    /// nothing covered it.
    func testComposableMotherboardDoesNotRegisterTheActivationFlow() {
        let composableTarget = PlainBoard(identifier: "target")
        let composable = ComposableMotherboard(boards: [composableTarget])

        let plainTarget = PlainBoard(identifier: "target")
        let plain = Motherboard(boards: [plainTarget])

        let model = BoardInput(target: BoardID("target"), input: "value")
        composable.board(composableTarget, didSendData: model)
        plain.board(plainTarget, didSendData: model)

        XCTAssertEqual(plainTarget.activationCount, 1, "a plain motherboard routes an activation model")
        XCTAssertEqual(composableTarget.activationCount, 0, "a composable motherboard forwards it upward instead")
    }

    /// The flows it does keep must still work: completion still removes the board.
    func testComposableMotherboardStillHandlesCompletion() {
        let board = PlainBoard(identifier: "panel")
        let motherboard = ComposableMotherboard(boards: [board])
        XCTAssertEqual(motherboard.boards.count, 1)

        board.complete()

        XCTAssertTrue(motherboard.boards.isEmpty)
    }

    // MARK: - produceComposableMotherboard

    /// The composable motherboard a board mounts is wired to forward both action and activation
    /// flows up to that board. Activation forwarding is the reason `ComposableMotherboard` omits
    /// its own activation flow, so the two halves have to be checked together.
    func testProduceComposableMotherboardForwardsActionAndActivationToTheParent() throws {
        let parent = HostBoard(identifier: "host", boardProducer: BoardProducer())
        let parentMotherboard = Motherboard(boards: [parent])
        let target = PlainBoard(identifier: "target")
        parentMotherboard.installBoard(target)

        let producer = BoardProducer()
        let child = producer.produceComposableMotherboard(identifier: "child", from: parent)
        let concreteChild = try XCTUnwrap(child as? ComposableMotherboard)

        // An activation model emitted inside the child must reach the parent's motherboard, which
        // is the whole reason ComposableMotherboard does not register an activation flow itself.
        concreteChild.board(target, didSendData: BoardInput(target: BoardID("target"), input: "value"))

        XCTAssertEqual(target.activationCount, 1)
    }

    func testProduceComposableMotherboardWithoutAParentInstallsTheBuiltElements() {
        let producer = BoardProducer()
        let child = producer.produceComposableMotherboard(identifier: "child") { _ in
            [PlainBoard(identifier: "a"), PlainBoard(identifier: "b")]
        }

        XCTAssertEqual(child.boards.map(\.identifier), ["a", "b"])
        XCTAssertEqual(child.identifier, "child")
    }

    // MARK: - mount / attach

    func testMountComposableMotherboardConnectsAndContextualisesTheInterface() {
        let host = HostBoard(identifier: "host", boardProducer: BoardProducer())
        let interface = SpyAttachableInterface()

        var configured: FlowComposableMotherboard?
        let mounted = host.mountComposableMotherboard(to: interface) { motherboard in
            configured = motherboard
        }

        XCTAssertTrue(configured === mounted)
        XCTAssertTrue(mounted.context === interface)
        XCTAssertEqual(mounted.identifier, BoardID("host").appending("composable-main"))
    }

    func testMountComposableMotherboardWithACustomBuilderUsesTheBuiltBoard() {
        let host = HostBoard(identifier: "host", boardProducer: BoardProducer())
        let interface = SpyAttachableInterface()

        let mounted = host.mountComposableMotherboard(to: interface) { producer in
            ComposableMotherboard(identifier: "custom", boardProducer: producer)
        }

        XCTAssertEqual(mounted.identifier, "custom")
        XCTAssertTrue(mounted.context === interface)
    }

    /// `attach…` differs from `mount…` only by handing the motherboard to the interface to retain.
    func testAttachComposableMotherboardHandsTheBoardToTheInterface() {
        let host = HostBoard(identifier: "host", boardProducer: BoardProducer())
        let interface = SpyAttachableInterface()

        let attached = host.attachComposableMotherboard(to: interface)

        XCTAssertTrue(attached.context === interface)
        XCTAssertFalse(interface.attachedObjects().isEmpty, "the interface must retain the motherboard")
    }

    func testAttachComposableMotherboardWithACustomBuilder() {
        let host = HostBoard(identifier: "host", boardProducer: BoardProducer())
        let interface = SpyAttachableInterface()

        let attached = host.attachComposableMotherboard(to: interface) { producer in
            ComposableMotherboard(identifier: "custom", boardProducer: producer)
        }

        XCTAssertEqual(attached.identifier, "custom")
        XCTAssertFalse(interface.attachedObjects().isEmpty)
    }
}
