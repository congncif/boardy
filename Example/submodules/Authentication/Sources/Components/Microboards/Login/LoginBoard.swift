//
//  LoginBoard.swift
//  AuthenticationPlugins
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import Boardy
import Foundation
import SiFUtilities
import UIKit

final class LoginBoard: ModernContinuableBoard, GuaranteedBoard, GuaranteedOutputSendingBoard, GuaranteedActionSendingBoard, GuaranteedCommandBoard {
    typealias InputType = LoginParameter
    typealias OutputType = LoginOutput
    typealias FlowActionType = LoginAction
    typealias CommandType = LoginCommand

    // MARK: Dependencies

    private let builder: LoginBuildable

    init(identifier: BoardID, builder: LoginBuildable, producer: ActivatableBoardProducer) {
        self.builder = builder
        super.init(identifier: identifier, boardProducer: producer)
        registerFlows()
    }

    /// Build and run an instance of Boardy micro-service
    func activate(withGuaranteedInput _: InputType) {
        let component = builder.build(withDelegate: self)
        let viewController = component.userInterface
        motherboard.putIntoContext(viewController)
        rootViewController.show(viewController) { config in
            config.style = .defaultPresent
        }

        returnBus.connect(target: self) { target, output in
            target.rootViewController.returnHere { [weak target] in
                target?.sendOutput(output)
            }
        }
    }

    /// Handle the command received from other boards
    func interact(guaranteedCommand _: CommandType) {}

    // MARK: Private properties

    private let returnBus = Bus<LoginOutput>()
}

extension LoginBoard: LoginDelegate {
    func userDidLogin(_ user: LoginOutput) {
        returnBus.transport(input: user)
    }

    func loadData() {}
}

private extension LoginBoard {
    func registerFlows() {}
}
