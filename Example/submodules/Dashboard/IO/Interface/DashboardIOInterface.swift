//
//  DashboardIOInterface.swift
//  Dashboard
//
//  Created by Boardy on 6/1/21.
//
//

import Boardy
import Foundation

// MARK: - ID

public extension BoardID {
    static let pubDashboard: BoardID = "pub.mod.DashboardIO.default"
}

// MARK: - Interface

public struct DashboardDestination {
    public let activation: BoardActivation<DashboardParameter>
    public let interaction: BoardInteraction<DashboardCommand>
    public let completer: BoardCompleter

    public static let defaultIdentifier: BoardID = .pubDashboard
}

extension ActivatableBoard {
    func ioDashboard(_ identifier: BoardID = DashboardDestination.defaultIdentifier) -> DashboardDestination {
        DashboardDestination(
            activation: activation(identifier, with: DashboardParameter.self),
            interaction: interaction(identifier, with: DashboardCommand.self),
            completer: completer(identifier)
        )
    }
}

public struct DashboardMainDestination {
    public let activation: MainboardActivation<DashboardParameter>
    public let interaction: MainboardInteraction<DashboardCommand>
    public let completer: MainboardCompleter
    public let flow: FlowHandler<DashboardOutput>
    public let action: ActionFlowHandler<DashboardAction>
    public let completion: CompletionFlowHandler

    public static let defaultIdentifier: BoardID = .pubDashboard
}

extension MotherboardType where Self: FlowManageable {
    func ioDashboard(_ identifier: BoardID = DashboardMainDestination.defaultIdentifier) -> DashboardMainDestination {
        DashboardMainDestination(
            activation: activation(identifier, with: DashboardParameter.self),
            interaction: interaction(identifier, with: DashboardCommand.self),
            completer: completer(identifier),
            flow: matchedFlow(identifier, with: DashboardOutput.self),
            action: actionFlow(identifier, with: DashboardAction.self),
            completion: completionFlow(identifier)
        )
    }
}
