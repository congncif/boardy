//
//  AuthenticationServiceMap.swift
//  Authentication
//
//  Created by Boardy on 6/1/21.
//
//

import Boardy
import Foundation

/// List of provided services here
public extension AuthenticationServiceMap {
    var ioAuthentication: AuthenticationMainDestination {
        mainboard.ioAuthentication()
    }
}

public final class AuthenticationServiceMap: ServiceMap {}

public extension ServiceMap {
    var modAuthentication: AuthenticationServiceMap { link() }
}
