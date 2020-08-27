//
//  ServiceRegistry.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 8/10/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Boardy
import Foundation
import Resolver

struct ServiceRegistry: Resolving {
    func registerAllServices() {
        resolver.register { LoginBuilder() }.implements(LoginBuildable.self)
        resolver.register { MainBuilder() }.implements(MainBuildable.self)
            .scope(ResolverScopeCache())
        resolver.register { DashboardBuilder() }.implements(DashboardBuildable.self)

        resolver.register { rsv -> Motherboard in
            let login = LoginBoard(builder: rsv.resolve())
            let dashboard = DashboardBoard(builder: rsv.resolve())

            let main = MainBoard(builder: rsv.resolve(), continuousBoards: [
                dashboard
            ])
            
            return Motherboard(boards: [
                login, main
            ])
        }
    }
}
