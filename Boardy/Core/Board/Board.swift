//
//  Board.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation
import UIKit

open class Board: IdentifiableBoard, OriginalBoard {
    public let identifier: BoardID
    public weak var delegate: BoardDelegate?

    public init(identifier: BoardID = .randomUnique()) {
        self.identifier = identifier
    }

    /**
     Give root object which associated with Board.
     */

    public var root: AnyObject? { rootObject }

    /**
        Install Board into a root object. The root object will be set as an associated object with this Board. After that the Board can use some public functions which root object provided.

         - Parameter rootObject: object Board will be linked to, should be `UIViewController`, `UIWindow` or a custom object.
     */

    open func installIntoRoot(_ rootObject: AnyObject) {
        self.rootObject = rootObject
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
    public func availableWatchedContents<Object>(_ contentType: Object.Type = Object.self) -> [Object] {
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
