//
//  Motherboard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 11/1/19.
//  Copyright © 2019 NGUYEN CHI CONG. All rights reserved.
//

import Foundation
import UIKit

open class Motherboard: Board, MotherboardRepresentable, BoardDelegate, FlowMotherboard, LazyMotherboard {
    public var flows: [BoardFlow] = []

    public init(identifier: BoardID = .randomUnique(),
                boards: [ActivatableBoard] = []) {
        boardProducer = NoBoardProducer()
        super.init(identifier: identifier)

        for board in boards {
            addBoard(board)
        }

        registerDefaultFlows()
    }

    public init(identifier: BoardID = .randomUnique(),
                boardProducer: ActivableBoardProducer) {
        self.boardProducer = boardProducer
        super.init(identifier: identifier)
        registerDefaultFlows()
    }

    public convenience init(identifier: BoardID = .randomUnique(), boardProducer: ActivableBoardProducer, boards: [ActivatableBoard]) {
        self.init(identifier: identifier, boardProducer: boardProducer)
        for board in boards {
            addBoard(board)
        }
    }

    func registerDefaultFlows() {
        // Forward action through chain
        forwardActionFlow(to: self)

        // Register Interaction flow
        registerGeneralFlow { [weak self] in
            self?.interactWithBoard(command: $0)
        }

        // Register activation flow
        registerGeneralFlow { [weak self] in
            self?.activateBoard(model: $0)
        }

        // Register complete flow
        registerGeneralFlow { [weak self] (action: CompleteAction) in
            self?.removeBoard(withIdentifier: action.identifier)
        }
    }

    override open func installIntoRoot(_ rootObject: AnyObject) {
        super.installIntoRoot(rootObject)
        for board in boards {
            board.installIntoRoot(rootObject)
        }
    }

    @discardableResult
    public func registerFlow(_ flow: BoardFlow) -> Self {
        flows.append(flow)
        return self
    }

    public func resetFlows() {
        flows = []
        registerDefaultFlows()
    }

    // MARK: - MotherboardRepresentable

    var mainboard: [ActivatableBoard] = [] {
        didSet {
            for board in boards {
                board.delegate = self
                if board.root == nil, let root = self.root {
                    board.installIntoRoot(root)
                }
            }
        }
    }

    // MARK: - LazyMotherboard

    var boardProducer: ActivableBoardProducer
}

/// A Motherboard is a special board which only accepts a BoardInputModel as input. When activate func is called, the motherboard will activate a Board with identifier in list of boards it manages.

extension Motherboard: GuaranteedBoard {
    public typealias InputType = BoardInputModel

    open func activate(withGuaranteedInput input: BoardInputModel) {
        activateBoard(model: input)
    }
}
