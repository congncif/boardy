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

    override public var debugDescription: String {
        let superDesc = super.debugDescription
        return superDesc + "\n" + """
            ● [Children] ➤ \(String(describing: boards.map { $0.identifier }))
            ● [Flows] ➤ \(String(describing: flows.count))
            ● [Producer] ➤ \(String(describing: boardProducer))
        """
    }

    public init(identifier: BoardID = .random(),
                boards: [ActivatableBoard] = []) {
        boardProducer = NoBoardProducer()
        super.init(identifier: identifier)

        for board in boards {
            addBoard(board)
        }

        registerDefaultFlows()
    }

    public init(identifier: BoardID = .random(),
                boardProducer: ActivableBoardProducer) {
        self.boardProducer = boardProducer
        super.init(identifier: identifier)
        registerDefaultFlows()
    }

    public convenience init(identifier: BoardID = .random(), boardProducer: ActivableBoardProducer, boards: [ActivatableBoard]) {
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

    override open func putIntoContext(_ context: AnyObject) {
        super.putIntoContext(context)
        for board in boards {
            board.putIntoContext(context)
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
                if board.context == nil, let root = context {
                    board.putIntoContext(root)
                }
            }
        }
    }

    // MARK: - LazyMotherboard

    public private(set) var boardProducer: ActivableBoardProducer
}

/// A Motherboard is a special board which only accepts a BoardInputModel as input. When activate func is called, the motherboard will activate a Board with identifier in list of boards it manages.

extension Motherboard: GuaranteedBoard {
    public typealias InputType = BoardInputModel

    open func activate(withGuaranteedInput input: BoardInputModel) {
        activateBoard(model: input)
    }
}
