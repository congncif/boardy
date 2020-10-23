//
//  ActivatableBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
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
    public func sendToMotherboard(data: Any? = nil) {
        delegate?.board(self, didSendData: data)
    }

    public func nextToBoard(model: BoardInputModel) {
        sendToMotherboard(data: model)
    }

    public func sendFlowAction(_ action: BoardFlowAction) {
        sendToMotherboard(data: action)
    }
}

public protocol ActivatableBoard: IdentifiableBoard, OriginalBoard {
    func activate(withOption option: Any?)
}

extension ActivatableBoard {
    public func activate() {
        activate(withOption: nil)
    }
}

// MARK: - Utility extensions

extension NSObject {
    public func install(board: OriginalBoard) {
        board.installIntoRoot(self)
    }
}
