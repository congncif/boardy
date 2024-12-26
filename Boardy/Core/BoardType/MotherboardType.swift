//
//  MotherboardType.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation

public protocol MotherboardType: IdentifiableBoard, OriginalBoard {
    var boards: [ActivatableBoard] { get }

    func activateBoard(identifier: BoardID, withOption option: Any?)

    /// Append list of boards, this doesn't include installing board into rootObject.
    func addBoard(_ board: ActivatableBoard)
    func removeBoard(withIdentifier identifier: BoardID)

    func getBoard(identifier: BoardID) -> ActivatableBoard?
    func getGatewayBoard(identifier: BoardID) -> ActivatableBoard?

    /// Remove all active boards at once
    func clearActiveBoards()
}

public extension MotherboardType {
    func removeBoard(_ board: ActivatableBoard) {
        removeBoard(withIdentifier: board.identifier)
    }

    /// Install additional a board after its Motherboard was installed.
    func installBoard(_ board: ActivatableBoard) {
        addBoard(board)
        if let root = context {
            board.putIntoContext(root)
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

protocol LazyMotherboard: MotherboardType {
    var boardProducer: ActivatableBoardProducer { get }
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

    public func getGatewayBoard(identifier: BoardID) -> ActivatableBoard? {
        let id = identifier.gateway

        let barrierActivation = ActivationBarrier(identifier: id, scope: .mainboard, option: .void)

        var barrierBoard: ActivatableBoard?

        if let installedBoard = boards.first(where: { $0.identifier == barrierActivation.barrierIdentifier }) {
            barrierBoard = installedBoard
        } else {
            let newBarrierBoard = ActivationBarrierFactory.makeBarrierBoard(barrierActivation)
            installBoard(newBarrierBoard)
            barrierBoard = newBarrierBoard

            if let manager = self as? FlowManageable {
                newBarrierBoard.registerCompletableFlow(to: manager)
            } else {
                assertionFailure("‼️ The Motherboard \(self) without FlowManageable conformation is unsupported for barrier activation")
            }
        }

        if let installedBoard = boards.first(where: { $0.identifier == id }) {
            DebugLog.logActivity(source: installedBoard, data: "[Gateway] with identifier \(identifier) was installed by \(id)")
        } else if let newBoard = boardProducer.produceGatewayBoard(identifier: identifier) {
            installBoard(newBoard)
            DebugLog.logActivity(source: newBoard, data: "[Gateway] with identifier \(identifier) is installing by \(id)")
        } else {
            return nil
        }

        return barrierBoard
    }
}

// MARK: - Internal

protocol MotherboardRepresentable: MotherboardType {
    var mainboard: [ActivatableBoard] { get set }
}

extension MotherboardRepresentable {
    public var boards: [ActivatableBoard] { mainboard }

    public func addBoard(_ board: ActivatableBoard) {
        assert(installedBoard(identifier: board.identifier) == nil, "\(String(describing: self)) \n🔥 Board with identifier \(board.identifier) was already added to motherboard \(self).")
        mainboard.append(board)
    }

    public func removeBoard(withIdentifier identifier: BoardID) {
        assert(installedBoard(identifier: identifier) != nil, "\(String(describing: self)) \n🔥 Board with identifier \(identifier) was not in motherboard \(self).")
        mainboard.removeAll { $0.identifier == identifier }
    }

    public func clearActiveBoards() {
        mainboard.removeAll()
    }
}
