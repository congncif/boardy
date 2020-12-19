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

    public init(identifier: BoardID = UUID().uuidString,
                boards: [ActivatableBoard] = []) {
        boardProducer = NoBoardProducer()
        super.init(identifier: identifier)

        for board in boards {
            addBoard(board)
        }

        registerDefaultFlows()
    }

    public init(identifier: BoardID = UUID().uuidString,
                boardProducer: ActivableBoardProducer) {
        self.boardProducer = boardProducer
        super.init(identifier: identifier)
        registerDefaultFlows()
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

    // MARK: - MotherboardRepresentable

    var mainboard: [ActivatableBoard] = [] {
        didSet {
            for var board in boards {
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

// MARK: - NoBoard

public final class NoBoard: Board, ActivatableBoard {
    private let handler: ((Any?) -> Void)?

    public init(identifier: BoardID = UUID().uuidString, handler: ((Any?) -> Void)? = nil) {
        self.handler = handler
        super.init(identifier: identifier)
    }

    public func activate(withOption option: Any?) {
        let alert = UIAlertController(title: "Feature is coming", message: "Board with identifier \(identifier) was not installed", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: .cancel, handler: { [weak self] _ in
            self?.handler?(option)
        }))
        rootViewController.present(alert, animated: true)
    }
}

final class NoBoardProducer: ActivableBoardProducer {
    func produceBoard(identifier: BoardID) -> ActivatableBoard? {
        NoBoard(identifier: identifier)
    }
}
