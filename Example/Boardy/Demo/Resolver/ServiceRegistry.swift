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

        resolver.register { LoginBoard() }
        resolver.register { HeadlineUIBoard() }
        resolver.register { FeaturedUIBoard() }
        resolver.register { DashboardBoard() }
        resolver.register { MainBoard() }

        resolver.register { rsv -> AppMainboard in
            let login: LoginBoard = rsv.resolve()
            let main: MainBoard = rsv.resolve()

            return AppMainboard(boards: [
                login, main
            ])
        }
        .scope(ResolverScopeCache())
        .implements(AppMotherboard.self)

        resolver.register { rsv -> HomeMainboard in
            let dashboard: DashboardBoard = rsv.resolve()

            return HomeMainboard(boards: [
                dashboard
            ])
        }
        .scope(ResolverScopeCache())
        .implements(HomeMotherboard.self)

        resolver.register {
            DeepLinkHandler(handlerClub: DeepLinkAppClub())
        }
        .scope(ResolverScopeApplication())
        .implements(DeepLinkHandlingComposable.self)
        .implements(DeepLinkHandling.self)
    }
}
