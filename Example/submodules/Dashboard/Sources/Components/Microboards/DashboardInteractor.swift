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

    deinit {
        print("XXX")
    }
}

// MARK: - As Interactor

extension DashboardInteractor: DashboardInteractable {
    func didBecomeActive() {
        delegate?.loadData(with: self)
    }
}

// MARK: - As Controller

extension DashboardInteractor: DashboardControllable {
    func receive(currentUser: User?) {
        presenter.map(currentUser: currentUser)
    }
}

// MARK: - Private methods

private extension DashboardInteractor {}
