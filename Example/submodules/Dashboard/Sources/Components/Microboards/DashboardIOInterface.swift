//
//  DashboardIOInterface.swift
//  DashboardPlugins
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import Boardy
import Foundation

// MARK: - ID

extension BoardID {
    static let modDashboard: BoardID = "mod.DashboardPlugins.Dashboard"
}

// MARK: - Interface

struct DashboardDestination {
    let activation: BoardActivation<DashboardParameter>
    let blockActivation: BlockTaskBoardActivation<DashboardInput, DashboardOutput>
    let interaction: BoardInteraction<DashboardCommand>
    let completer: BoardCompleter
}

extension ActivatableBoard {
    func ioDashboard(_ identifier: BoardID = .modDashboard) -> DashboardDestination {
        DashboardDestination(
            activation: activation(identifier, with: DashboardParameter.self),
            blockActivation: blockActivation(identifier, with: BlockTaskParameter<DashboardInput, DashboardOutput>.self),
            interaction: interaction(identifier, with: DashboardCommand.self),
            completer: completer(identifier)
        )
    }
}

struct DashboardMainDestination {
    let activation: MainboardActivation<DashboardParameter>
    let blockActivation: BlockTaskMainboardActivation<DashboardInput, DashboardOutput>
    let interaction: MainboardInteraction<DashboardCommand>
    let completer: MainboardCompleter
    let flow: FlowHandler<DashboardOutput>
    let action: ActionFlowHandler<DashboardAction>
    let completion: CompletionFlowHandler
}

extension MotherboardType where Self: FlowManageable {
    func ioDashboard(_ identifier: BoardID = .modDashboard) -> DashboardMainDestination {
        DashboardMainDestination(
            activation: activation(identifier, with: DashboardParameter.self),
            blockActivation: blockActivation(identifier, with: BlockTaskParameter<DashboardInput, DashboardOutput>.self),
            interaction: interaction(identifier, with: DashboardCommand.self),
            completer: completer(identifier),
            flow: matchedFlow(identifier, with: DashboardOutput.self),
            action: actionFlow(identifier, with: DashboardAction.self),
            completion: completionFlow(identifier)
        )
    }
}
