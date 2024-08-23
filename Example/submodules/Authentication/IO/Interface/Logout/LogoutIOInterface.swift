//
//  LogoutIOInterface.swift
//  Authentication
//
//  Created by NGUYEN CHI CONG on 23/8/24.
//  Compatible with Boardy 1.55.1 or later
//

import Boardy
import Foundation

// MARK: - ID

public extension BoardID {
    static let pubLogout: BoardID = "pub.mod.Authentication.Logout"
}

// MARK: - Interface

public typealias LogoutMainDestination = MainboardGenericDestination<LogoutInput, LogoutOutput, LogoutCommand, LogoutAction>

extension MotherboardType where Self: FlowManageable {
    func ioLogout(_ identifier: BoardID = .pubLogout) -> LogoutMainDestination {
        LogoutMainDestination(destinationID: identifier, mainboard: self)
    }
}

// public typealias LogoutDestination = BoardGenericDestination<LogoutInput, LogoutCommand>
//
// extension ActivatableBoard {
//    func ioLogout(_ identifier: BoardID = .pubLogout) -> LogoutDestination {
//        LogoutDestination(destinationID: identifier, source: self)
//    }
// }
