//
//  Motherboard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 11/1/19.
//  Copyright © 2019 NGUYEN CHI CONG. All rights reserved.
//

import Foundation
import UIKit

open class Motherboard: Board, MotherboardRepresentable, BoardDelegate, FlowMotherboard {
    var mainboard: [BoardID: ActivatableBoard] = [:] {
        didSet {
            for var board in boards {
                board.delegate = self
            }
        }
    }

    public var flows: [BoardFlow] = []

    public init(identifier: BoardID = UUID().uuidString,
                boards: [ActivatableBoard] = []) {
        super.init(identifier: identifier)

        for board in boards {
            addBoard(board)
        }

        forwardActivationFlow(to: self)
        forwardActionFlow(to: self)
    }

    public convenience init(identifier: BoardID = UUID().uuidString,
                            boards: [ActivatableBoard] = [],
                            rootObject: AnyObject) {
        self.init(identifier: identifier, boards: boards)
        installIntoRoot(rootObject)
    }

    override open func installIntoRoot(_ rootObject: AnyObject) {
        super.installIntoRoot(rootObject)
        for board in boards {
            board.installIntoRoot(rootObject)
        }
    }
}

/// A Motherboard is a special board which only accepts a BoardInputModel as input. When activate func is called, the motherboard will activate a Board with identifier in list of boards it manages.

extension Motherboard: GuaranteedBoard {
    public typealias InputType = BoardInputModel

    public func activate(withGuaranteedInput input: BoardInputModel) {
        activateBoard(model: input)
    }
}
