//
//  Motherboard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 11/1/19.
//  Copyright © 2019 NGUYEN CHI CONG. All rights reserved.
//

import Foundation
import UIKit

open class Motherboard: Board, MotherboardRepresentable, MotherboardType, BoardDelegate, FlowManageable {
    var mainboard: [BoardID: ActivatableBoard] = [:]

    public var flows: [BoardFlow] = []

    public init(identifier: BoardID = UUID().uuidString,
                boards: [ActivatableBoard] = []) {
        super.init(identifier: identifier)

        for var board in boards {
            self.addBoard(board)
            board.delegate = self
        }
    }

    public convenience init(identifier: BoardID = UUID().uuidString,
                            boards: [ActivatableBoard] = [],
                            rootViewController: UIViewController) {
        self.init(identifier: identifier, boards: boards)
        self.install(into: rootViewController)
    }

    override open func install(into rootViewController: UIViewController) {
        super.install(into: rootViewController)
        for board in boards {
            board.install(into: rootViewController)
        }
    }
}
