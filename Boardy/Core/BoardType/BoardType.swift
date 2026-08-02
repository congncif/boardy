//
//  BoardType.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/26/20.
//

import Foundation
import UIKit

/// The receiving end of everything a board emits.
///
/// A board never talks to another board directly. It hands data to its delegate — in practice a
/// ``Motherboard`` — which matches the message against its registered flows and decides what
/// happens next. That indirection is what lets boards be composed without knowing about each other.
///
/// The delegate is held weakly by the board, and the motherboard sets itself as delegate when the
/// board is installed.
public protocol BoardDelegate: AnyObject {
    /// Called when `board` emits data. `data` is untyped at this layer; the typed façades
    /// (``GuaranteedBoard``, flows) cast it on the way in and out.
    func board(_ board: IdentifiableBoard, didSendData data: Any?)
}

// MARK: - Board

/// A board's link to the object it was installed into.
///
/// The context is usually the `UIViewController` or `UIWindow` the board presents from. It is set
/// once, by whoever installs the board, and is what lets an otherwise stateless board reach UIKit.
public protocol OriginalBoard {
    /// System context which helps this Board access current state of system.
    var context: AnyObject? { get }

    /// Set context for this Board
    func putIntoContext(_ context: AnyObject)
}

/// The minimum a board must provide: a name to be addressed by, and somewhere to send output.
///
/// Everything the framework routes — activation, interaction, completion, flows — is keyed on
/// ``identifier``. Two boards with the same identifier cannot be installed in the same motherboard.
public protocol IdentifiableBoard: AnyObject, CustomDebugStringConvertible {
    /// Set by the motherboard when the board is installed. Held weakly.
    var delegate: BoardDelegate? { get set }

    /// The board's address within its motherboard. Stable for the board's lifetime.
    var identifier: BoardID { get }
}

public extension IdentifiableBoard {
    /// Send a message with data attached (if available) to the motherboard.
    func sendToMotherboard(data: Any? = nil) {
        DebugLog.logActivity(source: self, data: data)

        #if DEBUG
            if delegate == nil, !(self is MotherboardType) {
                print("⚠️ [\(String(describing: type(of: self)))] [\(#function)] [\(identifier)] sent a message with data \(String(describing: data)) to its Motherboard but it seems to have no Motherboards.")
            }
        #endif

        delegate?.board(self, didSendData: data)
    }

    /// Request the motherboard to activate another board.
    func nextToBoard(model: BoardInputModel) {
        sendToMotherboard(data: model)
    }

    func nextToBoard<Input>(_ input: BoardInput<Input>) {
        nextToBoard(model: input)
    }

    /// Send a Broadcast action to all older motherboards in chain.
    func sendFlowAction(_ action: BoardFlowAction) {
        sendToMotherboard(data: action)
    }

    /// Interact with a brotherhood relationship board in same Motherboard.
    func interactWithOtherBoard(command: BoardCommandModel) {
        sendToMotherboard(data: command)
    }

    func interactWithOtherBoard<Input>(_ input: BoardCommand<Input>) {
        interactWithOtherBoard(command: input)
    }

    /// Complete this board & ask to be removed.
    func complete(_ isDone: Bool = true) {
        sendToMotherboard(data: CompleteAction(identifier: identifier, isDone: isDone))
    }

    var debugDescription: String {
        var desc = ""
        desc += "    🏝 [\(String(describing: type(of: self)))] ➤ \(identifier.rawValue)"
        if let motherboard = delegate as? IdentifiableBoard {
            desc += "    🌏 [\(String(describing: type(of: motherboard)))] ➤ \(motherboard.identifier.rawValue)"
        }
        return desc
    }
}

// MARK: - CompleteAction

// Special action to indicate the board completed & should be removed.
struct CompleteAction {
    let identifier: BoardID
    let isDone: Bool
}
