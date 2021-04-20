//
//  MotherboardType.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation

public protocol MotherboardType: ActivatableBoard {
    var boards: [ActivatableBoard] { get }

    /// Append list of boards, this doesn't include installing board into rootObject.
    func addBoard(_ board: ActivatableBoard)
    func removeBoard(withIdentifier identifier: BoardID)

    func getBoard(identifier: BoardID) -> ActivatableBoard?
}

public extension MotherboardType {
    func removeBoard(_ board: ActivatableBoard) {
        removeBoard(withIdentifier: board.identifier)
    }

    /// Install additional a board after its Motherboard was installed.
    func installBoard(_ board: ActivatableBoard) {
        addBoard(board)
        if let root = self.root {
            board.installIntoRoot(root)
        }
    }

    func extended(boards: [ActivatableBoard]) -> Self {
        boards.forEach { self.installBoard($0) }
        return self
    }

    func installedBoard(identifier: BoardID) -> ActivatableBoard? {
        boards.first(where: { $0.identifier == identifier })
    }
}

public protocol ActivableBoardProducer {
    func produceBoard(identifier: BoardID) -> ActivatableBoard?
}

protocol LazyMotherboard: MotherboardType {
    var boardProducer: ActivableBoardProducer { get }
}

extension LazyMotherboard {
    public func getBoard(identifier: BoardID) -> ActivatableBoard? {
        if let installedBoard = boards.first(where: { $0.identifier == identifier }) {
            return installedBoard
        }
        guard let newBoard = boardProducer.produceBoard(identifier: identifier) else {
            return nil
        }
        installBoard(newBoard)
        return newBoard
    }
}

// MARK: - Internal

protocol MotherboardRepresentable: MotherboardType {
    var mainboard: [ActivatableBoard] { get set }
}

extension MotherboardRepresentable {
    public var boards: [ActivatableBoard] { mainboard }

    public func addBoard(_ board: ActivatableBoard) {
        assert(installedBoard(identifier: board.identifier) == nil, "⛈ [\(String(describing: self))] Board with identifier \(board.identifier) was already added to motherboard \(self).")
        mainboard.append(board)
    }

    public func removeBoard(withIdentifier identifier: BoardID) {
        assert(installedBoard(identifier: identifier) != nil, "⛈ [\(String(describing: self))] Board with identifier \(identifier) was not in motherboard \(self).")
        mainboard.removeAll { $0.identifier == identifier }
    }
}
