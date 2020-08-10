//
//  MotherboardType.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation

public protocol MotherboardType: InstallableBoard {
    var boards: [ActivatableBoard] { get }
}

extension MotherboardType {
    public func getBoard(identifier: BoardID) -> ActivatableBoard? {
        return boards.first { $0.identifier == identifier }
    }

    public func activateBoard(identifier: BoardID, withOption option: Any? = nil) {
        guard let board = getBoard(identifier: identifier) else {
            assertionFailure("Board with identifier \(identifier) was not found in mother board \(self)")
            return
        }
        board.activate(withOption: option)
    }
}
