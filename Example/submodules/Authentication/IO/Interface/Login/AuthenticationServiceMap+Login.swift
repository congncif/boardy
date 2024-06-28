//
//  AuthenticationServiceMap+Login.swift
//  Authentication
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import Boardy
import Foundation

public extension AuthenticationServiceMap {
    var ioLogin: LoginMainDestination {
        mainboard.ioLogin()
    }
}
