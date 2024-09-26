//
//  EmployeeListIOInterface.swift
//  EmployeeManagementPlugins
//
//  Created by NGUYEN CHI CONG on 23/8/24.
//  Compatible with Boardy 1.55.1 or later
//

import Boardy
import Foundation

// MARK: - ID

extension BoardID {
    static let modEmployeeList: BoardID = "mod.EmployeeManagementPlugins.EmployeeList"
}

// MARK: - Interface

typealias EmployeeListMainDestination = MainboardGenericDestination<EmployeeListInput, EmployeeListOutput, EmployeeListCommand, EmployeeListAction>

extension MotherboardType where Self: FlowManageable {
    func ioEmployeeList(_ identifier: BoardID = .modEmployeeList) -> EmployeeListMainDestination {
        EmployeeListMainDestination(destinationID: identifier, mainboard: self)
    }
}
