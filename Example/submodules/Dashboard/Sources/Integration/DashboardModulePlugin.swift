//
//  DashboardModulePlugin.swift
//  Dashboard
//
//  Created by BOARDY on 6/1/21.
//  Compatible with Boardy 1.54 or later
//

import Boardy
import Dashboard
import Foundation

struct DashboardModulePlugin: ModulePlugin {
    var identifier: Boardy.BoardID {
        service.identifier
    }

    let service: DashboardModulePlugin.ServiceType

    init(service: DashboardModulePlugin.ServiceType) {
        self.service = service
    }

    func apply(for main: MainComponent) {
        let mainProducer = main.producer

        let continuousProducer = BoardProducer(externalProducer: mainProducer, registrationsBuilder: { producer in
            // BoardRegistration
            DashboardBoard(identifier: .modDashboard, builder: DashboardBuilder(), producer: producer)
        })

        switch service {
        case .default:
            mainProducer.registerBoard(service.identifier) { identifier in
                DashboardBoardFactory.make(identifier: identifier, producer: continuousProducer)
            }
        }
    }

    /// Each service is equivalent to one entry point
    enum ServiceType {
        case `default`

        var identifier: BoardID {
            switch self {
            case .default:
                return .pubDashboard
            }
        }
    }
}

public struct DashboardLauncherPlugin: LauncherPlugin {
    public init() { /**/ }

    public func prepareForLaunching(withOptions _: MainOptions) -> ModuleComponent {
        ModuleComponent(
            modulePlugins: [
                DashboardModulePlugin(service: .default),
            ],
            urlOpenerPlugins: []
        )
    }
}
