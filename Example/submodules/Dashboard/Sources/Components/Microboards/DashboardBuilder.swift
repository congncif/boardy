//
//  DashboardBuilder.swift
//  DashboardPlugins
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import UIKit

struct DashboardBuilder: DashboardBuildable {
    func build(withDelegate delegate: DashboardDelegate?) -> DashboardInterface {
        let nibName = String(describing: DashboardViewController.self)
        let bundle = Bundle(for: DashboardViewController.self)
        let viewController = UIStoryboard(name: nibName, bundle: bundle).instantiateInitialViewController() as! DashboardViewController
        viewController.delegate = delegate

        let presenter = DashboardPresenter()
        presenter.view = viewController

        let interactor = DashboardInteractor(presenter: presenter)
        interactor.delegate = delegate

        viewController.interactor = interactor

        return DashboardInterface(userInterface: viewController, controller: interactor)
    }
}
