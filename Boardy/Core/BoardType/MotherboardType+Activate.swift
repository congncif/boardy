//
//  MotherboardType+Activate.swift
//  Boardy
//
//  Created by FOLY on 10/24/20.
//

import Foundation

extension MotherboardType {
    public func activateBoard(identifier: BoardID, withOption option: Any? = nil) {
        guard let board = getBoard(identifier: identifier) else {
            assertionFailure("\(String(describing: self)) \n🔥 Activated Board with identifier \(identifier) which was not found in motherboard")
            return
        }
        DebugLog.logActivation(source: self, destination: board, data: option)
        board.activate(withOption: option)
    }

    public func activateBoard(model: BoardInputModel) {
        activateBoard(identifier: model.identifier, withOption: model.option)
    }

    public func activateBoard<Input>(_ input: BoardInput<Input>) {
        activateBoard(model: input)
    }

    /// Alias for the removeBoard(withIdentifier:) method. The board with identifier will be removed from active list.
    public func deactivateBoard(identifier: BoardID) {
        removeBoard(withIdentifier: identifier)
    }
}
