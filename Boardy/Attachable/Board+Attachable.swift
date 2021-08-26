//
//  Board+Attachable.swift
//  Boardy
//
//  Created by FOLY on 1/26/21.
//

import Foundation
import UIKit

extension NSObject: AttachableObject {}

extension Board: AttachableObject {}

// MARK: - Utility extensions

extension UIViewController {
    /// Install a board and keep it alive with rootObject's lifecycle.
    public func attach(motherboard: FlowMotherboard) {
        attachObject(motherboard)
    }

    public func attach(board: Board) {
        attachObject(board)
    }
}

extension MotherboardType where Self: FlowManageable {
    public func attachInstall(to object: UIViewController) {
        object.attach(motherboard: self)
        object.install(board: self)
    }
}

extension Board {
    public func attach(to object: UIViewController) {
        object.attach(board: self)
    }
}
