//
//  LogoutIOInterface.swift
//  Authentication
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import Boardy
import Foundation

// MARK: - ID

public extension BoardID {
    static let pubLogout: BoardID = "pub.mod.Authentication.Logout"
}

// MARK: - Interface

public struct LogoutDestination {
    public let activation: BoardActivation<LogoutParameter>
    public let blockActivation: BlockTaskBoardActivation<LogoutInput, LogoutOutput>
    public let interaction: BoardInteraction<LogoutCommand>
    public let completer: BoardCompleter

    public static let defaultIdentifier: BoardID = .pubLogout
}

extension ActivatableBoard {
    func ioLogout(_ identifier: BoardID = LogoutDestination.defaultIdentifier) -> LogoutDestination {
        LogoutDestination(
            activation: activation(identifier, with: LogoutParameter.self),
            blockActivation: blockActivation(identifier, with: BlockTaskParameter<LogoutInput, LogoutOutput>.self),
            interaction: interaction(identifier, with: LogoutCommand.self),
            completer: completer(identifier)
        )
    }
}

public struct LogoutMainDestination {
    public let activation: MainboardActivation<LogoutParameter>
    public let blockActivation: BlockTaskMainboardActivation<LogoutInput, LogoutOutput>
    public let interaction: MainboardInteraction<LogoutCommand>
    public let completer: MainboardCompleter
    public let flow: FlowHandler<LogoutOutput>
    public let action: ActionFlowHandler<LogoutAction>
    public let completion: CompletionFlowHandler

    public static let defaultIdentifier: BoardID = .pubLogout
}

extension MotherboardType where Self: FlowManageable {
    func ioLogout(_ identifier: BoardID = LogoutMainDestination.defaultIdentifier) -> LogoutMainDestination {
        LogoutMainDestination(
            activation: activation(identifier, with: LogoutParameter.self),
            blockActivation: blockActivation(identifier, with: BlockTaskParameter<LogoutInput, LogoutOutput>.self),
            interaction: interaction(identifier, with: LogoutCommand.self),
            completer: completer(identifier),
            flow: matchedFlow(identifier, with: LogoutOutput.self),
            action: actionFlow(identifier, with: LogoutAction.self),
            completion: completionFlow(identifier)
        )
    }
}
