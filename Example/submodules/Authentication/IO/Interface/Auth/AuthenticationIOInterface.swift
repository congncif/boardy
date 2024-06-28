//
//  AuthenticationIOInterface.swift
//  Authentication
//
//  Created by Boardy on 6/1/21.
//
//

import Boardy
import Foundation

// MARK: - ID

public extension BoardID {
    static let pubAuthentication: BoardID = "pub.mod.AuthenticationIO.default"
}

// MARK: - Interface

public struct AuthenticationDestination {
    public let activation: BoardActivation<AuthenticationParameter>
    public let interaction: BoardInteraction<AuthenticationCommand>
    public let completer: BoardCompleter

    public static let defaultIdentifier: BoardID = .pubAuthentication
}

extension ActivatableBoard {
    func ioAuthentication(_ identifier: BoardID = AuthenticationDestination.defaultIdentifier) -> AuthenticationDestination {
        AuthenticationDestination(
            activation: activation(identifier, with: AuthenticationParameter.self),
            interaction: interaction(identifier, with: AuthenticationCommand.self),
            completer: completer(identifier)
        )
    }
}

public struct AuthenticationMainDestination {
    public let activation: MainboardActivation<AuthenticationParameter>
    public let interaction: MainboardInteraction<AuthenticationCommand>
    public let completer: MainboardCompleter
    public let flow: FlowHandler<AuthenticationOutput>
    public let action: ActionFlowHandler<AuthenticationAction>
    public let completion: CompletionFlowHandler

    public static let defaultIdentifier: BoardID = .pubAuthentication
}

extension MotherboardType where Self: FlowManageable {
    func ioAuthentication(_ identifier: BoardID = AuthenticationMainDestination.defaultIdentifier) -> AuthenticationMainDestination {
        AuthenticationMainDestination(
            activation: activation(identifier, with: AuthenticationParameter.self),
            interaction: interaction(identifier, with: AuthenticationCommand.self),
            completer: completer(identifier),
            flow: matchedFlow(identifier, with: AuthenticationOutput.self),
            action: actionFlow(identifier, with: AuthenticationAction.self),
            completion: completionFlow(identifier)
        )
    }
}
