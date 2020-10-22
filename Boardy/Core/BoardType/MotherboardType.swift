//
//  MotherboardType.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation

public protocol BoardInputModel {
    var identifier: BoardID { get }
    var option: Any? { get }
}

public struct BoardDestination: BoardInputModel {
    public let identifier: BoardID
    public let option: Any?

    public init(target: BoardID, option: Any? = nil) {
        self.identifier = target
        self.option = option
    }
}

public protocol MotherboardType: ActivatableBoard {
    var boards: [ActivatableBoard] { get }

    /// Append list of boards, this doesn't include installing board into rootObject.
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

    public func activateBoard(model: BoardInputModel) {
        activateBoard(identifier: model.identifier, withOption: model.option)
    }

    public func removeBoard(_ board: ActivatableBoard) {
        removeBoard(withIdentifier: board.identifier)
    }

    /// Install additional a board after its Motherboard was installed.
    public func installBoard(_ board: ActivatableBoard) {
        addBoard(board)
        if let root = self.root {
            board.installIntoRoot(root)
        }
    }

    public func extended(boards: [ActivatableBoard]) -> Self {
        boards.forEach { self.installBoard($0) }
        return self
    }
}

// MARK: - Internal

protocol MotherboardRepresentable: AnyObject, MotherboardType {
    var mainboard: [ActivatableBoard] { get set }
}

extension MotherboardRepresentable {
    public var boards: [ActivatableBoard] {
        mainboard
    }

    public func getBoard(identifier: BoardID) -> ActivatableBoard? {
        return mainboard.first { $0.identifier == identifier }
    }

    public func addBoard(_ board: ActivatableBoard) {
        assert(getBoard(identifier: board.identifier) == nil, " 💔 Board with identifier \(board.identifier) was already added to motherboard \(self).")
        mainboard.append(board)
    }

    public func removeBoard(withIdentifier identifier: BoardID) {
        assert(getBoard(identifier: identifier) != nil, " 💔 Board with identifier \(identifier) was not in motherboard \(self).")
        mainboard.removeAll { $0.identifier == identifier }
    }
}
