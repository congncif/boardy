//
//  ContinuousBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/27/20.
//

import Foundation

/// A ContinuousBoard contains an internal sub-motherboard by default.
open class ContinuousBoard: Board {
    public let motherboard: FlowMotherboard

    public init(identifier: BoardID = UUID().uuidString,
                motherboard: FlowMotherboard = Motherboard()) {
        self.motherboard = motherboard
        super.init(identifier: identifier)
    }

    override open func install(into rootViewController: UIViewController) {
        super.install(into: rootViewController)
        motherboard.install(into: rootViewController)
    }
}
