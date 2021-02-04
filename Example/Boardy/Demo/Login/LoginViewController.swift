//
//  LoginViewController.swift
//  SuperProject
//
//  Created by NGUYEN CHI CONG on 2/9/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import UIKit
import ViewStateCore

final class LoginViewController: UIViewController, LoginController {
    // MARK: Dependencies

    weak var delegate: LoginDelegate?

    lazy var state: LoginViewState = LoginViewState()

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        state.register(subscriberObject: self)

        usernameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        usernameField.text = "username"
        passwordField.text = "pwd"
        
        usernameField.sendActions(for: .editingChanged)
        passwordField.sendActions(for: .editingChanged)
    }

    // MARK: Privates

    @IBOutlet private var usernameField: UITextField!
    @IBOutlet private var passwordField: UITextField!
    @IBOutlet private var loginButton: UIButton!

    @IBAction private func loginButtonDidTap() {
        login()
    }

    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        switch textField {
        case usernameField:
            state.username = usernameField.text!
        case passwordField:
            state.password = passwordField.text!
        default:
            break
        }
    }
}

// MARK: - Behaviors

extension LoginViewController {
    func login() {
        // Perform login here
        delegate?.didLogin(userInfo: state.userInfo)
    }
}

// MARK: - ViewState

extension LoginViewController: DedicatedViewStateRenderable {
    func dedicatedRender(state: LoginViewState) {
        loginButton.isEnabled = !state.username.isEmpty && !state.password.isEmpty
    }
}
