//
//  MotherboardType+Activate.swift
//  Boardy
//
//  Created by FOLY on 10/24/20.
//

import Foundation

public extension MotherboardType {
    func activateBoard(identifier: BoardID, withOption option: Any? = nil) {
        guard let board = getBoard(identifier: identifier) else {
            assertionFailure("\(String(describing: self)) \n🔥 Activated Board with identifier \(identifier) which was not found in motherboard")
            return
        }

        if let barrier = board.activationBarrier(withOption: option) {
            let barrierBoard = getBarrierBoard(barrier)
            let pending = BoardActivationOption(identifier: identifier, option: option)
            barrierBoard.activate(withOption: pending)
        } else {
            DebugLog.logActivation(source: self, destination: board, data: option)
            board.activate(withOption: option)
        }
    }

    func activateBoard(model: BoardInputModel) {
        activateBoard(identifier: model.identifier, withOption: model.option)
    }

    func activateBoard<Input>(_ input: BoardInput<Input>) {
        activateBoard(model: input)
    }

    /// Alias for the removeBoard(withIdentifier:) method. The board with identifier will be removed from active list.
    func deactivateBoard(identifier: BoardID) {
        removeBoard(withIdentifier: identifier)
    }
}

extension MotherboardType {
    func getBarrierBoard(_ barrierActivation: ActivationBarrier) -> ActivatableBoard {
        let identifier = barrierActivation.identifier.appending("___PRIVATE_BARRIER___")

        if let installedBoard = boards.first(where: { $0.identifier == identifier }) {
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
