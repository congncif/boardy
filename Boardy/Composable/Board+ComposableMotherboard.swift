//
//  Board+ComposableMotherboard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/26/20.
//

import Foundation

extension Board {
    /// Create a new ComposableMotherboard which uses internally by a board. Chain of actions will be set up.
    public func getComposableMotherboard(identifier: BoardID = UUID().uuidString, elementBoards: [ActivatableBoard] = []) -> ComposableMotherboard {
        let motherboard = ComposableMotherboard(identifier: identifier, boards: elementBoards)
        // Setup chain of actions.
        motherboard.forwardActionFlow(to: self)

        // ComposableMotherboard should forward activation flow to previous Motherboard.
        motherboard.forwardActivationFlow(to: self)
        return motherboard
    }

    /// Create a new ComposableMotherboard which uses internally by a board. Chain of actions will be set up.
    public func getComposableMotherboard(identifier: BoardID = UUID().uuidString, boardProducer: ActivableBoardProducer) -> ComposableMotherboard {
        let motherboard = ComposableMotherboard(identifier: identifier, boardProducer: boardProducer)
        // Setup chain of actions.
        motherboard.forwardActionFlow(to: self)

        // ComposableMotherboard should forward activation flow to previous Motherboard.
        motherboard.forwardActivationFlow(to: self)
        return motherboard
    }
}
