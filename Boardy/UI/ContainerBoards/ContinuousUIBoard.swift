//
//  ContinuousUIBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/10/20.
//

import Foundation
import UIKit

open class ContinuousUIBoard: UIBoard {
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
