//
//  BoardType.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/26/20.
//

import Foundation
import UIKit

public typealias BoardID = String

public protocol BoardDelegate: AnyObject {
    func board(_ board: IdentifiableBoard, didSendData data: Any?)
}

// MARK: - Board

public protocol OriginalBoard {
    var root: AnyObject? { get }

    func installIntoRoot(_ rootObject: AnyObject)
}

public protocol IdentifiableBoard {
    var delegate: BoardDelegate? { get set }
    var identifier: BoardID { get }
}

extension IdentifiableBoard {
    /// Send a message with data attached (if available) to the motherboard.
    public func sendToMotherboard(data: Any? = nil) {
        delegate?.board(self, didSendData: data)
    }

    /// Request the motherboard to activate another board.
    public func nextToBoard(model: BoardInputModel) {
        sendToMotherboard(data: model)
    }

    /// Broadcast an action to all older motherboars in chain.
    public func sendFlowAction(_ action: BoardFlowAction) {
        sendToMotherboard(data: action)
    }

    /// Interact with a brotherhood relationship board in same Motherboard.
    public func interactWithOtherBoard(command: BoardCommandModel) {
        sendToMotherboard(data: command)
    }
}

// MARK: - Utility extensions

extension NSObject {
    public func install(board: OriginalBoard) {
        board.installIntoRoot(self)
    }
}
