//
//  EmployeeManagementServiceMap.swift
//  EmployeeManagement
//
//  Created by Boardy on 6/1/21.
//
//

import Boardy
import Foundation

/// List of provided services here
public extension EmployeeManagementServiceMap {
    var ioEmployeeManagement: EmployeeManagementMainDestination {
        mainboard.ioEmployeeManagement()
    }
}

public final class EmployeeManagementServiceMap: ServiceMap {}

public extension ServiceMap {
    var modEmployeeManagement: EmployeeManagementServiceMap { link() }
}
