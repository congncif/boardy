//
//  Motherboard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 11/1/19.
//  Copyright © 2019 NGUYEN CHI CONG. All rights reserved.
//

import Foundation
import UIKit

open class Motherboard: Board, MotherboardRepresentable, BoardDelegate, FlowManageable {
    var mainboard: [BoardID: ActivatableBoard] = [:] {
        didSet {
            for var board in boards {
                board.delegate = self
            }
        }
    }

    public var flows: [BoardFlow] = []

    public init(identifier: BoardID = UUID().uuidString,
                boards: [ActivatableBoard] = []) {
        super.init(identifier: identifier)

        for board in boards {
            addBoard(board)
        }
    }

    public convenience init(identifier: BoardID = UUID().uuidString,
                            boards: [ActivatableBoard] = [],
                            rootViewController: UIViewController) {
        self.init(identifier: identifier, boards: boards)
        install(into: rootViewController)
    }

    override open func install(into rootViewController: UIViewController) {
        super.install(into: rootViewController)
        for board in boards {
            board.install(into: rootViewController)
        }
    }
}
