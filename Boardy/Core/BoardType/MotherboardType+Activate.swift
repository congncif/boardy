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

        func activate() {
            if let barrier = board.activationBarrier(withOption: option) {
                let barrierBoard = getBarrierBoard(barrier)

                DebugLog.logActivation(source: self, destination: barrierBoard, data: option)

                let pendingActivation: () -> Void = { [weak board, weak self] in
                    guard let self, let board else { return }
                    DebugLog.logActivation(source: self, destination: board, data: option)
                    board.activate(withOption: option)
                }

                let pendingTask = BarrierPendingTask(activation: pendingActivation, barrierOptionValue: barrier.option.value)

                barrierBoard.activate(withOption: pendingTask)
            } else {
                DebugLog.logActivation(source: self, destination: board, data: option)
                board.activate(withOption: option)
            }
        }

        let gatewayBoard = getGatewayBoard(identifier: identifier)
        if board.identifier.isGateway || board.shouldBypassGatewayBarrier() || gatewayBoard == nil {
            activate()
        } else {
            let gatewayBarrierBoard = gatewayBoard!

            let pendingActivation: () -> Void = {
                activate()
            }

            let boardInputModel = GatewayInputModel(identifier: identifier, option: option)
            let pendingTask = BarrierPendingTask(activation: pendingActivation, barrierOptionValue: boardInputModel)
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
    func getBarrierBoard(_ barrierActivation: ActivationBarrier) -> ActivatableBoard {
        if let installedBoard = boards.first(where: { $0.identifier == barrierActivation.barrierIdentifier }) {
            return installedBoard
        }

        let newBoard = ActivationBarrierFactory.makeBarrierBoard(barrierActivation)
        installBoard(newBoard)

        if let manager = self as? FlowManageable {
            newBoard.registerCompletableFlow(to: manager)
        } else {
            assertionFailure("‼️ The Motherboard \(self) without FlowManageable conformation is unsupported for barrier activation")
        }

        return newBoard
    }
}

struct GatewayInputModel: BoardInputModel {
    var identifier: BoardID
    var option: Any?
}
