//
//  MotherboardLivable.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/6/20.
//

import Foundation
import UIKit

public protocol MotherboardLivable: AnyObject {
    var motherboard: FlowMotherboard? { get set }
    var lazyMotherboard: FlowMotherboard { get }
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

    public var motherboard: FlowMotherboard? {
        get {
            getAssociatedMotherboard()
        }

        set {
            setAssociatedMotherboard(newValue)
        }
    }

    public var lazyMotherboard: FlowMotherboard {
        if let board = getAssociatedMotherboard() {
            return board
        } else {
            let newBoard = Motherboard()
            setAssociatedMotherboard(newBoard)
            return newBoard
        }
    }
}

// MARK: - Utility extensions

extension NSObject: MotherboardLivable {
    /// Install a board and keep it alive with rootObject's lifecycle.
    public func associate(motherboard: FlowMotherboard) {
        self.motherboard = motherboard
    }
}

extension MotherboardType where Self: FlowManageable {
    public func associateInstall(to object: NSObject) {
        object.associate(motherboard: self)
        object.install(board: self)
    }
}
