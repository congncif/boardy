//
//  AuthenticationModulePlugin.swift
//  Authentication
//
//  Created by BOARDY on 6/1/21.
//  Compatible with Boardy 1.56 or later
//

import Authentication
import Boardy
import Foundation

struct AuthenticationModulePlugin: ModuleBuilderPlugin {
    func build(with identifier: Boardy.BoardID, sharedComponent _: any Boardy.SharedValueComponent, internalContinuousProducer: any Boardy.ActivatableBoardProducer) -> any Boardy.ActivatableBoard {
        let stateProvider = AuthStateProvider.shared
        return switch service {
        case .login:
            LoginBoard(identifier: identifier,
                       builder: LoginBuilder(authStateProvider: stateProvider),
                       producer: internalContinuousProducer)
        case .currentUser:
            CurrentUserBoard(identifier: identifier, producer: internalContinuousProducer, authStateProvider: stateProvider)
        case .logout:
            LogoutBoard(identifier: identifier, producer: internalContinuousProducer, authStateProvider: stateProvider)
        }
    }

    func internalContinuousRegistrations(producer _: any Boardy.ActivatableBoardProducer) -> [Boardy.BoardRegistration] {}

    var identifier: Boardy.BoardID {
        service.identifier
    }

    let service: AuthenticationModulePlugin.ServiceType

    /// Each service is equivalent to one entry point
    enum ServiceType {
        case login
        case currentUser
        case logout

        var identifier: BoardID {
            switch self {
            case .currentUser:
                return .pubCurrentUser
            case .login:
                return .pubLogin
            case .logout:
                return .pubLogout
            }
        }
    }
}

struct AuthenticationURLOpenerPlugin: GuaranteedURLOpenerPlugin {
    typealias Parameter = Void

    func willOpen(url _: URL) -> URLOpeningOption<Parameter> {
        // return .yes if need to process a deep link
        .no
    }

    func mainboard(_: any FlowMotherboard, openWith _: Parameter) {
        // Activate corresponding board here
    }
}

public struct AuthenticationLauncherPlugin: LauncherPlugin {
    public init() { /**/ }

    public func prepareForLaunching(withOptions _: MainOptions) -> ModuleComponent {
        ModuleComponent(
            modulePlugins: [
                AuthenticationModulePlugin(service: .currentUser),
                AuthenticationModulePlugin(service: .login),
                AuthenticationModulePlugin(service: .logout),
            ],
            urlOpenerPlugins: [
                AuthenticationURLOpenerPlugin(),
            ]
        )
    }
}
