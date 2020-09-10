//
//  ContainerUIBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/10/20.
//

import Foundation

open class ContainerUIBoard<OptionType>: UIViewControllerBoard<OptionType> {
    public let uimotherboard: FlowUIMotherboard

    public init(identifier: BoardID = UUID().uuidString,
                uimotherboard: FlowUIMotherboard = UIMotherboard()) {
        self.uimotherboard = uimotherboard
        super.init(identifier: identifier)

        uimotherboard.registerGeneralFlow { [weak self] (action: BoardFlowAction) in
            self?.sendFlowAction(action)
        }
    }

    override open func install(into rootViewController: UIViewController) {
        super.install(into: rootViewController)
        uimotherboard.install(into: rootViewController)
    }
}
