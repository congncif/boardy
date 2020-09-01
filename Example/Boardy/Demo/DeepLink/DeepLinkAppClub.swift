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

final class DeepLinkAppClub: DeepLinkHandlerClubbing, Resolving {
    @LazyInjected var appMainboard: AppMotherboard
    @LazyInjected var homeMainboard: HomeMotherboard

    var identifier: String { String(describing: self) }

    var workflowMainboards: [FlowMotherboard] {
        [
            appMainboard, homeMainboard
        ]
    }

    var parser: DeepLinkParsing {
        DeepLinkParser { (deepLink) -> DeepLinkDestination? in
            switch deepLink {
            case "boardy://login":
                return DeepLinkDestination(target: .login)
            case "boardy://dashboard":
                return DeepLinkDestination(target: .dashboard)
            default:
                return nil
            }
        }
    }
}
