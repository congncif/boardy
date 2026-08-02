//
//  MotherboardType+Interact.swift
//  Boardy
//
//  Created by FOLY on 10/24/20.
//

import Foundation

public extension MotherboardType {
    /// Interact with a child board which this motherboard directly manages.
    ///
    /// Interaction targets a board that is already active, so this is a pure lookup: an unknown
    /// identifier is reported rather than silently producing and installing a placeholder board.
    func interactWithBoard(command: BoardCommandModel) {
        let identifier = command.identifier
        guard let board = getBoard(identifier: identifier) else {
            assertionFailure("⚠️ [\(identifier)] received an interaction command but no board with that identifier is installed in \(String(describing: self))!")
            return
        }
        guard let interactBoard = board as? InteractableBoard else {
            assertionFailure("⚠️ [\(identifier)] received an interaction command but it needs to conform \(InteractableBoard.self) to continue process!")
            return
        }
        DebugLog.logActivation(icon: "🚚 [Interaction]", source: self, destination: interactBoard, data: command.data)
        interactBoard.interact(command: command.data)
    }

    func interactWithBoard<Input>(_ input: BoardCommand<Input>) {
        interactWithBoard(command: input)
    }
}
