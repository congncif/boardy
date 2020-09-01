//
//  MainBuilder.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 8/10/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import RIBs

protocol MainDependency: Dependency {}

final class MainComponent: Component<MainDependency> {}

final class MainRootComponent: MainDependency {}

// MARK: - Builder

protocol MainBuildable: Buildable {
    func build(withListener listener: MainListener, userInfo: UserInfo) -> MainRouting
}

final class MainBuilder: Builder<MainDependency>, MainBuildable {

    override init(dependency: MainDependency = MainRootComponent()) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: MainListener, userInfo: UserInfo) -> MainRouting {
        let bundle = Bundle(for: MainViewController.self)
        let storyboard = UIStoryboard(name: MainViewController.typeName, bundle: bundle)
        guard let viewController = storyboard.instantiateInitialViewController() as? MainViewController else {
            preconditionFailure("Cannot init MainViewController")
        }

        let interactor = MainInteractor(presenter: viewController, userInfo: userInfo)
        interactor.listener = listener
        return MainRouter(interactor: interactor, viewController: viewController)
    }
}
