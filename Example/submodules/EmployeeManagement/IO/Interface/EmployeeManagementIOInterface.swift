//
//  EmployeeManagementIOInterface.swift
//  EmployeeManagement
//
//  Created by NGUYEN CHI CONG on 23/8/24.
//  Compatible with Boardy 1.55.1 or later
//

import Boardy
import Foundation

// MARK: - ID

public extension BoardID {
    static let pubEmployeeManagement: BoardID = "pub.mod.EmployeeManagement.EmployeeManagement"
}

// MARK: - Interface

public typealias EmployeeManagementMainDestination = MainboardGenericDestination<EmployeeManagementInput, EmployeeManagementOutput, EmployeeManagementCommand, EmployeeManagementAction>

extension MotherboardType where Self: FlowManageable {
    func ioEmployeeManagement(_ identifier: BoardID = .pubEmployeeManagement) -> EmployeeManagementMainDestination {
        EmployeeManagementMainDestination(destinationID: identifier, mainboard: self)
    }
}

// public typealias EmployeeManagementDestination = BoardGenericDestination<EmployeeManagementInput, EmployeeManagementCommand>
//
// public extension ActivatableBoard {
//    func ioEmployeeManagement(_ identifier: BoardID = .pubEmployeeManagement) -> EmployeeManagementDestination {
//        EmployeeManagementDestination(destinationID: identifier, source: self)
//    }
// }
