//
//  ComposingMotherboard+Live.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/22/20.
//

import Foundation
import UIKit

public protocol ComposingMotherboardLivable: AnyObject {
    var composingMotherboard: FlowComposingMotherboard { get set }
}

private var composingMotherboardKey: UInt8 = 109

extension ComposingMotherboardLivable where Self: AnyObject {
    private func getAssociatedComposingMotherboard() -> FlowComposingMotherboard? {
        return objc_getAssociatedObject(self, &composingMotherboardKey) as? FlowComposingMotherboard
    }

    private func setAssociatedComposingMotherboard(_ value: FlowComposingMotherboard?) {
        value?.installIntoRoot(self)
        objc_setAssociatedObject(self, &composingMotherboardKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    public var composingMotherboard: FlowComposingMotherboard {
        get {
            if let board = getAssociatedComposingMotherboard() {
                return board
            } else {
                let newBoard = ComposingMotherboard()
                setAssociatedComposingMotherboard(newBoard)
                return newBoard
            }
        }

        set {
            setAssociatedComposingMotherboard(newValue)
        }
    }
}

// MARK: - Utility extensions

extension NSObject: ComposingMotherboardLivable {
    /// Install a board and keep it alive with rootObject's lifecycle.
    public func attachComposingMotheboard(_ motherboard: FlowComposingMotherboard) {
        composingMotherboard = motherboard
        install(board: motherboard)
    }
}

extension ComposingMotherboardType where Self: FlowManageable {
    public func attach(to object: NSObject) {
        object.attachComposingMotheboard(self)
    }
}
