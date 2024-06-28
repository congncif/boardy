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

// Wrap an array to pass LazyInjected convention of Resolver.
struct MainBoardCollection {
    let boards: [ActivatableBoard]
}

final class MainBoard: ContinuousRIBBoard, GuaranteedBoard {
    typealias InputType = UserInfo

    @LazyInjected var builder: MainBuildable
    @LazyInjected var boardCollection: MainBoardCollection

    // To defer initializing sub-boards, use mainboard instead of motherboard (default) for activation related activities.
    private lazy var mainboard: FlowMotherboard = motherboard.extended(boards: boardCollection.boards)

    init(homeBoard: HomeMotherboard) {
        super.init(identifier: .main, motherboard: homeBoard)
    }

    func activate(withGuaranteedInput input: UserInfo) {
        let router = builder.build(withListener: self, userInfo: input)
        rootRouter.attachChild(router)

        let nav = UINavigationController(rootViewController: router.viewControllable.uiviewController)
        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .crossDissolve

        let rootViewController = rootRouter.viewControllable.uiviewController
        if rootViewController.presentedViewController != nil {
            rootViewController.dismiss(animated: false)
        }

        motherboard.registerGeneralFlow(target: self, uniqueOutputType: Any.self) { _, _ in
            print("AAA")
        }

        rootRouter.viewControllable.uiviewController.topPresentedViewController.present(nav, animated: true)
    }

    deinit {
        print("XXX")
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
        mainboard.activateBoard(.dashboard)
    }
}
