//
//  EmployeeListInteractor.swift
//  EmployeeManagementPlugins
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import Foundation

protocol EmployeeListPresentable: AnyObject {}

final class EmployeeListInteractor {
    weak var delegate: EmployeeListControlDelegate!

    private let presenter: EmployeeListPresentable

    init(presenter: EmployeeListPresentable) {
        self.presenter = presenter
    }

    // MARK: Private properties
}

// MARK: - As Interactor

extension EmployeeListInteractor: EmployeeListInteractable {
    func didBecomeActive() {
        delegate?.loadData()
    }
}

// MARK: - As Controller

extension EmployeeListInteractor: EmployeeListControllable {}

// MARK: - Private methods

private extension EmployeeListInteractor {}
