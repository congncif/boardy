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

    public init(identifier: BoardID = .randomUnique(),
                motherboard: FlowMotherboard = Motherboard()) {
        self.motherboard = motherboard
        super.init(identifier: identifier)

        motherboard.forwardActionFlow(to: self)
    }

    public convenience init(identifier: BoardID = .randomUnique(),
                            boardProducer: ActivableBoardProducer) {
        let motherboard = Motherboard(boardProducer: boardProducer)
        self.init(identifier: identifier, motherboard: motherboard)
    }

    override open func installIntoRoot(_ rootObject: AnyObject) {
        super.installIntoRoot(rootObject)
        motherboard.installIntoRoot(rootObject)
    }
}

extension ContinuousBoard {
    public func continueBoard<Input>(_ input: BoardInput<Input>) {
        motherboard.activateBoard(input)
    }

    public func continueBoard(model: BoardInputModel) {
        motherboard.activateBoard(model: model)
    }

    public func continueInteractWithBoard<Input>(_ input: BoardCommand<Input>) {
        motherboard.interactWithBoard(input)
    }

    public func continueInteractWithBoard(command: BoardCommandModel) {
        motherboard.interactWithBoard(command: command)
    }
}
