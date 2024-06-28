//
//  EmployeeListViewController.swift
//  EmployeeManagementPlugins
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import UIKit

/// Use for interacting with data before sending messages to outside
protocol EmployeeListInteractable {
    func didBecomeActive()
}

final class EmployeeListViewController: UIViewController, EmployeeListUserInterface {
    // MARK: Dependencies

    weak var delegate: EmployeeListActionDelegate!

    var interactor: EmployeeListInteractable!

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        interactor.didBecomeActive()
    }

    // MARK: Private computed & temporary properties

    // MARK: IBOutlets / IBActions
}

// MARK: - Behaviors

extension EmployeeListViewController: EmployeeListViewable {}

// MARK: - Private methods

private extension EmployeeListViewController {
    func setupView() {}
}
