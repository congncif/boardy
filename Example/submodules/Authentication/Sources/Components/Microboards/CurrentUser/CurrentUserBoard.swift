//
//  CurrentUserBoard.swift
//  AuthenticationPlugins
//
//  Created by NGUYEN CHI CONG on 29/6/24.
//  Compatible with Boardy 1.54 or later
//

import Boardy
import Foundation
import UIKit

final class CurrentUserBoard: ModernContinuableBoard, GuaranteedBoard, GuaranteedOutputSendingBoard, GuaranteedActionSendingBoard, GuaranteedCommandBoard {
    typealias InputType = CurrentUserParameter
    typealias OutputType = CurrentUserOutput
    typealias FlowActionType = CurrentUserAction
    typealias CommandType = CurrentUserCommand

    private let authStateProvider: AuthStateObservable

    init(identifier: BoardID, producer: ActivatableBoardProducer, authStateProvider: AuthStateObservable) {
        self.authStateProvider = authStateProvider
        super.init(identifier: identifier, boardProducer: producer)
        registerFlows()
    }

    /// Build and run an instance of Boardy micro-service
    func activate(withGuaranteedInput input: InputType) {
        authStateProvider.addObserver(input)
    }

    /// Handle the command received from other boards
    func interact(guaranteedCommand _: CommandType) {}
}

private extension CurrentUserBoard {
    func registerFlows() {}
}
