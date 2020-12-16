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
            assertionFailure("Board with identifier \(identifier) must conforms \(InteractableBoard.self) but \(board)")
            return
        }
        interactBoard.interact(command: command)
    }
}
