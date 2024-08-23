//
//  AuthenticationIOInterface.swift
//  Authentication
//
//  Created by NGUYEN CHI CONG on 23/8/24.
//  Compatible with Boardy 1.55.1 or later
//

import Boardy
import Foundation

// MARK: - ID

public extension BoardID {
    static let pubAuthentication: BoardID = "pub.mod.Authentication.Authentication"
}

// MARK: - Interface

public typealias AuthenticationMainDestination = MainboardGenericDestination<AuthenticationInput, AuthenticationOutput, AuthenticationCommand, AuthenticationAction>

extension MotherboardType where Self: FlowManageable {
    func ioAuthentication(_ identifier: BoardID = .pubAuthentication) -> AuthenticationMainDestination {
        AuthenticationMainDestination(destinationID: identifier, mainboard: self)
    }
}

// public typealias AuthenticationDestination = BoardGenericDestination<AuthenticationInput, AuthenticationCommand>
//
// extension ActivatableBoard {
//    func ioAuthentication(_ identifier: BoardID = .pubAuthentication) -> AuthenticationDestination {
//        AuthenticationDestination(destinationID: identifier, source: self)
//    }
// }
