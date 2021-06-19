//
//  MotherboardType+Interact.swift
//  Boardy
//
//  Created by FOLY on 10/24/20.
//

import Foundation

extension MotherboardType {
    /// Interact with a child board which this motherboard directly manages.
    public func interactWithBoard(command: BoardCommandModel) {
        let identifier = command.identifier
        let board = getBoard(identifier: identifier)
        guard let interactBoard = board as? InteractableBoard else {
            assertionFailure("\(String(describing: self)) \n🔥 Interacted Board with identifier \(identifier) but it didn't conform \(InteractableBoard.self)")
            return
        }
        DebugLog.logActivation(icon: "🚚 [Interaction]", source: self, destination: interactBoard, data: command.data)
        interactBoard.interact(command: command)
    }

    public func interactWithBoard<Input>(_ input: BoardCommand<Input>) {
        interactWithBoard(command: input)
    }
}
