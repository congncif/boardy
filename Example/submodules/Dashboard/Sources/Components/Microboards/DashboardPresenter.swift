//
//  DashboardPresenter.swift
//  DashboardPlugins
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import Authentication
import Foundation

protocol DashboardViewable: AnyObject {
    func bind(welcome: WelcomeViewModel)
}

final class DashboardPresenter: DashboardPresentable {
    func map(currentUser: Authentication.User?) {
        let viewModel: WelcomeViewModel
        if let currentUser {
            viewModel = WelcomeViewModel(
                greetings: "Hello, \(currentUser.username)",
                authAction: "Logout",
                isContentAvailable: true
            )
        } else {
            viewModel = WelcomeViewModel(
                greetings: "Not logged in yet",
                authAction: "Login",
                isContentAvailable: false
            )
        }

        DispatchQueue.main.async { [weak view] in
            view?.bind(welcome: viewModel)
        }
    }

    weak var view: DashboardViewable!

    // MARK: Private properties
}

// MARK: - Private methods

private extension DashboardPresenter {}

// MARK: - View Model

struct WelcomeViewModel {
    let greetings: String
    let authAction: String
    let isContentAvailable: Bool
}
