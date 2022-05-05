//
//  Board+ComposableMotherboard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/26/20.
//

import Foundation

public extension ActivatableBoardProducer {
    /// Create a new ComposableMotherboard which uses internally by a board. Chain of actions will be set up to parent.
    func produceComposableMotherboard(identifier: BoardID,
                                      from parent: IdentifiableBoard? = nil,
                                      elementsBuilder: (ActivatableBoardProducer) -> [ActivatableBoard] = { _ in [] }) -> FlowComposableMotherboard {
        let motherboard = ComposableMotherboard(identifier: identifier, boardProducer: self, boards: elementsBuilder(self))

        if let parent = parent {
            // Setup chain of actions.
            motherboard.forwardActionFlow(to: parent)

            // ComposableMotherboard should forward activation flow to previous Motherboard.
            motherboard.forwardActivationFlow(to: parent)
        }

        return motherboard
    }
}
