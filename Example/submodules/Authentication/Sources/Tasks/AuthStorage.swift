//
//  Task.swift
//  Modular
//
//  Created by BOARDY on 5/31/21.
//

import Authentication
import Boardy

protocol AuthStateUpdater {
    func update(user: User?)
}

protocol AuthStateObservable {
    func addObserver(_ input: CurrentUserInput)
}

final class AuthStateProvider: AuthStateUpdater, AuthStateObservable {
    static let shared = AuthStateProvider()

    func update(user: User?) {
        currentUser = user
    }

    func addObserver(_ input: CurrentUserInput) {
        if let observer = input.observer {
            observer.update(currentUser: currentUser)
            currentUserBus.connect(target: observer) { target, user in
                target.update(currentUser: user)
            }
        }
    }

    private(set) var currentUser: User? {
        didSet {
            currentUserBus.transport(input: currentUser)
        }
    }

    private init() {}
    private let currentUserBus = Bus<User?>()
}
