//
//  Motherboard.swift
//
//
//  Created by NGUYEN CHI CONG on 11/1/19.
//  Copyright © 2019 NGUYEN CHI CONG. All rights reserved.
//

import Foundation
import RIBs
import UIKit

open class Motherboard: Board, MotherboardType, BoardDelegate, FlowManageable {
    public private(set) var boards: [ActivatableBoard]
    public var flows: [BoardFlow] = []

    public init(identifier: String = UUID().uuidString,
                boards: [ActivatableBoard] = []) {
        self.boards = boards
        super.init(identifier: identifier)

        for var board in self.boards {
            board.delegate = self
        }
    }

    public convenience init(identifier: String = UUID().uuidString,
                            boards: [ActivatableBoard] = [],
                            rootViewController: UIViewController) {
        self.init(identifier: identifier, boards: boards)
        self.install(into: rootViewController)
    }

    public convenience init(identifier: String = UUID().uuidString,
                            boards: [ActivatableBoard] = [],
                            rootRouter: ViewableRouting) {
        self.init(identifier: identifier, boards: boards)
        self.install(into: rootRouter)
    }

    open override func install(into rootRouter: ViewableRouting) {
        super.install(into: rootRouter)
        for board in boards {
            board.install(into: rootRouter)
        }
    }

    open override func install(into rootViewController: UIViewController) {
        super.install(into: rootViewController)
        for board in boards {
            board.install(into: router)
        }
    }
}
