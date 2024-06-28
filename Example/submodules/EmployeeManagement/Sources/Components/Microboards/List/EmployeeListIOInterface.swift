//
//  EmployeeListIOInterface.swift
//  EmployeeManagementPlugins
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import Boardy
import Foundation

// MARK: - ID

extension BoardID {
    static let modEmployeeList: BoardID = "mod.EmployeeManagementPlugins.EmployeeList"
}

// MARK: - Interface

struct EmployeeListDestination {
    let activation: BoardActivation<EmployeeListParameter>
    let blockActivation: BlockTaskBoardActivation<EmployeeListInput, EmployeeListOutput>
    let interaction: BoardInteraction<EmployeeListCommand>
    let completer: BoardCompleter
}

extension ActivatableBoard {
    func ioEmployeeList(_ identifier: BoardID = .modEmployeeList) -> EmployeeListDestination {
        EmployeeListDestination(
            activation: activation(identifier, with: EmployeeListParameter.self),
            blockActivation: blockActivation(identifier, with: BlockTaskParameter<EmployeeListInput, EmployeeListOutput>.self),
            interaction: interaction(identifier, with: EmployeeListCommand.self),
            completer: completer(identifier)
        )
    }
}

struct EmployeeListMainDestination {
    let activation: MainboardActivation<EmployeeListParameter>
    let blockActivation: BlockTaskMainboardActivation<EmployeeListInput, EmployeeListOutput>
    let interaction: MainboardInteraction<EmployeeListCommand>
    let completer: MainboardCompleter
    let flow: FlowHandler<EmployeeListOutput>
    let action: ActionFlowHandler<EmployeeListAction>
    let completion: CompletionFlowHandler
}

extension MotherboardType where Self: FlowManageable {
    func ioEmployeeList(_ identifier: BoardID = .modEmployeeList) -> EmployeeListMainDestination {
        EmployeeListMainDestination(
            activation: activation(identifier, with: EmployeeListParameter.self),
            blockActivation: blockActivation(identifier, with: BlockTaskParameter<EmployeeListInput, EmployeeListOutput>.self),
            interaction: interaction(identifier, with: EmployeeListCommand.self),
            completer: completer(identifier),
            flow: matchedFlow(identifier, with: EmployeeListOutput.self),
            action: actionFlow(identifier, with: EmployeeListAction.self),
            completion: completionFlow(identifier)
        )
    }
}
