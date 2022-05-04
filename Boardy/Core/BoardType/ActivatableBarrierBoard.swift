//
//  ActivatableBarrierBoard.swift
//  Boardy
//
//  Created by CONGNC7 on 04/05/2022.
//

import Foundation

struct BoardActivationOption: BoardInputModel {
    let identifier: BoardID
    let option: Any?
}

final class ActivatableBarrierBoard: Board, ActivatableBoard {
    let completableIdentifier: BoardID

    init(identifier: BoardID, completableIdentifier: BoardID) {
        self.completableIdentifier = completableIdentifier
        super.init(identifier: identifier)
    }

    @Atomic
    var pendingActivations: [() -> Void] = []

    var isProcessing: Bool { !pendingActivations.isEmpty }

    func registerCompletableFlow(to manager: FlowManageable) {
        manager.registerCompletionFlow(matchedIdentifiers: completableIdentifier) { [weak self] in
            self?.completePendingTasks(isDone: $0)
        }
    }

    func activate(withOption option: Any?) {
        guard let option = option as? () -> Void else { return }

        if isProcessing {
            pendingActivations.append(option)
        } else {
            pendingActivations.append(option)
            nextToBoard(BoardInput<Void>(target: completableIdentifier, input: ()))
        }
    }

    func completePendingTasks(isDone: Bool) {
        if isDone {
            for activation in pendingActivations {
                activation()
            }
        }
        pendingActivations.removeAll()
        complete()
    }
}

enum ActivationBarrierFactory {
    @Atomic
    static var cache: [BoardID: ActivatableBarrierBoard] = [:]

    static func makeBarrierBoard(_ barrierActivation: ActivationBarrier) -> ActivatableBarrierBoard {
        let identifier = barrierActivation.identifier.appending("___PRIVATE_BARRIER___")

        switch barrierActivation.scope {
        case .inMain:
            return ActivatableBarrierBoard(identifier: identifier, completableIdentifier: barrierActivation.identifier)
        case .global:
            if let cachedInstance = cache[identifier] {
                return cachedInstance
            } else {
                let newInstance = ActivatableBarrierBoard(identifier: identifier, completableIdentifier: barrierActivation.identifier)
                cache[identifier] = newInstance
                return newInstance
            }
        }
    }
}
