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

    override open func installIntoRoot(_ rootObject: AnyObject) {
        super.installIntoRoot(rootObject)
        motherboard.installIntoRoot(rootObject)
    }
}

extension Board {
    /// Create a new UIMotherboard which use internal a board. Chain of action will be set up.
    public func getUIMotherboard(identifier: BoardID = UUID().uuidString, elementBoards: [UIActivatableBoard] = []) -> UIMotherboard {
        let motherboard = UIMotherboard(identifier: identifier, uiboards: elementBoards)
        motherboard.forwardActionFlow(to: self)
        motherboard.forwardActivationFlow(to: self)
        return motherboard
    }
}
