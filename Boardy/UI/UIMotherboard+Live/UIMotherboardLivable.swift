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

extension UIMotherboardLivable where Self: AnyObject {
    func getAssociatedUIMotherboard() -> FlowUIMotherboard? {
        return objc_getAssociatedObject(self, &uimotherboardKey) as? FlowUIMotherboard
    }

    func setAssociatedUIMotherboard(_ value: FlowUIMotherboard?) {
        value?.installIntoRoot(self)
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

extension NSObject: UIMotherboardLivable {}

extension Board: DisposeControllable {}

// MARK: - UIMotherboard live

extension UIMotherboardLivable where Self: NSObject {
    /// Install a board and keep it alive with rootObject's lifecycle.
    public func attachUIMotherboard(_ board: FlowUIMotherboard) {
        uimotherboard = board
        install(board: board)
    }
}

extension UIMotherboardLivable where Self: UIBoardInterface, Self: DisposeControllable {
    public func plugUIMotherboard(_ board: FlowUIMotherboard) {
        board.plug(in: self, with: disposeBag)
    }
}

extension UIMotherboardType where Self: DisposeControllable {
    public func plug(in interface: UIBoardInterface) {
        plug(in: interface, with: disposeBag)
    }
}
