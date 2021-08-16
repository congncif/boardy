//
//  Board+ComposableMotherboard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/26/20.
//

import Foundation

extension Board {
    @available(*, deprecated, renamed: "produceComposableMotherboard")
    public func getComposableMotherboard(identifier: BoardID = .random(), boardProducer: ActivableBoardProducer = NoBoardProducer(), elementBoards: [ActivatableBoard] = []) -> ComposableMotherboard {
        produceComposableMotherboard(identifier: identifier, boardProducer: boardProducer, elementBoards: elementBoards)
    }

    /// Create a new ComposableMotherboard which uses internally by a board. Chain of actions will be set up.
    public func produceComposableMotherboard(identifier: BoardID = .random(),
                                             boardProducer: ActivableBoardProducer = NoBoardProducer(),
                                             elementBoards: [ActivatableBoard] = []) -> ComposableMotherboard {
        let motherboard = ComposableMotherboard(identifier: identifier, boardProducer: boardProducer, boards: elementBoards)
        // Setup chain of actions.
        motherboard.forwardActionFlow(to: self)

        // ComposableMotherboard should forward activation flow to previous Motherboard.
        motherboard.forwardActivationFlow(to: self)

        return motherboard
    }
}

///
public extension ActivableBoardProducer {
    /// Create a new ComposableMotherboard which uses internally by a board. Chain of actions will be set up to parent.
    func produceComposableMotherboard(identifier: BoardID = .random(),
                                      from parent: IdentifiableBoard? = nil,
                                      elementsBuilder: (ActivableBoardProducer) -> [ActivatableBoard] = { _ in [] }) -> FlowComposableMotherboard {
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
