//
//  EmployeeListProtocols.swift
//  EmployeeManagementPlugins
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import UIKit

// MARK: - Inward

/// Use for pushing messages inwards from outside
protocol EmployeeListControllable: AnyObject {}

// MARK: - Outward

/// Use for ViewController sending messages to outside directly
protocol EmployeeListActionDelegate: AnyObject {}

/// Use for Controller (Interactor) sending messages to outside
protocol EmployeeListControlDelegate: AnyObject {
    func loadData()
}

/// Interface combined of above two delegates for convenience using purpose
protocol EmployeeListDelegate: EmployeeListActionDelegate, EmployeeListControlDelegate {}

// MARK: - Interface

/// Defined interface for outside using purpose
protocol EmployeeListUserInterface: UIViewController {}

struct EmployeeListInterface {
    let userInterface: EmployeeListUserInterface
    let controller: EmployeeListControllable
}

/// Construct and connect dependencies
protocol EmployeeListBuildable {
    func build(withDelegate delegate: EmployeeListDelegate?) -> EmployeeListInterface
}
