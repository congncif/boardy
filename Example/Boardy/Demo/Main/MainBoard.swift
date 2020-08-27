//
//  MainBoard.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 8/10/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Boardy
import Foundation

final class MainBoard: RIBBoard, GuaranteedBoard {
    typealias InputType = UserInfo

    private let builder: MainBuildable
    private let motherboard: FlowMotherboard

    init(builder: MainBuildable, motherboard: FlowMotherboard) {
        self.builder = builder
        self.motherboard = motherboard
        super.init(identifier: .main)
    }

    convenience init(builder: MainBuildable, continuousBoards: [ActivatableBoard]) {
        let motherboard = Motherboard(boards: continuousBoards)
        self.init(builder: builder, motherboard: motherboard)
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
        
        rootRouter.viewControllable.uiviewController.present(nav, animated: true)
    }
}

extension MainBoard: MainListener {
    func didLogout() {
        guard let childRouter = rootRouter.children.first(where: { $0 is MainRouting }) as? MainRouting else { return }
        rootRouter.detachChild(childRouter)
        rootRouter.viewControllable.uiviewController.dismiss(animated: true) {
            self.sendToMotherboard()
        }
    }

    func showDashboard() {
        motherboard.activateBoard(identity: .dashboard)
    }
}
