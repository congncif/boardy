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
            assertionFailure("⛈ [\(String(describing: self)) with identifier: \(identifier)] Board with identifier \(identifier) was not found in mother board \(self)")
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
}
