//
//  ContainerRIBBoard.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 9/12/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import RIBs
import RxSwift
import UIKit

// MARK: - RIBBoard + Extensions

extension RIBBoard {
    public func pairInstallUIMotherboard(_ uimotherboard: FlowUIMotherboardObject, with router: ViewableRouting) {
        uimotherboard.registerGeneralFlow { [weak self] in
            self?.sendFlowAction($0)
        }
        uimotherboard.install(into: router)
        uimotherboard.pairWith(object: router.viewControllable.uiviewController)
    }
}
