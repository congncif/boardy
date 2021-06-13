//
//  ActivatableBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation
import UIKit

public protocol ActivatableBoard: IdentifiableBoard, OriginalBoard, BoardRegistrationsConvertible {
    func activate(withOption option: Any?)
}

extension ActivatableBoard {
    public func asBoardRegistrations() -> [BoardRegistration] {
        [BoardRegistration(identifier) { _ in self }]
    }
}

extension ActivatableBoard {
    public func activate() {
        activate(withOption: nil)
    }
}

public typealias NormalBoard = InstallableBoard & ActivatableBoard
