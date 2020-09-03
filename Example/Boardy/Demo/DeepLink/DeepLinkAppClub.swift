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

final class DeepLinkAppClub: DeepLinkHandlerClubbing {
    @LazyInjected var appMainboard: AppMotherboard
    @LazyInjected var homeMainboard: HomeMotherboard

    var identifier: String { String(describing: self) }

    var workflowMainboards: [FlowMotherboard] {
        [
            appMainboard, homeMainboard
        ]
    }

    var parser: DeepLinkParsing {
        DeepLinkParser { (deepLink) -> BoardIdentity? in
            switch deepLink {
            case "boardy://login":
                return .login
            case "boardy://dashboard":
                return .dashboard
            default:
                return nil
            }
        }
    }
}
