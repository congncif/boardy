//
//  Motherboard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 11/1/19.
//  Copyright © 2019 NGUYEN CHI CONG. All rights reserved.
//

import Foundation
import UIKit

open class Motherboard: Board, MotherboardRepresentable, BoardDelegate, FlowMotherboard {
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

        // Register default flow
        let defaultFlow = BoardActivateFlow(matcher: { _ in true }, nextHandler: { [weak self] data in
            guard let next = data as? BoardInputModel else { return }
            self?.activateBoard(model: next)
        })
        registerFlow(defaultFlow)
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
