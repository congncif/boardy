//
//  CurrentUserIOInterface.swift
//  Authentication
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import Boardy
import Foundation

// MARK: - ID

public extension BoardID {
    static let pubCurrentUser: BoardID = "pub.mod.Authentication.CurrentUser"
}

// MARK: - Interface

public struct CurrentUserDestination {
    public let activation: BoardActivation<CurrentUserParameter>
    public let blockActivation: BlockTaskBoardActivation<CurrentUserInput, CurrentUserOutput>
    public let interaction: BoardInteraction<CurrentUserCommand>
    public let completer: BoardCompleter

    public static let defaultIdentifier: BoardID = .pubCurrentUser
}

extension ActivatableBoard {
    func ioCurrentUser(_ identifier: BoardID = CurrentUserDestination.defaultIdentifier) -> CurrentUserDestination {
        CurrentUserDestination(
            activation: activation(identifier, with: CurrentUserParameter.self),
            blockActivation: blockActivation(identifier, with: BlockTaskParameter<CurrentUserInput, CurrentUserOutput>.self),
            interaction: interaction(identifier, with: CurrentUserCommand.self),
            completer: completer(identifier)
        )
    }
}

public struct CurrentUserMainDestination {
    public let activation: MainboardActivation<CurrentUserParameter>
    public let blockActivation: BlockTaskMainboardActivation<CurrentUserInput, CurrentUserOutput>
    public let interaction: MainboardInteraction<CurrentUserCommand>
    public let completer: MainboardCompleter
    public let flow: FlowHandler<CurrentUserOutput>
    public let action: ActionFlowHandler<CurrentUserAction>
    public let completion: CompletionFlowHandler

    public static let defaultIdentifier: BoardID = .pubCurrentUser
}

extension MotherboardType where Self: FlowManageable {
    func ioCurrentUser(_ identifier: BoardID = CurrentUserMainDestination.defaultIdentifier) -> CurrentUserMainDestination {
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
