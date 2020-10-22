//
//  MotherboardLivable.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/6/20.
//

import Foundation
import UIKit

public protocol MotherboardLivable: AnyObject {
    var motherboard: FlowMotherboard { get set }
}

private var motherboardKey: UInt8 = 105

extension MotherboardLivable where Self: AnyObject {
    private func getAssociatedMotherboard() -> FlowMotherboard? {
        return objc_getAssociatedObject(self, &motherboardKey) as? FlowMotherboard
    }

    private func setAssociatedMotherboard(_ value: FlowMotherboard?) {
        value?.installIntoRoot(self)
        objc_setAssociatedObject(self, &motherboardKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    public var motherboard: FlowMotherboard {
        get {
            if let board = getAssociatedMotherboard() {
                return board
            } else {
                let newBoard = Motherboard()
                setAssociatedMotherboard(newBoard)
                return newBoard
            }
        }

        set {
            setAssociatedMotherboard(newValue)
        }
    }
}

// MARK: - Utility extensions

extension NSObject: MotherboardLivable {
    /// Install a board and keep it alive with rootObject's lifecycle.
    public func attachMotheboard(_ motherboard: FlowMotherboard) {
        self.motherboard = motherboard
        install(board: motherboard)
    }
}

extension MotherboardType where Self: FlowManageable {
    public func attach(to object: NSObject) {
        object.attachMotheboard(self)
    }
}
