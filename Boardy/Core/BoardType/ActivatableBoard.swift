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

public typealias NormalBoard = ActivatableBoard & InstallableBoard

public struct ActivationBarrier {
    public let barrierIdentifier: BoardID
    public let scope: ActivationBarrierScope
    public let option: ActivationBarrierOption
}

/// Control lifecycle of Activation Barrier
public enum ActivationBarrierScope {
    /// Activation Barrier is created and lives on the current Mainboard
    case mainboard

    /// Activation Barrier is unique by identifier in whole the application
    case application
}

public extension ActivationBarrierScope {
    @available(*, deprecated, renamed: "mainboard", message: "Use .mainboard instead")
    static var inMain: ActivationBarrierScope { .mainboard }
    @available(*, deprecated, renamed: "application", message: "Use .application instead")
    static var global: ActivationBarrierScope { .application }
}

/// Enable identity Activation Barrier with the input option
public enum ActivationBarrierOption {
    /// Activation Barrier without input. This is default value.
    case void

    /// Activation Barrier is unique with the hashed input. Will create a new barrier if the hash value changes.
    case unique(AnyHashable)

    /// Activation Barrier is always created with any input. When the input is `nil`, this option works similarly to `.none` option.
    case unidentified(Any?)

    var value: Any? {
        switch self {
        case .void:
            return ()
        case let .unique(value):
            return value
        case let .unidentified(value):
            return value
        }
    }
}

public extension ActivationBarrier {
    var identifier: BoardID {
        var privateID = barrierIdentifier.appending("___PRIVATE_BARRIER___")

        switch option {
        case .void:
            break
        case let .unique(value):
            let optionValue = String(value.hashValue)
            privateID = privateID.appending(optionValue)
        case let .unidentified(value):
            if value != nil {
                if value is Void {
                    break
                } else {
                    privateID = privateID.appending(UUID().uuidString)
                }
            } else {
                privateID = privateID.appending("none")
            }
        }

        return privateID
    }
}
