//
//  AppMainboard.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 9/1/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Boardy
import Foundation

protocol AppMotherboard: FlowMotherboard {}

final class AppMainboard: Motherboard, AppMotherboard {
    init(boardProducer: ActivableBoardProducer) {
        super.init(boardProducer: boardProducer)
//        registerFlowSteps(.login >=> .main >=> .login)

        registerGeneralFlow { [weak self] (action: BoardAction) in
            switch action {
            case .return:
                self?.rootViewController.returnHere()
            }
        }
    }
}
