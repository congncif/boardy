//
//  MotherboardType.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation

public protocol MotherboardType: InstallableBoard {
    var boards: [ActivatableBoard] { get }

    func addBoard(_ board: ActivatableBoard)
    func removeBoard(withIdentifier identifier: BoardID)

    func getBoard(identifier: BoardID) -> ActivatableBoard?
}

extension MotherboardType {
    public func activateBoard(identifier: BoardID, withOption option: Any? = nil) {
        guard let board = getBoard(identifier: identifier) else {
            assertionFailure("Board with identifier \(identifier) was not found in mother board \(self)")
            return
        }
        board.activate(withOption: option)
    }

    public func removeBoard(_ board: ActivatableBoard) {
        removeBoard(withIdentifier: board.identifier)
    }
}

// MARK: - Internal

protocol MotherboardRepresentable: AnyObject, MotherboardType {
    var mainboard: [BoardID: ActivatableBoard] { get set }
}

extension MotherboardRepresentable {
    public var boards: [ActivatableBoard] {
        mainboard.map { $0.value }
    }

    public func getBoard(identifier: BoardID) -> ActivatableBoard? {
        return mainboard[identifier]
    }

    public func addBoard(_ board: ActivatableBoard) {
        assert(mainboard[board.identifier] == nil, " 💔 Board with identifier \(board.identifier) was already added to motherboard \(self).")
        mainboard[board.identifier] = board
    }

    public func removeBoard(withIdentifier identifier: BoardID) {
        assert(mainboard[identifier] != nil, " 💔 Board with identifier \(identifier) was not in motherboard \(self).")
        mainboard[identifier] = nil
    }
}
