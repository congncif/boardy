//
//  EmployeeManagementIOInterface.swift
//  EmployeeManagement
//
//  Created by Boardy on 6/1/21.
//
//

import Boardy
import Foundation

// MARK: - ID

public extension BoardID {
    static let pubEmployeeManagement: BoardID = "pub.mod.EmployeeManagementIO.default"
}

// MARK: - Interface

public struct EmployeeManagementDestination {
    public let activation: BoardActivation<EmployeeManagementParameter>
    public let interaction: BoardInteraction<EmployeeManagementCommand>
    public let completer: BoardCompleter

    public static let defaultIdentifier: BoardID = .pubEmployeeManagement
}

extension ActivatableBoard {
    func ioEmployeeManagement(_ identifier: BoardID = EmployeeManagementDestination.defaultIdentifier) -> EmployeeManagementDestination {
        EmployeeManagementDestination(
            activation: activation(identifier, with: EmployeeManagementParameter.self),
            interaction: interaction(identifier, with: EmployeeManagementCommand.self),
            completer: completer(identifier)
        )
    }
}

public struct EmployeeManagementMainDestination {
    public let activation: MainboardActivation<EmployeeManagementParameter>
    public let interaction: MainboardInteraction<EmployeeManagementCommand>
    public let completer: MainboardCompleter
    public let flow: FlowHandler<EmployeeManagementOutput>
    public let action: ActionFlowHandler<EmployeeManagementAction>
    public let completion: CompletionFlowHandler

    public static let defaultIdentifier: BoardID = .pubEmployeeManagement
}

extension MotherboardType where Self: FlowManageable {
    func ioEmployeeManagement(_ identifier: BoardID = EmployeeManagementMainDestination.defaultIdentifier) -> EmployeeManagementMainDestination {
        EmployeeManagementMainDestination(
            activation: activation(identifier, with: EmployeeManagementParameter.self),
            interaction: interaction(identifier, with: EmployeeManagementCommand.self),
            completer: completer(identifier),
            flow: matchedFlow(identifier, with: EmployeeManagementOutput.self),
            action: actionFlow(identifier, with: EmployeeManagementAction.self),
            completion: completionFlow(identifier)
        )
    }
}
