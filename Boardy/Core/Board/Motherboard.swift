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
        registerGeneralFlow { [weak self] in
            self?.activateBoard(model: $0)
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

/// A Motherboard is a special board which only accepts a BoardInputModel as input. When this func is called, the motherboard will activate a Board with identifier in list of boards it manages.

extension Motherboard: GuaranteedBoard {
    public typealias InputType = BoardInputModel

    public func activate(withGuaranteedInput input: BoardInputModel) {
        activateBoard(model: input)
    }
}
