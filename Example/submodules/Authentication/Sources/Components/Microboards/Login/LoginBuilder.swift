//
//  LoginBuilder.swift
//  AuthenticationPlugins
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import UIKit

struct LoginBuilder: LoginBuildable {
    func build(withDelegate delegate: LoginDelegate?) -> LoginInterface {
        let nibName = String(describing: LoginViewController.self)
        let bundle = Bundle(for: LoginViewController.self)
        let viewController = UIStoryboard(name: nibName, bundle: bundle).instantiateInitialViewController() as! LoginViewController
        viewController.delegate = delegate

        let presenter = LoginPresenter()
        presenter.view = viewController

        let interactor = LoginInteractor(presenter: presenter)
        interactor.delegate = delegate

        viewController.interactor = interactor

        return LoginInterface(userInterface: viewController, controller: interactor)
    }
}
