//
//  EmployeeListBoard.swift
//  EmployeeManagementPlugins
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import Authentication
import Boardy
import Foundation
import SiFUtilities
import UIKit

final class EmployeeListBoard: ModernContinuableBoard, GuaranteedBoard, GuaranteedOutputSendingBoard, GuaranteedActionSendingBoard, GuaranteedCommandBoard {
    typealias InputType = EmployeeListParameter
    typealias OutputType = EmployeeListOutput
    typealias FlowActionType = EmployeeListAction
    typealias CommandType = EmployeeListCommand

    // MARK: Dependencies

    private let builder: EmployeeListBuildable

    init(identifier: BoardID, builder: EmployeeListBuildable, producer: ActivatableBoardProducer) {
        self.builder = builder
        super.init(identifier: identifier, boardProducer: producer)
        registerFlows()
    }

//    func activationBarrier(withGuaranteedInput _: EmployeeListParameter) -> ActivationBarrier? {
//        serviceMap.modAuthentication.ioCurrentUser.activation.barrier(with: CurrentUserInput(observer: nil))
//    }

    /// Build and run an instance of Boardy micro-service
    func activate(withGuaranteedInput _: InputType) {
        let component = builder.build(withDelegate: self)
        let viewController = component.userInterface
        motherboard.putIntoContext(viewController)
        rootViewController.show(viewController)
    }

    /// Handle the command received from other boards
    func interact(guaranteedCommand _: CommandType) {}

    // MARK: Private properties
}

extension EmployeeListBoard: EmployeeListDelegate {
    func loadData() {}
}

private extension EmployeeListBoard {
    func registerFlows() {}
}
