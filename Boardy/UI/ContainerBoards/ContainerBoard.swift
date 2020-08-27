//
//  ContainerBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/27/20.
//

import Foundation

// A ContainerBoard contains an internal sub-uimotherboard by default.
open class ContainerBoard: Board {
    public let uimotherboard: FlowUIMotherboard

    public init(identifier: BoardID = UUID().uuidString,
                uimotherboard: FlowUIMotherboard = UIMotherboard()) {
        self.uimotherboard = uimotherboard
        super.init(identifier: identifier)
    }

    override public func install(into rootViewController: UIViewController) {
        super.install(into: rootViewController)
        uimotherboard.install(into: rootViewController)
    }
}
