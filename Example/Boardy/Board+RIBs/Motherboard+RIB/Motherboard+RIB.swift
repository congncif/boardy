//
//  Motherboard+RIB.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/8/20.
//

import Foundation
import RIBs
import RxSwift

extension Motherboard {
    public convenience init(identifier: String = UUID().uuidString,
                            boards: [ActivatableBoard] = [],
                            rootRouter: ViewableRouting) {
        self.init(identifier: identifier, boards: boards)
        self.install(into: rootRouter)
    }
}

extension MotherboardType {
    public func install(into rootRouter: ViewableRouting) {
        let rootViewController = rootRouter.viewControllable.uiviewController
        self.install(into: rootViewController)
    }
}

extension UIMotherboard {
    public convenience init(identifier: String = UUID().uuidString,
                            uiboards: [UIActivatableBoard] = [],
                            rootRouter: ViewableRouting) {
        self.init(identifier: identifier, uiboards: uiboards)
        self.install(into: rootRouter)
    }
}

extension UIMotherboardType {
    public func install(into rootRouter: ViewableRouting) {
        let rootViewController = rootRouter.viewControllable.uiviewController
        self.install(into: rootViewController)
    }

    public func flashInstall(into rootRouter: ViewableRouting,
                             interface: UIBoardInterface,
                             disposeBag: DisposeBag,
                             activationHandler: ([UIActivatableBoard]) -> Void) {
        self.install(into: rootRouter)
        activationHandler(uiboards)
        plug(in: interface, with: disposeBag)
    }
}
