//
//  ContinuousBoardRIBBoard.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 9/12/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Foundation

open class ContinuousRIBBoard: RIBBoard {
    public let motherboard: FlowMotherboard

    public init(identifier: BoardID = UUID().uuidString,
                motherboard: FlowMotherboard = Motherboard()) {
        self.motherboard = motherboard
        super.init(identifier: identifier)

        motherboard.registerGeneralFlow { [weak self] (action: BoardFlowAction) in
            self?.sendFlowAction(action)
        }
    }

    override open func install(into rootViewController: UIViewController) {
        super.install(into: rootViewController)
        motherboard.install(into: rootViewController)
    }
}

open class ContinuousUIRIBBoard: UIRIBBoard {
    public let motherboard: FlowMotherboard

    public init(identifier: BoardID = UUID().uuidString,
                motherboard: FlowMotherboard = Motherboard()) {
        self.motherboard = motherboard
        super.init(identifier: identifier)

        motherboard.registerGeneralFlow { [weak self] (action: BoardFlowAction) in
            self?.sendFlowAction(action)
        }
    }

    override open func install(into rootViewController: UIViewController) {
        super.install(into: rootViewController)
        motherboard.install(into: rootViewController)
    }
}
