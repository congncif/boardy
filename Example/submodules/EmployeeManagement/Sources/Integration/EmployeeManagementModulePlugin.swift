//
//  EmployeeManagementModulePlugin.swift
//  EmployeeManagement
//
//  Created by BOARDY on 6/1/21.
//  Compatible with Boardy 1.54 or later
//

import Boardy
import EmployeeManagement
import Foundation

struct EmployeeManagementModulePlugin: ModulePlugin {
    var identifier: Boardy.BoardID {
        service.identifier
    }

    let service: EmployeeManagementModulePlugin.ServiceType

    init(service: EmployeeManagementModulePlugin.ServiceType) {
        self.service = service
    }

    func apply(for main: MainComponent) {
        let mainProducer = main.producer

        let continuousProducer = BoardProducer(externalProducer: mainProducer, registrationsBuilder: { producer in
            // BoardRegistration
            BoardRegistration(.modEmployeeList) { identifier in
                EmployeeListBoard(identifier: identifier, builder: EmployeeListBuilder(), producer: producer)
            }
        })

        switch service {
        case .default:
            mainProducer.registerBoard(service.identifier) { identifier in
                EmployeeManagementBoardFactory.make(identifier: identifier, producer: continuousProducer)
            }
        }
    }

    /// Each service is equivalent to one entry point
    enum ServiceType {
        case `default`

        var identifier: BoardID {
            switch self {
            case .default:
                return .pubEmployeeManagement
            }
        }
    }
}

public struct EmployeeManagementLauncherPlugin: LauncherPlugin {
    public init() { /**/ }

    public func prepareForLaunching(withOptions _: MainOptions) -> ModuleComponent {
        ModuleComponent(
            modulePlugins: [
                EmployeeManagementModulePlugin(service: .default),
            ],
            urlOpenerPlugins: []
        )
    }
}
