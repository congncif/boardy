//
//  ServiceRegistry.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 8/10/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Boardy
import Foundation
import Resolver

struct ServiceRegistry: Resolving {
    func registerAllServices() {
        resolver.register { LoginBuilder() }.implements(LoginBuildable.self)
        resolver.register { MainBuilder() }.implements(MainBuildable.self)
        resolver.register { DashboardBuilder() }.implements(DashboardBuildable.self)
        resolver.register { HeadlineBuilder() }.implements(HeadlineBuildable.self)
        resolver.register { FeaturedBuilder() }.implements(FeaturedBuildable.self)
        resolver.register { RootBuilder() }.implements(RootBuildable.self)

        resolver.register { LoginBoard() }
//        resolver.register { HeadlineUIBoard() }
//        resolver.register { FeaturedUIBoard() }
        resolver.register { DashboardBoard() }
        resolver.register { MainBoard(homeBoard: $0.resolve()) }

        resolver.register { RootBoard(motherboard: $0.resolve()) }

        resolver.register { AppMainboard(boardProducer: BoardProducer()) }.implements(AppMotherboard.self)

        resolver.register { HomeMainboard() }.implements(HomeMotherboard.self)

        resolver.register { rsv -> MainBoardCollection in
            let dashboard: DashboardBoard = rsv.resolve()
            return MainBoardCollection(boards: [dashboard])
        }

        resolver.register {
            DeepLinkHandler(handlerClub: DeepLinkAppClub())
        }
        .scope(ResolverScopeApplication())
        .implements(DeepLinkHandlingComposable.self)
        .implements(DeepLinkHandling.self)

        resolver.register { rsv -> DeepLinkBoardCollection in
            let login: LoginBoard = rsv.resolve()
            let main: MainBoard = rsv.resolve()
            let dashboard: DashboardBoard = rsv.resolve()
            return DeepLinkBoardCollection(boards: [login, main, dashboard])
        }

//        resolver.register { DashboardElementFactory() }
//            .implements(DashboardElementManufacturing.self)
    }
}
