//
//  BoardID.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 8/10/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Boardy
import Foundation

extension BoardID {
    static let login = "login"
    static let main = "main"
}

enum BoardIdentity {
    case login
    case main(userInfo: UserInfo)

    var identifier: String {
        switch self {
        case .login:
            return .login
        case .main:
            return .main
        }
    }

    var option: Any? {
        switch self {
        case .login:
            return nil
        case let .main(userInfo: info):
            return info
        }
    }
}

extension MotherboardType {
    func activateBoard(identity: BoardIdentity) {
        activateBoard(identifier: identity.identifier, withOption: identity.option)
    }
}
