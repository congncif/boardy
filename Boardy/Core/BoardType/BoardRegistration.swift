//
//  BoardRegistration.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 6/13/21.
//

import Foundation

public typealias BoardConstructor = (BoardID) -> ActivatableBoard

/// A factory paired with the identifier it answers to.
///
/// - Important: equality and hashing use ``identifier`` alone, ignoring the constructor. Two
///   registrations for the same identifier are the same element to a `Set`, which is what makes
///   duplicate registration detectable — and what makes `Set.insert` keep the existing factory
///   rather than replace it.
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
