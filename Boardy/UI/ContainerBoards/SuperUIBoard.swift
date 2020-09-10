//
//  SuperUIBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/10/20.
//

import Foundation

open class SuperUIBoard<OptionType>: ContinuousUIBoard<OptionType> {
    public let uimotherboard: FlowUIMotherboard

    public init(identifier: BoardID = UUID().uuidString,
                motherboard: FlowMotherboard = Motherboard(),
                uimotherboard: FlowUIMotherboard = UIMotherboard()) {
        self.uimotherboard = uimotherboard
        super.init(identifier: identifier, motherboard: motherboard)

        motherboard.registerGeneralFlow { [weak self] (action: BoardFlowAction) in
            self?.sendFlowAction(action)
        }

        uimotherboard.registerGeneralFlow { [weak self] (action: BoardFlowAction) in
            self?.sendFlowAction(action)
        }
    }

    override open func install(into rootViewController: UIViewController) {
        super.install(into: rootViewController)
        uimotherboard.install(into: rootViewController)
    }
}
