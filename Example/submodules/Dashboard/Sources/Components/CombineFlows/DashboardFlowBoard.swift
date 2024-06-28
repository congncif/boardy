//
//  RootBoard.swift
//  Dashboard
//
//  Created by BOARDY on 10/22/21.
//
//

import Boardy
import Dashboard
import Foundation

enum DashboardBoardFactory {
    static func make(identifier: BoardID, producer: ActivatableBoardProducer) -> ActivatableBoard {
        FlowBoard<DashboardInput, DashboardOutput, DashboardCommand, DashboardAction>(identifier: identifier, producer: producer) { _ in
            // <#register flows#>
        } flowActivation: { it, _ in
            it.motherboard.ioDashboard().activation.activate()
        }
    }
}
