//
//  ContinuousBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/27/20.
//

import Foundation
import UIKit

/// A ContinuousBoard contains an internal sub-motherboard by default.
open class ContinuousBoard: Board {
    public let motherboard: FlowMotherboard

    public init(identifier: BoardID = UUID().uuidString,
                motherboard: FlowMotherboard = Motherboard()) {
        self.motherboard = motherboard
        super.init(identifier: identifier)

        motherboard.forwardActionFlow(to: self)
    }

    override open func installIntoRoot(_ rootObject: AnyObject) {
        super.installIntoRoot(rootObject)
        motherboard.installIntoRoot(rootObject)
    }
}
