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

    init(builder: MainBuildable) {
        self.builder = builder
        super.init(identifier: .main)
    }

    func activate(withGuaranteedInput input: UserInfo) {
        let router = builder.build(withListener: self, userInfo: input)
        rootRouter.attachChild(router)
        router.viewControllable.uiviewController.modalPresentationStyle = .fullScreen
        rootRouter.viewControllable.uiviewController.present(router.viewControllable.uiviewController, animated: true)
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
}
