//
//  LoginInteractor.swift
//  AuthenticationPlugins
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import Authentication
import Foundation

protocol LoginPresentable: AnyObject {}

final class LoginInteractor {
    weak var delegate: LoginControlDelegate!

    private let presenter: LoginPresentable
    private let authStateProvider: AuthStateUpdater

    init(presenter: LoginPresentable, authStateProvider: AuthStateUpdater) {
        self.presenter = presenter
        self.authStateProvider = authStateProvider
    }

    // MARK: Private properties
}

// MARK: - As Interactor

extension LoginInteractor: LoginInteractable {
    func didBecomeActive() {
        delegate?.loadData()
    }

    func login(username: String, password _: String) {
        guard !username.isEmpty else {
            return
        }
        let user = User(username: username)

        authStateProvider.update(user: user)

        delegate.userDidLogin(user)
    }
}

// MARK: - As Controller

extension LoginInteractor: LoginControllable {}

// MARK: - Private methods

private extension LoginInteractor {}
