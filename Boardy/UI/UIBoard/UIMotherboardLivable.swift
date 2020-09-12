//
//  UIMotherboardLivable.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/6/20.
//

import Foundation
import UIKit

public protocol UIMotherboardLivable: AnyObject {
    var uimotherboard: FlowUIMotherboard { get set }
}

private var uimotherboardKey: UInt8 = 107

extension UIMotherboardLivable where Self: UIViewController {
    func getAssociatedUIMotherboard() -> FlowUIMotherboard? {
        return objc_getAssociatedObject(self, &uimotherboardKey) as? FlowUIMotherboard
    }

    func setAssociatedUIMotherboard(_ value: FlowUIMotherboard?) {
        value?.install(into: self)
        objc_setAssociatedObject(self, &uimotherboardKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    public var uimotherboard: FlowUIMotherboard {
        get {
            if let board = getAssociatedUIMotherboard() {
                return board
            } else {
                let newBoard = UIMotherboard()
                setAssociatedUIMotherboard(newBoard)
                return newBoard
            }
        }

        set {
            setAssociatedUIMotherboard(newValue)
        }
    }
}

// MARK: - Utility extensions

extension UIMotherboardLivable where Self: UIViewController {
    /// Install a board and keep it alive with view controller's lifecycle.
    public func attachUIMotherboard(_ board: FlowUIMotherboard) {
        uimotherboard = board
        install(board: board)
    }
}

extension UIMotherboardLivable where Self: UIBoardInterface, Self: DisposeControllable, Self: UIViewController {
    public func plugUIMotherboard(_ board: FlowUIMotherboard) {
        board.plug(in: self, with: disposeBag)
    }
}

extension UIViewController: UIMotherboardLivable {}

extension NSObject: DisposeControllable {}

extension Board: DisposeControllable {}

extension Board {
    /// Use this method to attach an UIMotherboard to guarantee default settings.
    public func attachUIMotherboard(_ uimotherboard: FlowUIMotherboard, to viewController: UIViewController) {
        uimotherboard.registerGeneralFlow { [weak self] in
            self?.sendFlowAction($0)
        }
        viewController.attachUIMotherboard(uimotherboard)
    }
}
