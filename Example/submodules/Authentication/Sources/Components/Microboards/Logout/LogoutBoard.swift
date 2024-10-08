//
//  LogoutBoard.swift
//  AuthenticationPlugins
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import Authentication
import Boardy
import Foundation
import SiFUtilities
import UIKit

final class LogoutBoard: ModernContinuableBoard, GuaranteedBoard, GuaranteedOutputSendingBoard, GuaranteedActionSendingBoard, GuaranteedCommandBoard {
    typealias InputType = LogoutInput
    typealias OutputType = LogoutOutput
    typealias FlowActionType = LogoutAction
    typealias CommandType = LogoutCommand

    private let authStateProvider: AuthStateUpdater

    init(identifier: BoardID, producer: ActivatableBoardProducer, authStateProvider: AuthStateUpdater) {
        self.authStateProvider = authStateProvider
        super.init(identifier: identifier, boardProducer: producer)
        registerFlows()
    }

    /// Build and run an instance of Boardy micro-service
    func activate(withGuaranteedInput _: InputType) {
        rootViewController.topPresentedViewController.confirm(message: "Are you sure logout?") { [weak self] in
            self?.authStateProvider.update(user: nil)
            self?.sendOutput(nil)
        }
    }

    /// Handle the command received from other boards
    func interact(guaranteedCommand _: CommandType) {}
}

private extension LogoutBoard {
    func registerFlows() {}
}
