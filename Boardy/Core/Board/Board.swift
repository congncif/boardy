//
//  Board.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation
import UIKit

/// The base class for a unit of flow logic.
///
/// A board is glue, not a place to keep state. It receives an input, does one thing — show a
/// screen, run a task, decide a route — and reports back through ``sendToMotherboard(data:)``.
/// Business logic belongs in whatever controller the board builds; the board wires that controller
/// to the rest of the app.
///
/// Subclass this and adopt one of the activation protocols rather than conforming from scratch:
///
/// ```swift
/// final class CheckoutBoard: Board, GuaranteedBoard, GuaranteedOutputSendingBoard {
///     typealias InputType = Cart
///     typealias OutputType = Receipt
///
///     func activate(withGuaranteedInput cart: Cart) {
///         let screen = CheckoutViewController(cart: cart)
///         screen.onPaid = { [weak self] receipt in self?.sendOutput(receipt) }
///         rootViewController.show(screen)
///     }
/// }
/// ```
///
/// ## Lifetime
///
/// A board is created by a producer when first activated and removed from its motherboard when it
/// completes. Prefer letting that happen: a board that stores state across activations has to
/// manage its own lifecycle and stops being safely reusable. If a board must outlive one
/// activation, it is responsible for calling `complete()` itself.
///
/// ## Threading
///
/// Activation and output are caller-controlled — the framework adds no queue hops. UIKit work must
/// therefore happen on the main thread, as usual. Installing and removing boards, and registering
/// flows, must happen on the main thread; DEBUG builds assert this.
open class Board: IdentifiableBoard, OriginalBoard {
    public let identifier: BoardID
    public weak var delegate: BoardDelegate?

    /// Creates a board addressable as `identifier`.
    ///
    /// The identifier must be unique within the motherboard the board is installed into.
    public init(identifier: BoardID) {
        self.identifier = identifier
    }

    public var debugDescription: String {
        """
        ⛵️ [Debug Description]
            ● [Board] ➤ \(String(describing: type(of: self)))
            ● [ID] ➤ \(String(describing: identifier))
            ● [Motherboard] ➤ \(String(describing: (delegate as? IdentifiableBoard)?.identifier))
        """
    }

    /**
     Give root object which associated with Board.
     */

    public var context: AnyObject? { rootObject }

    /**
        Install Board into a root object. The root object will be set as an associated object with this Board. After that the Board can use some public functions which root object provided.

         - Parameter rootObject: object Board will be linked to, should be `UIViewController`, `UIWindow` or a custom object.
     */

    open func putIntoContext(_ context: AnyObject) {
        rootObject = context
    }

    // MARK: Content watching

    /**
     Track content via its lifecycle. A reference will be created to content object to ensure that it will be still available or not at some time.

     - Parameter content: object which should be watched.
     */
    public func watch(content: AnyObject) {
        cleanBoxesIfNeeded()
        contentBoxes.append(ContentBox(content: content))
    }

    /**
     Give available status about contents of a Board. Use for checking the Board has active contents or not. Return `true` if has at least one watched content is still available, otherwise `false`. Required using with `watch(content:)`, if `watch(content:)` was not called before, this method always returns `false`.
     */
    public var watchedContentIsAvailable: Bool {
        cleanBoxesIfNeeded()
        return !contentBoxes.isEmpty
    }

    /**
     Wouldn't like to watch old contents, reset at all.
     */
    public func resetWatchedContents() {
        contentBoxes.removeAll()
    }

    /**
     Give list of watched contents which is still available.
     */
    public func availableWatchedContents() -> [AnyObject] {
        cleanBoxesIfNeeded()
        return contentBoxes.compactMap { $0.content }
    }

    /**
     Give list of available watched contents with object type specified.
     */
    public func availableWatchedContents<Object>(_: Object.Type = Object.self) -> [Object] {
        availableWatchedContents().compactMap { $0 as? Object }
    }

    /**
     Shorthand of availableWatchedContents(_:) returns first object.
     */
    public func firstAvailableWatchedContent<Object>(_ contentType: Object.Type = Object.self) -> Object? {
        availableWatchedContents(contentType).first
    }

    /**
     Shorthand of availableWatchedContents(_:) returns last object.
     */
    public func lastAvailableWatchedContent<Object>(_ contentType: Object.Type = Object.self) -> Object? {
        availableWatchedContents(contentType).last
    }

    // MARK: Private properties

    private weak var rootObject: AnyObject?
    private lazy var contentBoxes: [ContentBox] = []

    // MARK: Private methods

    private func cleanBoxesIfNeeded() {
        contentBoxes.removeAll { !$0.isAvailable }
    }
}

extension Board: InstallableBoard {}

extension Board: WindowInstallableBoard {}

/// Box to keep weak reference to a content object which can be released at some time.
struct ContentBox {
    weak var content: AnyObject?

    var isAvailable: Bool { content != nil }
}
