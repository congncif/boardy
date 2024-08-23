//
//  LoginProtocols.swift
//  AuthenticationPlugins
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import Authentication
import UIKit

// MARK: - Inward

/// Use for pushing messages inwards from outside
protocol LoginControllable: AnyObject {}

// MARK: - Outward

/// Use for ViewController sending messages to outside directly
protocol LoginActionDelegate: AnyObject {}

/// Use for Controller (Interactor) sending messages to outside
protocol LoginControlDelegate: AnyObject {
    func loadData()
    func userDidLogin(_ user: LoginOutput)
}

/// Interface combined of above two delegates for convenience using purpose
protocol LoginDelegate: LoginActionDelegate, LoginControlDelegate {}

// MARK: - Interface

/// Defined interface for outside using purpose
protocol LoginUserInterface: UIViewController {}

struct LoginInterface {
    let userInterface: LoginUserInterface
    let controller: LoginControllable
}

/// Construct and connect dependencies
protocol LoginBuildable {
    func build(withDelegate delegate: LoginDelegate?) -> LoginInterface
}
