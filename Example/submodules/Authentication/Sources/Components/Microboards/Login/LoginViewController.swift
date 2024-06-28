//
//  LoginViewController.swift
//  AuthenticationPlugins
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import UIKit

/// Use for interacting with data before sending messages to outside
protocol LoginInteractable {
    func didBecomeActive()

    func login(username: String, password: String)
}

final class LoginViewController: UIViewController, LoginUserInterface {
    // MARK: Dependencies

    weak var delegate: LoginActionDelegate!

    var interactor: LoginInteractable!

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        interactor.didBecomeActive()
    }

    // MARK: Private computed & temporary properties

    // MARK: IBOutlets / IBActions

    @IBOutlet private var usernameTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!

    @IBAction private func loginButtonTapped() {
        let username = usernameTextField.text!
        let password = passwordTextField.text!

        interactor.login(username: username, password: password)
    }
}

// MARK: - Behaviors

extension LoginViewController: LoginViewable {}

// MARK: - Private methods

private extension LoginViewController {
    func setupView() {}
}
