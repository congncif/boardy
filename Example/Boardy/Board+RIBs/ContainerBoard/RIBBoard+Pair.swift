//
//  ContainerRIBBoard.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 9/12/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import UIKit

extension RIBBoard {
    public func pairUIMotherboard(_ uimotherboard: FlowUIMotherboardObject, with viewController: UIViewController) {
        uimotherboard.registerGeneralFlow { [weak self] in
            self?.sendFlowAction($0)
        }
        uimotherboard.install(into: viewController)
        uimotherboard.pairWith(object: viewController)
    }
}
