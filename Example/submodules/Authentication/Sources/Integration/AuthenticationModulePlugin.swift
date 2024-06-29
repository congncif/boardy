//
//  AuthenticationModulePlugin.swift
//  Authentication
//
//  Created by BOARDY on 6/1/21.
//  Compatible with Boardy 1.54 or later
//

import Authentication
import Boardy
import Foundation

struct AuthenticationModulePlugin: ModulePlugin {
    var identifier: Boardy.BoardID {
        service.identifier
    }

    let service: AuthenticationModulePlugin.ServiceType

    init(service: AuthenticationModulePlugin.ServiceType) {
        self.service = service
    }

    func apply(for main: MainComponent) {
        let mainProducer = main.producer

        let continuousProducer = BoardProducer(externalProducer: mainProducer, registrationsBuilder: { _ in
            // BoardRegistration
        })

        switch service {
        case .login:
            mainProducer.registerBoard(service.identifier) { identifier in
                LoginBoard(identifier: identifier, builder: LoginBuilder(authStateProvider: AuthStateProvider.shared), producer: continuousProducer)
            }
        case .logout:
            mainProducer.registerBoard(service.identifier) { identifier in
                LogoutBoard(identifier: identifier, producer: continuousProducer, authStateProvider: AuthStateProvider.shared)
            }
        case .currentUser:
            mainProducer.registerBoard(service.identifier) { identifier in
                CurrentUserBoard(identifier: identifier, producer: continuousProducer, authStateProvider: AuthStateProvider.shared)
            }
        }
    }

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

public struct AuthenticationLauncherPlugin: LauncherPlugin {
    public init() { /**/ }

    public func prepareForLaunching(withOptions _: MainOptions) -> ModuleComponent {
        ModuleComponent(
            modulePlugins: [
                AuthenticationModulePlugin(service: .currentUser),
                AuthenticationModulePlugin(service: .login),
                AuthenticationModulePlugin(service: .logout),
            ],
            urlOpenerPlugins: []
        )
    }
}
