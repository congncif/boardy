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
    static let login: BoardID = "login"
    static let main: BoardID = "main"
    static let dashboard: BoardID = "dashboard"
    static let root: BoardID = "root"
    static let headline: BoardID = "headline"
    static let featured: BoardID = "featured"
}

enum BoardIdentity: BoardInputModel {
    case root
    case login
    case main(userInfo: UserInfo)
    case dashboard

    var identifier: BoardID {
        switch self {
        case .root:
            return .root
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

enum HeadlineCommand: BoardCommandModel {
    case refresh(label: String)

    var identifier: BoardID { .headline }

    var data: Any? {
        switch self {
        case let .refresh(label: value):
            return value
        }
    }
}

extension MotherboardType {
    func activateBoard(_ identity: BoardIdentity) {
        activateBoard(model: identity)
    }
}

extension IdentifiableBoard {
    func nextToBoard(_ identity: BoardIdentity) {
        nextToBoard(model: identity)
    }

    func sendAction(_ action: BoardAction) {
        sendFlowAction(action)
    }
}

enum BoardAction: BoardFlowAction {
    case `return`
}
