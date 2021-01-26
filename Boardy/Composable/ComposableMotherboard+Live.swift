//
//  ComposableMotherboard+Live.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/22/20.
//

import Foundation
import UIKit

public protocol ComposableMotherboardLivable: AnyObject {
    var composableMotherboard: FlowComposableMotherboard? { get set }
    var lazyComposableMotherboard: FlowComposableMotherboard { get }
}

private var composableMotherboardKey: UInt8 = 109

extension ComposableMotherboardLivable where Self: AnyObject {
    private func getAssociatedComposableMotherboard() -> FlowComposableMotherboard? {
        return objc_getAssociatedObject(self, &composableMotherboardKey) as? FlowComposableMotherboard
    }

    private func setAssociatedComposableMotherboard(_ value: FlowComposableMotherboard?) {
        value?.installIntoRoot(self)
        objc_setAssociatedObject(self, &composableMotherboardKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    public var composableMotherboard: FlowComposableMotherboard? {
        get {
            getAssociatedComposableMotherboard()
        }

        set {
            setAssociatedComposableMotherboard(newValue)
        }
    }

    public var lazyComposableMotherboard: FlowComposableMotherboard {
        if let board = getAssociatedComposableMotherboard() {
            return board
        } else {
            let newBoard = ComposableMotherboard()
            setAssociatedComposableMotherboard(newBoard)
            return newBoard
        }
    }
}

// MARK: - Utility extensions

extension NSObject: ComposableMotherboardLivable {
    /// Install a board and keep it alive with rootObject's lifecycle.
    public func associate(composableMotherboard: FlowComposableMotherboard) {
        self.composableMotherboard = composableMotherboard
        install(board: composableMotherboard)
    }
}

extension ComposableMotherboardType where Self: FlowManageable {
    public func associate(to object: NSObject) {
        object.associate(composableMotherboard: self)
    }
}
