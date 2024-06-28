//
//  DashboardInteractor.swift
//  DashboardPlugins
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import Authentication
import Foundation

protocol DashboardPresentable: AnyObject {
    func map(currentUser: User?)
}

final class DashboardInteractor {
    weak var delegate: DashboardControlDelegate!

    private let presenter: DashboardPresentable

    init(presenter: DashboardPresentable) {
        self.presenter = presenter
    }

    // MARK: Private properties
}

// MARK: - As Interactor

extension DashboardInteractor: DashboardInteractable {
    func didBecomeActive() {
        delegate?.loadData()
    }
}

// MARK: - As Controller

extension DashboardInteractor: DashboardControllable {
    func updateCurrentUser(_ user: User?) {
        presenter.map(currentUser: user)
    }
}

// MARK: - Private methods

private extension DashboardInteractor {}
