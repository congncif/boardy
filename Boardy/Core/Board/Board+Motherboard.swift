//
//  Board+Motherboard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/26/20.
//

import Foundation

extension Board {
    /// Create a new Motherboard which use internal a board. Chain of actions will be set up.
    public func getMotherboard(identifier: BoardID = UUID().uuidString, elementBoards: [ActivatableBoard] = []) -> Motherboard {
        let motherboard = Motherboard(identifier: identifier, boards: elementBoards)
        // Setup chain of actions.
        motherboard.forwardActionFlow(to: self)
        return motherboard
    }
}
