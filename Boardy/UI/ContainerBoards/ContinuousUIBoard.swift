//
//  ContinuousUIBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/10/20.
//

import Foundation

open class ContinuousUIBoard<OptionType>: UIViewControllerBoard<OptionType> {
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
