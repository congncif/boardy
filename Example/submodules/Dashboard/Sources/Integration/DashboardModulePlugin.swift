//
//  DashboardModulePlugin.swift
//  DashboardPlugins
//
//  Created by NGUYEN CHI CONG on 22/8/24.
//  Compatible with Boardy 1.56 or later
//

import Boardy
import Dashboard
import Foundation

struct DashboardModulePlugin: ModuleBuilderPlugin {
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

    func build(with identifier: Boardy.BoardID, sharedComponent _: any Boardy.SharedValueComponent, internalContinuousProducer: any Boardy.ActivatableBoardProducer) -> any Boardy.ActivatableBoard {
        DashboardBoard(identifier: identifier, builder: DashboardBuilder(), producer: internalContinuousProducer)
    }

    func internalContinuousRegistrations(producer _: any Boardy.ActivatableBoardProducer) -> [Boardy.BoardRegistration] {}

    let service: DashboardModulePlugin.ServiceType

    var identifier: BoardID {
        service.identifier
    }
}

struct DashboardURLOpenerPlugin: GuaranteedURLOpenerPlugin {
    typealias Parameter = Void

    func willOpen(url _: URL) -> URLOpeningOption<Parameter> {
        // return .yes if need to process a deep link
        .no
    }

    func mainboard(_: any FlowMotherboard, openWith _: Parameter) {
        // Activate corresponding board here
    }
}

public struct DashboardLauncherPlugin: LauncherPlugin {
    public init() { /**/ }

    public func prepareForLaunching(withOptions _: MainOptions) -> ModuleComponent {
        ModuleComponent(
            modulePlugins: [
                DashboardModulePlugin(service: .default),
            ],
            urlOpenerPlugins: [
                DashboardURLOpenerPlugin(),
            ]
        )
    }
}
