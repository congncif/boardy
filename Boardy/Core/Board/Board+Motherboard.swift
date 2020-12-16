//
//  Board+Motherboard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/26/20.
//

import Foundation

extension Board {
    /// Create a new Motherboard which uses internally by a board. Chain of actions will be set up.
    public func getMotherboard(identifier: BoardID = UUID().uuidString, elementBoards: [ActivatableBoard] = []) -> Motherboard {
        let motherboard = Motherboard(identifier: identifier, boards: elementBoards)
        // Setup chain of actions.
        motherboard.forwardActionFlow(to: self)
        return motherboard
    }

    /// Create a new Motherboard which uses internally by a board. Chain of actions will be set up.
    public func getMotherboard(identifier: BoardID = UUID().uuidString, boardProducer: ActivableBoardProducer) -> Motherboard {
        let motherboard = Motherboard(identifier: identifier, boardProducer: boardProducer)
        // Setup chain of actions.
        motherboard.forwardActionFlow(to: self)
        return motherboard
    }
}
