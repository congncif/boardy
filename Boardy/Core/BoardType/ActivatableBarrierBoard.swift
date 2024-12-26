//
//  ActivatableBarrierBoard.swift
//  Boardy
//
//  Created by CONGNC7 on 04/05/2022.
//

import Foundation

final class ActivatableBarrierBoard: Board, ActivatableBoard {
    let completableIdentifier: BoardID

    init(identifier: BoardID, completableIdentifier: BoardID) {
        self.completableIdentifier = completableIdentifier
        super.init(identifier: identifier)
    }

//    @Atomic
//    var pendingTasks: [BarrierPendingTask] = []
    var pendingTasks = SafeArray<BarrierPendingTask>()

    var isProcessing: Bool { !pendingTasks.isEmpty }

    func registerCompletableFlow(to manager: FlowManageable) {
        manager.registerCompletionFlow(matchedIdentifiers: completableIdentifier) { [weak self] in
            self?.completePendingTasks(isDone: $0)
        }
    }

    func activate(withOption option: Any?) {
        guard let task = option as? BarrierPendingTask else { return }

        if isProcessing {
            pendingTasks.append(task)
        } else {
            pendingTasks.append(task)
            nextToBoard(BoardInput<Any?>(target: completableIdentifier, input: task.barrierOptionValue))
        }
    }

    func completePendingTasks(isDone: Bool) {
        if isDone {
            for task in pendingTasks.elements {
                task.activation()
            }
        }
        pendingTasks.removeAll()
        complete()
    }
}

enum ActivationBarrierFactory {
    static var cache = SafeDictionary<BoardID, ActivatableBarrierBoard>()

    static func makeBarrierBoard(_ barrierActivation: ActivationBarrier) -> ActivatableBarrierBoard {
        let identifier = barrierActivation.barrierIdentifier

        switch barrierActivation.scope {
        case .mainboard:
            return ActivatableBarrierBoard(identifier: identifier, completableIdentifier: barrierActivation.identifier)
        case .application:
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

// extension Array {
//    var elements: [Element] { self }
// }

struct BarrierPendingTask {
    let activation: () -> Void
    let barrierOptionValue: Any?
}
