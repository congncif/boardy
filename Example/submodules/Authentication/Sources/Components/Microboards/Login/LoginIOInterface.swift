//
//  LoginIOInterface.swift
//  AuthenticationPlugins
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import Boardy
import Foundation

// MARK: - ID

extension BoardID {
    static let modLogin: BoardID = "mod.AuthenticationPlugins.Login"
}

// MARK: - Interface

struct LoginDestination {
    let activation: BoardActivation<LoginParameter>
    let blockActivation: BlockTaskBoardActivation<LoginInput, LoginOutput>
    let interaction: BoardInteraction<LoginCommand>
    let completer: BoardCompleter
}

extension ActivatableBoard {
    func ioLogin(_ identifier: BoardID = .modLogin) -> LoginDestination {
        LoginDestination(
            activation: activation(identifier, with: LoginParameter.self),
            blockActivation: blockActivation(identifier, with: BlockTaskParameter<LoginInput, LoginOutput>.self),
            interaction: interaction(identifier, with: LoginCommand.self),
            completer: completer(identifier)
        )
    }
}

struct LoginMainDestination {
    let activation: MainboardActivation<LoginParameter>
    let blockActivation: BlockTaskMainboardActivation<LoginInput, LoginOutput>
    let interaction: MainboardInteraction<LoginCommand>
    let completer: MainboardCompleter
    let flow: FlowHandler<LoginOutput>
    let action: ActionFlowHandler<LoginAction>
    let completion: CompletionFlowHandler
}

extension MotherboardType where Self: FlowManageable {
    func ioLogin(_ identifier: BoardID = .modLogin) -> LoginMainDestination {
        LoginMainDestination(
            activation: activation(identifier, with: LoginParameter.self),
            blockActivation: blockActivation(identifier, with: BlockTaskParameter<LoginInput, LoginOutput>.self),
            interaction: interaction(identifier, with: LoginCommand.self),
            completer: completer(identifier),
            flow: matchedFlow(identifier, with: LoginOutput.self),
            action: actionFlow(identifier, with: LoginAction.self),
            completion: completionFlow(identifier)
        )
    }
}
