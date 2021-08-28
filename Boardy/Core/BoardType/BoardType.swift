//
//  BoardType.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/26/20.
//

import Foundation
import UIKit

public protocol BoardDelegate: AnyObject {
    func board(_ board: IdentifiableBoard, didSendData data: Any?)
}

// MARK: - Board

public protocol OriginalBoard {
    /// System context which helps this Board access current state of system.
    var context: AnyObject? { get }

    /// Set context for this Board
    func putIntoContext(_ context: AnyObject)
}

public protocol IdentifiableBoard: AnyObject, CustomDebugStringConvertible {
    var delegate: BoardDelegate? { get set }
    var identifier: BoardID { get }
}

extension IdentifiableBoard {
    /// Send a message with data attached (if available) to the motherboard.
    public func sendToMotherboard(data: Any? = nil) {
        DebugLog.logActivator(source: self, data: data)

        #if DEBUG
        if delegate == nil {
            print("⚠️ [\(String(describing: type(of: self)))] [\(#function)] [\(identifier)] sent a message with data \(String(describing: data)) to its Motherboard but it seems to have no Motherboards.")
        }
        #endif

        delegate?.board(self, didSendData: data)
    }

    /// Request the motherboard to activate another board.
    public func nextToBoard(model: BoardInputModel) {
        sendToMotherboard(data: model)
    }

    public func nextToBoard<Input>(_ input: BoardInput<Input>) {
        nextToBoard(model: input)
    }

    /// Send a Broadcast action to all older motherboards in chain.
    public func sendFlowAction(_ action: BoardFlowAction) {
        sendToMotherboard(data: action)
    }

    /// Send a Broadcast action with generic type. See more sendFlowAction(_:).
    public func broadcastAction<Action: BoardFlowAction>(_ action: Action) {
        sendFlowAction(action)
    }

    /// Interact with a brotherhood relationship board in same Motherboard.
    public func interactWithOtherBoard(command: BoardCommandModel) {
        sendToMotherboard(data: command)
    }

    public func interactWithOtherBoard<Input>(_ input: BoardCommand<Input>) {
        interactWithOtherBoard(command: input)
    }

    /// Complete this board & ask to be removed.
    public func complete() {
        sendToMotherboard(data: CompleteAction(identifier: identifier))
    }
}

// MARK: - CompleteAction

// Special action to indicate the board completed & should be removed.
struct CompleteAction {
    let identifier: BoardID
}
