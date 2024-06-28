//
//  DashboardViewController.swift
//  DashboardPlugins
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import UIKit

/// Use for interacting with data before sending messages to outside
protocol DashboardInteractable {
    func didBecomeActive()
}

final class DashboardViewController: UIViewController, DashboardUserInterface {
    // MARK: Dependencies

    weak var delegate: DashboardActionDelegate!

    var interactor: DashboardInteractable!

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        interactor.didBecomeActive()
    }

    // MARK: Private computed & temporary properties

    // MARK: IBOutlets / IBActions

    @IBOutlet private var welcomeLabel: UILabel!
    @IBOutlet private var loginButton: UIButton!
    @IBOutlet private var contentScrollView: UIScrollView!

    @IBAction private func loginButtonTapped() {
        if contentScrollView.isHidden {
            delegate.openLogin()
        } else {
            delegate.doLogout()
        }
    }

    @IBAction private func employeeManagementButtonTapped() {
        delegate.openEmployeeManagement()
    }
}

// MARK: - Behaviors

extension DashboardViewController: DashboardViewable {
    func bind(welcome: WelcomeViewModel) {
        welcomeLabel.text = welcome.greetings
        loginButton.setTitle(welcome.authAction, for: .normal)
        contentScrollView.isHidden = !welcome.isContentAvailable
    }
}

// MARK: - Private methods

private extension DashboardViewController {
    func setupView() {}
}
