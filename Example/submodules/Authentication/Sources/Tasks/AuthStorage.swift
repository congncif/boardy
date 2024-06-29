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
    func addObserver<Observer>(_ observer: Observer, handler: @escaping (Observer, User?) -> Void)
}

final class AuthStateProvider: AuthStateUpdater, AuthStateObservable {
    static let shared = AuthStateProvider()

    func update(user: User?) {
        currentUser = user
    }

    func addObserver<Observer>(_ observer: Observer, handler: @escaping (Observer, User?) -> Void) {
        handler(observer, currentUser)
        currentUserBus.connect(target: observer, handler: handler)
    }

    private(set) var currentUser: User? {
        didSet {
            currentUserBus.transport(input: currentUser)
        }
    }

    private init() {}
    private let currentUserBus = Bus<User?>()
}
