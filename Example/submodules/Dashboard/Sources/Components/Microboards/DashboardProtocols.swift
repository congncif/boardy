//
//  DashboardProtocols.swift
//  DashboardPlugins
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import Authentication
import UIKit

// MARK: - Inward

/// Use for pushing messages inwards from outside
protocol DashboardControllable: AnyObject, CurrentUserObserver {
    func update(currentUser: User?)
}

// MARK: - Outward

/// Use for ViewController sending messages to outside directly
protocol DashboardActionDelegate: AnyObject {
    func openLogin()
    func openEmployeeManagement()
    func doLogout()
}

/// Use for Controller (Interactor) sending messages to outside
protocol DashboardControlDelegate: AnyObject {
    func loadData(with listener: CurrentUserObserver?)
}

/// Interface combined of above two delegates for convenience using purpose
protocol DashboardDelegate: DashboardActionDelegate, DashboardControlDelegate {}

// MARK: - Interface

/// Defined interface for outside using purpose
protocol DashboardUserInterface: UIViewController {}

struct DashboardInterface {
    let userInterface: DashboardUserInterface
    let controller: DashboardControllable
}

/// Construct and connect dependencies
protocol DashboardBuildable {
    func build(withDelegate delegate: DashboardDelegate?) -> DashboardInterface
}
