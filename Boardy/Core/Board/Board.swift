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

    private weak var rootObject: AnyObject?

    public init(identifier: BoardID = UUID().uuidString) {
        self.identifier = identifier
    }

    public var root: AnyObject? { rootObject }

    open func installIntoRoot(_ rootObject: AnyObject) {
        self.rootObject = rootObject
    }
}

extension Board: InstallableBoard {}

extension Board: WindowInstallableBoard {}
