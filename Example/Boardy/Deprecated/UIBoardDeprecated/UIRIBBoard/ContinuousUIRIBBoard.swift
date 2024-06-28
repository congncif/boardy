//
//  ContinuousUIRIBBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/8/20.
//

import Foundation

open class ContinuousUIRIBBoard: UIRIBBoard {
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
