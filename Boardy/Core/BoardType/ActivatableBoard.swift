//
//  ActivatableBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

public typealias BoardID = String

public protocol BoardDelegate: AnyObject {
    func board(_ board: IdentifiableBoard, didSendData data: Any?)
}

// MARK: - Board

public protocol InstallableBoard {
    var rootViewController: UIViewController { get }

    func install(into rootViewController: UIViewController)
}

public protocol IdentifiableBoard {
    var delegate: BoardDelegate? { get set }
    var identifier: BoardID { get }
}

extension IdentifiableBoard {
    public func sendToMotherboard(data: Any?) {
        delegate?.board(self, didSendData: data)
    }

    public func sendToMotherboard() {
        delegate?.board(self, didSendData: nil)
    }
}

public protocol ActivatableBoard: IdentifiableBoard, InstallableBoard {
    func activate(withOption option: Any?)
}

// MARK: - Utility extensions

extension UIViewController {
    public func install(board: InstallableBoard) {
        board.install(into: self)
    }
}
