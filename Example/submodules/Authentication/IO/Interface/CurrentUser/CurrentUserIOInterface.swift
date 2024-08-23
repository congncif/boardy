//
//  CurrentUserIOInterface.swift
//  Authentication
//
//  Created by NGUYEN CHI CONG on 23/8/24.
//  Compatible with Boardy 1.55.1 or later
//

import Boardy
import Foundation

// MARK: - ID

public extension BoardID {
    static let pubCurrentUser: BoardID = "pub.mod.Authentication.CurrentUser"
}

// MARK: - Interface

public typealias CurrentUserMainDestination = MainboardGenericDestination<CurrentUserInput, CurrentUserOutput, CurrentUserCommand, CurrentUserAction>

extension MotherboardType where Self: FlowManageable {
    func ioCurrentUser(_ identifier: BoardID = .pubCurrentUser) -> CurrentUserMainDestination {
        CurrentUserMainDestination(destinationID: identifier, mainboard: self)
    }
}

// public typealias CurrentUserDestination = BoardGenericDestination<CurrentUserInput, CurrentUserCommand>
//
// public extension ActivatableBoard {
//    func ioCurrentUser(_ identifier: BoardID = .pubCurrentUser) -> CurrentUserDestination {
//        CurrentUserDestination(destinationID: identifier, source: self)
//    }
// }
