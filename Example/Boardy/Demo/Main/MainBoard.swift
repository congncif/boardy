//
//  MainBoard.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 8/10/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Boardy
import Foundation
import Resolver

final class MainBoard: RIBBoard, GuaranteedBoard {
    typealias InputType = UserInfo

    @LazyInjected var builder: MainBuildable
    @LazyInjected var motherboard: HomeMotherboard

    init() {
        super.init(identifier: .main)

        motherboard.registerGeneralFlow { [weak self] in
            self?.sendAction($0)
        }
    }

    override func install(into rootViewController: UIViewController) {
        super.install(into: rootViewController)
        motherboard.install(into: rootViewController)
    }

    func activate(withGuaranteedInput input: UserInfo) {
        let router = builder.build(withListener: self, userInfo: input)
        rootRouter.attachChild(router)

        let nav = UINavigationController(rootViewController: router.viewControllable.uiviewController)
        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .crossDissolve
        rootRouter.viewControllable.uiviewController.present(nav, animated: true)
    }
}

extension MainBoard: MainListener {
    func didLogout() {
        guard let childRouter = rootRouter.children.first(where: { $0 is MainRouting }) as? MainRouting else { return }
        rootRouter.detachChild(childRouter)
        rootRouter.viewControllable.uiviewController.dismiss(animated: true) {
            self.nextToBoard(.login)
        }
    }

    func showDashboard() {
        motherboard.activateBoard(.dashboard)
    }
}
