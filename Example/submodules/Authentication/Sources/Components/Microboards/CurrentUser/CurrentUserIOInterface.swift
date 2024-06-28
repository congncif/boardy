//
//  CurrentUserIOInterface.swift
//  AuthenticationPlugins
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import Boardy
import Foundation

// MARK: - ID

extension BoardID {
    static let modCurrentUser: BoardID = "mod.AuthenticationPlugins.CurrentUser"
}

// MARK: - Interface

struct CurrentUserDestination {
    let activation: BoardActivation<CurrentUserParameter>
    let blockActivation: BlockTaskBoardActivation<CurrentUserInput, CurrentUserOutput>
    let interaction: BoardInteraction<CurrentUserCommand>
    let completer: BoardCompleter
}

extension ActivatableBoard {
    func ioCurrentUser(_ identifier: BoardID = .modCurrentUser) -> CurrentUserDestination {
        CurrentUserDestination(
            activation: activation(identifier, with: CurrentUserParameter.self),
            blockActivation: blockActivation(identifier, with: BlockTaskParameter<CurrentUserInput, CurrentUserOutput>.self),
            interaction: interaction(identifier, with: CurrentUserCommand.self),
            completer: completer(identifier)
        )
    }
}

struct CurrentUserMainDestination {
    let activation: MainboardActivation<CurrentUserParameter>
    let blockActivation: BlockTaskMainboardActivation<CurrentUserInput, CurrentUserOutput>
    let interaction: MainboardInteraction<CurrentUserCommand>
    let completer: MainboardCompleter
    let flow: FlowHandler<CurrentUserOutput>
    let action: ActionFlowHandler<CurrentUserAction>
    let completion: CompletionFlowHandler
}

extension MotherboardType where Self: FlowManageable {
    func ioCurrentUser(_ identifier: BoardID = .modCurrentUser) -> CurrentUserMainDestination {
        CurrentUserMainDestination(
            activation: activation(identifier, with: CurrentUserParameter.self),
            blockActivation: blockActivation(identifier, with: BlockTaskParameter<CurrentUserInput, CurrentUserOutput>.self),
            interaction: interaction(identifier, with: CurrentUserCommand.self),
            completer: completer(identifier),
            flow: matchedFlow(identifier, with: CurrentUserOutput.self),
            action: actionFlow(identifier, with: CurrentUserAction.self),
            completion: completionFlow(identifier)
        )
    }
}
