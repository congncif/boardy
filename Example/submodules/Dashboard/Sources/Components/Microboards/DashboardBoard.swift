//
//  DashboardBoard.swift
//  DashboardPlugins
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import Authentication
import Boardy
import EmployeeManagement
import Foundation
import SiFUtilities
import UIKit

final class DashboardBoard: ModernContinuableBoard, GuaranteedBoard, GuaranteedOutputSendingBoard, GuaranteedActionSendingBoard, GuaranteedCommandBoard {
    typealias InputType = DashboardParameter
    typealias OutputType = DashboardOutput
    typealias FlowActionType = DashboardAction
    typealias CommandType = DashboardCommand

    // MARK: Dependencies

    private let builder: DashboardBuildable

    init(identifier: BoardID, builder: DashboardBuildable, producer: ActivatableBoardProducer) {
        self.builder = builder
        super.init(identifier: identifier, boardProducer: producer)
        registerFlows()
    }

    /// Build and run an instance of Boardy micro-service
    func activate(withGuaranteedInput _: InputType) {
        let component = builder.build(withDelegate: self)
        let viewController = component.userInterface
        motherboard.putIntoContext(viewController)

        let navigationController = UINavigationController(rootViewController: viewController)
        window.setRootViewController(navigationController, animated: false)

        currentUserBus.connect(target: component.controller) { target, user in
            target.updateCurrentUser(user)
        }
    }

    /// Handle the command received from other boards
    func interact(guaranteedCommand _: CommandType) {}

    // MARK: Private properties

    private let currentUserBus = Bus<User?>()
}

extension DashboardBoard: DashboardDelegate {
    func loadData() {
        serviceMap.modAuthentication.ioCurrentUser.activation.activate()
    }

    func openLogin() {
        serviceMap.modAuthentication.ioLogin.activation.activate()
    }

    func doLogout() {
        serviceMap.modAuthentication.ioLogout.activation.activate()
    }

    func openEmployeeManagement() {
        serviceMap.modEmployeeManagement.ioEmployeeManagement.activation.activate()
    }
}

private extension DashboardBoard {
    func registerFlows() {
        serviceMap.modAuthentication.ioCurrentUser.flow.bind(to: currentUserBus)
        serviceMap.modAuthentication.ioLogin.flow.bind(to: currentUserBus)
        serviceMap.modAuthentication.ioLogout.flow.bind(to: currentUserBus)
    }
}
