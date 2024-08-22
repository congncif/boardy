//
//  LoginIOInterface.swift
//  Authentication
//
//  Created by NGUYEN CHI CONG on 22/8/24.
//  Compatible with Boardy 1.55.1 or later
//

import Boardy
import Foundation

// MARK: - ID

public extension BoardID {
    static let pubLogin: BoardID = "pub.mod.Authentication.Login"
}

// MARK: - Interface

public typealias LoginDestination = BoardGenericDestination<LoginInput, LoginCommand>

extension ActivatableBoard {
    func ioLogin(_ identifier: BoardID = .pubLogin) -> LoginDestination {
        LoginDestination(destinationID: identifier, source: self)
    }
}

public typealias LoginMainDestination = MainboardGenericDestination<LoginInput, LoginOutput, LoginCommand, LoginAction>

extension MotherboardType where Self: FlowManageable {
    func ioLogin(_ identifier: BoardID = .pubLogin) -> LoginMainDestination {
        LoginMainDestination(destinationID: identifier, mainboard: self)
    }
}
