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
    var currentUser: User? { get }

    func addObserver(_ observer: CurrentUserInput)
}

final class AuthStateProvider: AuthStateUpdater, AuthStateObservable {
    static let shared = AuthStateProvider()

    func update(user: User?) {
        currentUser = user
    }

    func addObserver(_ observer: CurrentUserInput) {
        currentUserBus.connect(observer)
    }

    private(set) var currentUser: User? {
        didSet {
            currentUserBus.transport(input: currentUser)
        }
    }

    private init() {}
    private let currentUserBus = Bus<User?>()
}
