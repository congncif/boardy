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

public extension ContinuableBoard {
    func continueBoard<Input>(_ input: BoardInput<Input>) {
        motherboard.activateBoard(input)
    }

    func continueBoard(model: BoardInputModel) {
        motherboard.activateBoard(model: model)
    }

    func continueInteractWithBoard<Input>(_ input: BoardCommand<Input>) {
        motherboard.interactWithBoard(input)
    }

    func continueInteractWithBoard(command: BoardCommandModel) {
        motherboard.interactWithBoard(command: command)
    }
}

// MARK: - ModernContinuableBoard

open class ModernContinuableBoard: Board, ContinuableBoard {
    public var motherboard: FlowMotherboard { internalMainboard }

    public let producer: ActivatableBoardProducer

    public init(identifier: BoardID,
                boardProducer: ActivatableBoardProducer) {
        producer = boardProducer
        super.init(identifier: identifier)
    }

    private lazy var internalMainboard: FlowMotherboard = produceContinuousMotherboard()

    override open func putIntoContext(_ context: AnyObject) {
        super.putIntoContext(context)
        motherboard.putIntoContext(context)
    }

    func produceContinuousMotherboard() -> FlowMotherboard {
        producer.produceContinuousMotherboard(identifier: identifier.appending("continuous-main"), from: self)
    }
}

// MARK: - ModernContinuableBoard + Continuous

public extension ModernContinuableBoard {
    @discardableResult
    func mountContinuousMotherboard(to context: AnyObject,
                                    configurationBuilder: (FlowMotherboard) -> Void = { _ in }) -> FlowMotherboard {
        let newBoard = produceContinuousMotherboard()
        configurationBuilder(newBoard)

        newBoard.putIntoContext(context)

        return newBoard
    }

    @discardableResult
    func mountContinuousMotherboard<Mainboard: FlowMotherboard>(to context: AnyObject, build: (ActivatableBoardProducer) -> Mainboard) -> Mainboard {
        let newBoard = build(producer)
        newBoard.putIntoContext(context)

        return newBoard
    }
}

// MARK: - Legacy ContinuousBoard

/// A ContinuousBoard contains an internal sub-motherboard by default.
///
/// Still supported in 1.x. New code should prefer `ModernContinuableBoard`, which builds its
/// sub-motherboard lazily from a producer instead of holding one from construction.
///
/// This is not carrying a deprecation attribute, because moving is not a rename. `init(identifier:motherboard:)`
/// takes a `FlowMotherboard` the caller assembled; `ModernContinuableBoard` has no equivalent and
/// only accepts a producer, calling `produceContinuousMotherboard()` when the board is first used.
/// A call site that assembles its own motherboard has to change how it is constructed, not just
/// which type it names, so existing code is left to migrate on its own schedule.
open class ContinuousBoard: Board, ContinuableBoard {
    public let motherboard: FlowMotherboard

    #if DEBUG
        /// Emitted once per process rather than per instance: this is a signpost, not a warning
        /// about the call site it happens to fire from.
        private static let legacyNotice: Void = print("ℹ️ [Boardy] ContinuousBoard is the legacy continuable board and remains supported. New code should prefer ModernContinuableBoard — see the type's documentation for why migrating changes construction, not just the type name.")
    #endif

    public init(identifier: BoardID,
                motherboard: FlowMotherboard) {
        #if DEBUG
            _ = Self.legacyNotice
        #endif

        self.motherboard = motherboard
        super.init(identifier: identifier)

        motherboard.forwardActionFlow(to: self)
    }

    public init(identifier: BoardID,
                boardProducer: ActivatableBoardProducer) {
        #if DEBUG
            _ = Self.legacyNotice
        #endif

        let motherboard = Motherboard(identifier: BoardID(rawValue: identifier.rawValue + ".continuous-main"), boardProducer: boardProducer)

        self.motherboard = motherboard
        super.init(identifier: identifier)
        motherboard.forwardActionFlow(to: self)
    }

    override open func putIntoContext(_ context: AnyObject) {
        super.putIntoContext(context)
        motherboard.putIntoContext(context)
    }
}
