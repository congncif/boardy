//
//  EmployeeListBuilder.swift
//  EmployeeManagementPlugins
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import UIKit

struct EmployeeListBuilder: EmployeeListBuildable {
    func build(withDelegate delegate: EmployeeListDelegate?) -> EmployeeListInterface {
        let nibName = String(describing: EmployeeListViewController.self)
        let bundle = Bundle(for: EmployeeListViewController.self)
        let viewController = UIStoryboard(name: nibName, bundle: bundle).instantiateInitialViewController() as! EmployeeListViewController
        viewController.delegate = delegate

        let presenter = EmployeeListPresenter()
        presenter.view = viewController

        let interactor = EmployeeListInteractor(presenter: presenter)
        interactor.delegate = delegate

        viewController.interactor = interactor

        return EmployeeListInterface(userInterface: viewController, controller: interactor)
    }
}
