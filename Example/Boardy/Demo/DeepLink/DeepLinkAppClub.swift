//
//  DeepLinkAppClub.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 9/1/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Boardy
import Foundation
import Resolver

// Wrap an array to pass LazyInjected convention of Resolver.
struct DeepLinkBoardCollection {
    let boards: [ActivatableBoard]
}

final class DeepLinkAppClub: DeepLinkHandlerClubbing {
    @LazyInjected var appMainboard: AppMotherboard

    @LazyInjected var boardCollection: DeepLinkBoardCollection

    private lazy var mainboard: FlowMotherboard = {
        appMainboard.extended(boards: boardCollection.boards)
    }()

    var identifier: String { String(describing: self) }

    var workflowMainboards: [FlowMotherboard] { [mainboard] }

    var parser: DeepLinkParsing {
        DeepLinkParser { (deepLink) -> BoardIdentity? in
            switch deepLink {
            case "boardy://login":
                return .login
            case "boardy://dashboard":
                return .dashboard
            case "boardy://main":
                return .main(userInfo: UserInfo(username: "DeepLink", password: ""))
            default:
                return nil
            }
        }
    }
}
