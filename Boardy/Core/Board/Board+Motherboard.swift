//
//  Board+Motherboard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/26/20.
//

import Foundation

public extension ActivatableBoardProducer {
    /// Create a new Motherboard which uses internally by a board. Chain of actions will be set up to parent.
    func produceContinuousMotherboard(identifier: BoardID,
                                      from parent: IdentifiableBoard? = nil,
                                      elementsBuilder: (ActivatableBoardProducer) -> [ActivatableBoard] = { _ in [] }) -> FlowMotherboard {
        let motherboard = Motherboard(identifier: identifier, boardProducer: self, boards: elementsBuilder(self))

        if let parent = parent {
            // Setup chain of actions.
            motherboard.forwardActionFlow(to: parent)
        }

        return motherboard
    }
}
