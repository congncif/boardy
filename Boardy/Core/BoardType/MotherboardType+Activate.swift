//
//  MotherboardType+Activate.swift
//  Boardy
//
//  Created by FOLY on 10/24/20.
//

import Foundation

public extension MotherboardType {
    func activateBoard(identifier: BoardID, withOption option: Any?) {
        guard let board = getBoard(identifier: identifier) else {
            assertionFailure("\(String(describing: self)) \n🔥 Activated Board with identifier \(identifier) which was not found in motherboard")
            return
        }

        guard !board.identifier.isGateway else {
            performActivation(of: board, withOption: option)
            return
        }

        let gatewayBoard = getGatewayBoard(identifier: identifier)
        if board.shouldBypassGatewayBarrier() || gatewayBoard == nil {
            performActivation(of: board, withOption: option)
        } else {
            guard
                let gatewayBarrierBoard = gatewayBoard as? ActivatableBarrierBoard,
                let owner = self as? BarrierOwningMotherboard
            else {
                assertionFailure("‼️ A gateway barrier owner must conform to MotherboardType, BoardDelegate and FlowManageable")
                return
            }

            // Must not capture `self` or `board` strongly: a gateway that never completes keeps this
            // task queued forever, which would retain the whole motherboard graph.
            let pendingActivation: () -> Void = { [weak self, weak board] in
                guard let self, let board else { return }
                performActivation(of: board, withOption: option)
            }

            let boardInputModel = GatewayInputModel(identifier: identifier, option: option)
            let pendingTask = BarrierPendingTask(
                activation: pendingActivation,
                barrierOptionValue: boardInputModel,
                ownerToken: gatewayBarrierBoard.ownerToken(for: owner)
            )
            gatewayBarrierBoard.activate(withOption: pendingTask)
        }
    }

    func activateBoard(model: BoardInputModel) {
        activateBoard(identifier: model.identifier, withOption: model.option)
    }

    func activateBoard(_ input: BoardInput<some Any>) {
        activateBoard(model: input)
    }

    /// Alias for the removeBoard(withIdentifier:) method. The board with identifier will be removed from active list.
    func deactivateBoard(identifier: BoardID) {
        removeBoard(withIdentifier: identifier)
    }
}

extension MotherboardType {
    /// Activates `board`, routing through its own activation barrier when it declares one.
    ///
    /// `board` is passed in rather than captured so that deferred callers (gateway barriers) can
    /// hold it weakly. See `activateBoard(identifier:withOption:)`.
    func performActivation(of board: ActivatableBoard, withOption option: Any?) {
        guard let barrier = board.activationBarrier(withOption: option) else {
            DebugLog.logActivation(source: self, destination: board, data: option)
            board.activate(withOption: option)
            return
        }

        let barrierBoard = getBarrierBoard(barrier)

        DebugLog.logActivation(source: self, destination: barrierBoard, data: option)

        guard let owner = self as? BarrierOwningMotherboard else {
            assertionFailure("‼️ A barrier owner must conform to MotherboardType, BoardDelegate and FlowManageable")
            return
        }

        let pendingActivation: () -> Void = { [weak self, weak board] in
            guard let self, let board else { return }
            DebugLog.logActivation(source: self, destination: board, data: option)
            board.activate(withOption: option)
        }

        let pendingTask = BarrierPendingTask(
            activation: pendingActivation,
            barrierOptionValue: barrier.option.value,
            ownerToken: barrierBoard.ownerToken(for: owner)
        )

        barrierBoard.activate(withOption: pendingTask)
    }

    func getBarrierBoard(_ barrierActivation: ActivationBarrier) -> ActivatableBarrierBoard {
        let identifier = barrierActivation.barrierIdentifier
        if let installedBoard = boards.first(where: { $0.identifier == identifier }) {
            guard let barrierBoard = installedBoard as? ActivatableBarrierBoard else {
                preconditionFailure("A non-barrier board is installed with barrier identifier \(identifier)")
            }
            return barrierBoard
        }

        return ActivationBarrierFactory.makeBarrierBoard(
            barrierActivation,
            identifier: identifier
        )
    }
}

struct GatewayInputModel: BoardInputModel {
    var identifier: BoardID
    var option: Any?
}
