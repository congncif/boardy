//
//  EmployeeManagementModulePlugin.swift
//  EmployeeManagementPlugins
//
//  Created by NGUYEN CHI CONG on 22/8/24.
//  Compatible with Boardy 1.56 or later
//

import Boardy
import EmployeeManagement
import Foundation

struct EmployeeManagementModulePlugin: ModuleBuilderPlugin {
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

    func build(with identifier: Boardy.BoardID, sharedComponent _: any Boardy.SharedValueComponent, internalContinuousProducer: any Boardy.ActivatableBoardProducer) -> any Boardy.ActivatableBoard {
        EmployeeManagementBoardFactory.make(identifier: identifier, producer: internalContinuousProducer)
    }

    func internalContinuousRegistrations(producer: any Boardy.ActivatableBoardProducer) -> [Boardy.BoardRegistration] {
        BoardRegistration(.modEmployeeList) { identifier in
            EmployeeListBoard(identifier: identifier, builder: EmployeeListBuilder(), producer: producer)
        }
    }

    let service: EmployeeManagementModulePlugin.ServiceType

    var identifier: BoardID {
        service.identifier
    }
}

struct EmployeeManagementURLOpenerPlugin: GuaranteedURLOpenerPlugin {
    typealias Parameter = Void

    func willOpen(url _: URL) -> URLOpeningOption<Parameter> {
        // return .yes if need to process a deep link
        .no
    }

    func mainboard(_: any FlowMotherboard, openWith _: Parameter) {
        // Activate corresponding board here
    }
}

public struct EmployeeManagementLauncherPlugin: LauncherPlugin {
    public init() { /**/ }

    public func prepareForLaunching(withOptions _: MainOptions) -> ModuleComponent {
        ModuleComponent(
            modulePlugins: [
                EmployeeManagementModulePlugin(service: .default),
            ],
            urlOpenerPlugins: [
                EmployeeManagementURLOpenerPlugin(),
            ]
        )
    }
}
