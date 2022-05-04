//
//  ActivatableBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation
import UIKit

public protocol ActivatableBoard: IdentifiableBoard, OriginalBoard, BoardRegistrationsConvertible {
    func activationBarrier(withOption option: Any?) -> ActivationBarrier?
    func activate(withOption option: Any?)
}

public extension ActivatableBoard {
    func asBoardRegistrations() -> [BoardRegistration] {
        [BoardRegistration(identifier) { _ in self }]
    }
}

public extension ActivatableBoard {
    func activate() {
        activate(withOption: nil)
    }

    func activationBarrier(withOption _: Any?) -> ActivationBarrier? {
        nil
    }
}

public typealias NormalBoard = InstallableBoard & ActivatableBoard

public struct ActivationBarrier {
    public let identifier: BoardID
    public let scope: Scope

    public enum Scope {
        case inMain
        case global
    }
}
