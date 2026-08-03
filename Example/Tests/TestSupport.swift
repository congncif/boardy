//
//  TestSupport.swift
//  Boardy_Tests
//
//  Shared helpers for the whole test target. Anything used by more than one test file belongs here
//  rather than being redefined per file — six files had already grown their own near-identical
//  board doubles under slightly different names.
//

@testable import Boardy
import UIKit
import XCTest

// MARK: - Timeouts

/// Upper bound for any wait in this test target.
///
/// Every wait here is signalled by a controlled executor, an injected completion or a run-loop turn
/// — never by elapsed time. The timeout exists only so a hung test fails instead of blocking the
/// suite, so it is deliberately generous: a value tight enough to be exceeded on a loaded CI runner
/// turns a deadlock guard into a flake. Two of them did exactly that and failed a release.
let hangGuardTimeout: TimeInterval = 10

// MARK: - UIKit host

/// A live window a board can be installed into.
///
/// Boards reach UIKit through their context, so anything exercising `rootViewController`,
/// `navigationController`, `tabBarController`, or a board that presents — `AlertBoard`, any UI board
/// — needs a real one. Without it those paths are unreachable from tests, which is why they sat at
/// 0% while the rest of the library was covered.
///
/// ```swift
/// let host = UIHost()
/// motherboard.putIntoContext(host.window)
/// motherboard.activateBoard(identifier: .alert, withOption: alert)
/// XCTAssertTrue(host.root.presentedViewController is UIAlertController)
/// ```
///
/// Hold it for the duration of the test: releasing it tears the window down.
final class UIHost {
    /// The view controller a board's `rootViewController` resolves to when the host is navigation-
    /// based (the default), i.e. the navigation controller itself.
    let window: UIWindow

    /// The content view controller presentations land on.
    let root: UIViewController

    /// Present only when the host was built with `navigationBased: true` (the default).
    let navigationController: UINavigationController?

    /// Present only when the host was built with `tabBarBased: true`.
    let tabBarController: UITabBarController?

    /// - Parameters:
    ///   - navigationBased: wraps `root` in a `UINavigationController`, so
    ///     `board.navigationController` resolves. Default `true`.
    ///   - tabBarBased: additionally wraps in a `UITabBarController`, so
    ///     `board.tabBarController` resolves. Default `false`.
    ///   - visible: calls `makeKeyAndVisible()`. Required for presentation to complete
    ///     synchronously, which is what lets a test assert without waiting. Default `true`.
    init(navigationBased: Bool = true, tabBarBased: Bool = false, visible: Bool = true) {
        let content = UIViewController()
        root = content

        var top: UIViewController = content

        if navigationBased {
            let nav = UINavigationController(rootViewController: content)
            navigationController = nav
            top = nav
        } else {
            navigationController = nil
        }

        if tabBarBased {
            let tab = UITabBarController()
            tab.viewControllers = [top]
            tabBarController = tab
            top = tab
        } else {
            tabBarController = nil
        }

        window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = top

        if visible {
            window.makeKeyAndVisible()
        }
    }

    deinit {
        window.rootViewController = nil
        window.isHidden = true
    }
}

// MARK: - Board doubles

/// Records every option it was activated with, and nothing else.
///
/// The default choice when a test needs to know *whether* and *with what* a board was activated.
final class RecordingBoard: Board, ActivatableBoard {
    private(set) var activatedOptions: [Any?] = []

    var activationCount: Int { activatedOptions.count }

    func activate(withOption option: Any?) {
        activatedOptions.append(option)
    }
}

/// Emits its input during `activate`, with no queue hop.
///
/// Use this when the behaviour under test is the routing, not the asynchrony: the assertion can run
/// on the next line with nothing to wait for. Reach for ``AsyncEmittingBoard`` only when the point
/// of the test is that output arrives after activation returns.
final class SyncEmittingBoard<Value>: Board, GuaranteedBoard, GuaranteedOutputSendingBoard {
    typealias InputType = Value
    typealias OutputType = Value

    private(set) var activatedValues: [Value] = []

    func activate(withGuaranteedInput input: Value) {
        activatedValues.append(input)
        sendOutput(input)
    }
}

/// Emits its input on the next main-queue turn.
///
/// Deliberately `async` rather than `asyncAfter`: still asynchronous, so it exercises output that
/// arrives after `activate` returns, but signalled by a run-loop turn instead of a clock.
final class AsyncEmittingBoard<Value>: Board, GuaranteedBoard, GuaranteedOutputSendingBoard {
    typealias InputType = Value
    typealias OutputType = Value

    func activate(withGuaranteedInput input: Value) {
        DispatchQueue.main.async { [weak self] in
            self?.sendOutput(input)
        }
    }
}

/// A board that completes only when the test says so.
///
/// This is the shape a gate has: the barrier waits for *this* board's `CompleteAction`, so a test
/// drives the gate by calling ``open(_:)``.
final class GatingBoard: Board, ActivatableBoard {
    private(set) var activationCount = 0

    func activate(withOption _: Any?) {
        activationCount += 1
    }

    /// Completes the gate. `true` lets the queued activation through; `false` cancels it.
    func open(_ isDone: Bool = true) {
        complete(isDone)
    }
}

/// Declares an activation barrier on another board's identifier.
///
/// The `barrier…` parameters mirror ``ActivationBarrier`` so a test can vary scope and option
/// without defining another double.
final class BarrieredBoard: Board, GuaranteedBoard {
    typealias InputType = String

    private(set) var activatedValues: [String] = []

    private let gateIdentifier: BoardID
    private let scope: ActivationBarrierScope
    private let option: ActivationBarrierOption

    init(
        identifier: BoardID,
        gate gateIdentifier: BoardID,
        scope: ActivationBarrierScope = .mainboard,
        option: ActivationBarrierOption = .void
    ) {
        self.gateIdentifier = gateIdentifier
        self.scope = scope
        self.option = option
        super.init(identifier: identifier)
    }

    func activationBarrier(withGuaranteedInput _: String) -> ActivationBarrier? {
        ActivationBarrier(identifier: gateIdentifier, scope: scope, option: option)
    }

    func activate(withGuaranteedInput input: String) {
        activatedValues.append(input)
    }
}
