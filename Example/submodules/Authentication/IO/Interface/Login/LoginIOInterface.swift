//
//  LoginIOInterface.swift
//  Authentication
//
//  Created by NGUYEN CHI CONG on 23/8/24.
//  Compatible with Boardy 1.55.1 or later
//

import Boardy
import Foundation

// MARK: - ID

public extension BoardID {
    static let pubLogin: BoardID = "pub.mod.Authentication.Login"
}

// MARK: - Interface

public typealias LoginMainDestination = MainboardGenericDestination<LoginInput, LoginOutput, LoginCommand, LoginAction>

extension MotherboardType where Self: FlowManageable {
    func ioLogin(_ identifier: BoardID = .pubLogin) -> LoginMainDestination {
        LoginMainDestination(destinationID: identifier, mainboard: self)
    }
}
