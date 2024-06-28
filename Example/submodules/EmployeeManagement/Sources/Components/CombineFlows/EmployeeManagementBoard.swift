//
//  RootBoard.swift
//  EmployeeManagement
//
//  Created by BOARDY on 10/22/21.
//
//

import Boardy
import EmployeeManagement
import Foundation

enum EmployeeManagementBoardFactory {
    static func make(identifier: BoardID, producer: ActivatableBoardProducer) -> ActivatableBoard {
        FlowBoard<EmployeeManagementInput, EmployeeManagementOutput, EmployeeManagementCommand, EmployeeManagementAction>(identifier: identifier, producer: producer) { _ in
            // <#register flows#>
        } flowActivation: { it, _ in
            it.motherboard.ioEmployeeList().activation.activate()
        }
    }
}
