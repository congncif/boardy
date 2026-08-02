//
//  BoardID.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 2/26/21.
//

import Foundation

/// A board's address, as a string with a type around it.
///
/// Every route in the framework is keyed on a `BoardID`: which board to activate, which board a
/// flow listens to, which registration a producer answers with. The wrapper exists so those keys
/// cannot be confused with arbitrary strings, and so identifiers can be declared once and shared:
///
/// ```swift
/// extension BoardID {
///     static let checkout: BoardID = "checkout"
/// }
///
/// motherboard.activateBoard(identifier: .checkout, withOption: cart)
/// ```
///
/// String literals work directly (`let id: BoardID = "checkout"`), which is convenient in tests and
/// a typo risk in production code — prefer declared constants.
///
/// The framework reserves two suffixes and composes them onto your identifiers: `.___GATEWAY___`
/// for a board's gateway barrier and `___PRIVATE_BARRIER___` for an activation barrier. Do not
/// build identifiers containing them.
public struct BoardID: LosslessStringConvertible, ExpressibleByStringLiteral, Hashable, RawRepresentable {
    public typealias StringLiteralType = String

    public let rawValue: String

    public init(stringLiteral value: StringLiteralType) {
        rawValue = value
    }

    public init(_ description: String) {
        rawValue = description
    }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public var description: String {
        rawValue
    }

    public static func random() -> BoardID {
        BoardID(UUID().uuidString)
    }
}

extension BoardID: Equatable {
    public static func == (lhs: BoardID, rhs: BoardID) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

// Overload the ~= operator to match a BoardID with a string.
public func ~= (pattern: BoardID, value: String) -> Bool {
    pattern.rawValue == value
}

public extension BoardID {
    func appending(_ tail: String, separator: String = ".") -> BoardID {
        BoardID(rawValue + separator + tail)
    }
}
