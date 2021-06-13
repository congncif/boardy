//
//  Board+Motherboard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/26/20.
//

import Foundation

extension Board {
    /// Create a new Motherboard which uses internally by a board. Chain of actions will be set up.
    @available(*, deprecated, renamed: "produceContinuousMotherboard")
    public func getMotherboard(identifier: BoardID = .random(), boardProducer: ActivableBoardProducer = NoBoardProducer(), elementBoards: [ActivatableBoard] = []) -> Motherboard {
        produceContinuousMotherboard(identifier: identifier, boardProducer: boardProducer, elementBoards: elementBoards)
    }

    /// Create a new Motherboard which uses internally by a board. Chain of actions will be set up.
    public func produceContinuousMotherboard(identifier: BoardID = .random(),
                                             boardProducer: ActivableBoardProducer = NoBoardProducer(),
                                             elementBoards: [ActivatableBoard] = []) -> Motherboard {
        let motherboard = Motherboard(identifier: identifier, boardProducer: boardProducer, boards: elementBoards)
        // Setup chain of actions.
        motherboard.forwardActionFlow(to: self)
        return motherboard
    }
}

///
public extension ActivableBoardProducer {
    /// Create a new Motherboard which uses internally by a board. Chain of actions will be set up to parent.
    func produceContinuousMotherboard(identifier: BoardID = .random(), from parent: IdentifiableBoard? = nil) -> FlowMotherboard {
        let motherboard = Motherboard(identifier: identifier, boardProducer: self, boards: [])

        if let parent = parent {
            // Setup chain of actions.
            motherboard.forwardActionFlow(to: parent)
        }

        return motherboard
    }
}
