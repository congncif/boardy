//
//  AuthenticationServiceMap+Logout.swift
//  Authentication
//
//  Created by NGUYEN CHI CONG on 22/8/24.
//  Compatible with Boardy 1.55.1 or later
//

import Boardy
import Foundation

public extension AuthenticationServiceMap {
    var ioLogout: LogoutMainDestination {
        mainboard.ioLogout()
    }
}
