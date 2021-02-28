//
//  BoardID.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 2/26/21.
//

import Foundation

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

    public static func randomUnique() -> BoardID {
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
    return pattern.rawValue == value
}
