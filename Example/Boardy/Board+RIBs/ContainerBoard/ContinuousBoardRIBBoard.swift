//
//  ContinuousBoardRIBBoard.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 9/12/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Foundation
import RIBs
import UIKit

open class ContinuousRIBBoard: RIBBoard {
    public let motherboard: FlowMotherboard

    public init(identifier: BoardID = .random(),
                motherboard: FlowMotherboard = Motherboard()) {
        self.motherboard = motherboard
        super.init(identifier: identifier)

        motherboard.forwardActionFlow(to: self)
    }

    override open func putIntoContext(_ rootObject: AnyObject) {
        super.putIntoContext(rootObject)
        motherboard.putIntoContext(rootObject)
    }
}
