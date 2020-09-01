//
//  BoardID.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 8/10/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Boardy
import Foundation

extension BoardID {
    static let login = "login"
    static let main = "main"
    static let dashboard = "dashboard"
}

enum BoardIdentity: BoardInputModel {
    case login
    case main(userInfo: UserInfo)
    case dashboard

    var identifier: String {
        switch self {
        case .login:
            return .login
        case .main:
            return .main
        case .dashboard:
            return .dashboard
        }
    }

    var option: Any? {
        switch self {
        case let .main(userInfo: info):
            return info
        default:
            return nil
        }
    }
}

extension MotherboardType {
    func activateBoard(identity: BoardIdentity) {
        activateBoard(model: identity)
    }
}
