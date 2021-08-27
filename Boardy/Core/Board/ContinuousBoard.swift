//
//  ContinuousBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/27/20.
//

import Foundation
import UIKit

public protocol ContinuableBoard: IdentifiableBoard, OriginalBoard {
    var motherboard: FlowMotherboard { get }
}

extension ContinuableBoard {
    public func continueBoard<Input>(_ input: BoardInput<Input>) {
        motherboard.activateBoard(input)
    }

    public func continueBoard(model: BoardInputModel) {
        motherboard.activateBoard(model: model)
    }

    public func continueInteractWithBoard<Input>(_ input: BoardCommand<Input>) {
        motherboard.interactWithBoard(input)
    }

    public func continueInteractWithBoard(command: BoardCommandModel) {
        motherboard.interactWithBoard(command: command)
    }
}

// MARK: - ModernContinuableBoard

open class ModernContinuableBoard: Board, ContinuableBoard {
    public var motherboard: FlowMotherboard { internalMainboard }

    public let producer: ActivableBoardProducer

    public init(identifier: BoardID,
                boardProducer: ActivableBoardProducer) {
        self.producer = boardProducer
        super.init(identifier: identifier)
    }

    private lazy var internalMainboard: FlowMotherboard = produceContinuousMotherboard()

    override open func installIntoRoot(_ rootObject: AnyObject) {
        super.installIntoRoot(rootObject)
        motherboard.installIntoRoot(rootObject)
    }

    func produceContinuousMotherboard() -> FlowMotherboard {
        producer.produceContinuousMotherboard(identifier: identifier.appending("continuous-main"), from: self)
    }
}

// MARK: - ModernContinuableBoard + Continuous

extension ModernContinuableBoard {
    @discardableResult
    public func mountContinuousMotherboard(to context: AnyObject,
                                           configurationBuilder: (FlowMotherboard) -> Void = { _ in }) -> FlowMotherboard {
        let newBoard = produceContinuousMotherboard()
        configurationBuilder(newBoard)

        newBoard.installIntoRoot(context)

        return newBoard
    }
}

// MARK: - Legacy ContinuousBoard

/// A ContinuousBoard contains an internal sub-motherboard by default.
open class ContinuousBoard: Board, ContinuableBoard {
    public let motherboard: FlowMotherboard

    public init(identifier: BoardID,
                motherboard: FlowMotherboard) {
        self.motherboard = motherboard
        super.init(identifier: identifier)

        motherboard.forwardActionFlow(to: self)
    }

    public convenience init(identifier: BoardID,
                            boardProducer: ActivableBoardProducer) {
        let motherboard = Motherboard(identifier: BoardID(rawValue: identifier.rawValue + ".continuous-main"), boardProducer: boardProducer)
        self.init(identifier: identifier, motherboard: motherboard)
    }

    override open func installIntoRoot(_ rootObject: AnyObject) {
        super.installIntoRoot(rootObject)
        motherboard.installIntoRoot(rootObject)
    }
}
