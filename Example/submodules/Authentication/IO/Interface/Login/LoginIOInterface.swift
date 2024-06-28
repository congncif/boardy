//
//  LoginIOInterface.swift
//  Authentication
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import Boardy
import Foundation

// MARK: - ID

public extension BoardID {
    static let pubLogin: BoardID = "pub.mod.Authentication.Login"
}

// MARK: - Interface

public struct LoginDestination {
    public let activation: BoardActivation<LoginParameter>
    public let blockActivation: BlockTaskBoardActivation<LoginInput, LoginOutput>
    public let interaction: BoardInteraction<LoginCommand>
    public let completer: BoardCompleter

    public static let defaultIdentifier: BoardID = .pubLogin
}

extension ActivatableBoard {
    func ioLogin(_ identifier: BoardID = LoginDestination.defaultIdentifier) -> LoginDestination {
        LoginDestination(
            activation: activation(identifier, with: LoginParameter.self),
            blockActivation: blockActivation(identifier, with: BlockTaskParameter<LoginInput, LoginOutput>.self),
            interaction: interaction(identifier, with: LoginCommand.self),
            completer: completer(identifier)
        )
    }
}

public struct LoginMainDestination {
    public let activation: MainboardActivation<LoginParameter>
    public let blockActivation: BlockTaskMainboardActivation<LoginInput, LoginOutput>
    public let interaction: MainboardInteraction<LoginCommand>
    public let completer: MainboardCompleter
    public let flow: FlowHandler<LoginOutput>
    public let action: ActionFlowHandler<LoginAction>
    public let completion: CompletionFlowHandler

    public static let defaultIdentifier: BoardID = .pubLogin
}

extension MotherboardType where Self: FlowManageable {
    func ioLogin(_ identifier: BoardID = LoginMainDestination.defaultIdentifier) -> LoginMainDestination {
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
