//
//  BoardRegistration.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 6/13/21.
//

import Foundation

public typealias BoardConstructor = (BoardID) -> ActivatableBoard

public struct BoardRegistration: Hashable {
    public init(_ identifier: BoardID, constructor: @escaping (BoardID) -> ActivatableBoard?) {
        self.identifier = identifier
        self.constructor = constructor
    }

    public let identifier: BoardID
    public let constructor: (BoardID) -> ActivatableBoard?

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    public static func == (lhs: BoardRegistration, rhs: BoardRegistration) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
