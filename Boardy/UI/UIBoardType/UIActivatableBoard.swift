//
//  UIPluggableBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

public protocol UIPluggableBoard {
    var version: Int { get }
    var isVisible: Bool { get }
    var options: Any? { get }
    var pluggableInterface: UIViewController { get }
}

// Default is unchanged board
extension UIPluggableBoard {
    public var version: Int { return 1 }
    public var isVisible: Bool { return true }
    public var options: Any? { return nil }
}

public protocol UIActivatableBoard: UIPluggableBoard, ActivatableBoard {
    var changeSequence: Observable<UIActivatableBoard> { get }

    func reload()
}

public struct UIBoardItem: Equatable {
    public private(set) weak var viewController: UIViewController?
    public let identifier: BoardID
    public let version: Int
    public let options: Any?

    public static func == (lhs: UIBoardItem, rhs: UIBoardItem) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.version == rhs.version
    }

    public init(identifier: BoardID, version: Int, viewController: UIViewController, options: Any? = nil) {
        self.identifier = identifier
        self.version = version
        self.viewController = viewController
        self.options = options
    }
}

public protocol UIBoardInterface {
    var boardItems: Binder<[UIBoardItem]> { get }
}
