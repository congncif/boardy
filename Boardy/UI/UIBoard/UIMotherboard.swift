//
//  UIMotherboard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation
import UIKit

open class UIMotherboard: Board, UIMotherboardType, BoardDelegate, FlowManageable {
    public private(set) var uiboards: [UIActivatableBoard]
    public var flows: [BoardFlow] = []

    public init(identifier: BoardID = UUID().uuidString,
                uiboards: [UIActivatableBoard] = []) {
        self.uiboards = uiboards
        super.init(identifier: identifier)

        for var board in uiboards {
            board.delegate = self
        }
    }

    public convenience init(identifier: BoardID = UUID().uuidString,
                            uiboards: [UIActivatableBoard] = [],
                            rootViewController: UIViewController) {
        self.init(identifier: identifier, uiboards: uiboards)
        self.install(into: rootViewController)
    }

    override open func install(into rootViewController: UIViewController) {
        super.install(into: rootViewController)
        for board in uiboards {
            board.install(into: rootViewController)
        }
    }
}
