//
//  BoardProducer.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 6/13/21.
//

import Foundation

public protocol BoardRegistrationsConvertible {
    func asBoardRegistrations() -> [BoardRegistration]
}

extension BoardRegistration: BoardRegistrationsConvertible {
    public func asBoardRegistrations() -> [BoardRegistration] { [self] }
}

extension Array: BoardRegistrationsConvertible where Element == BoardRegistration {
    public func asBoardRegistrations() -> [BoardRegistration] { self }
}

public protocol BoardDynamicProducer: AnyObject, ActivableBoardProducer {
    func registerBoard(_ identifier: BoardID, factory: @escaping (BoardID) -> ActivatableBoard)
}

extension BoardDynamicProducer {
    /// Boxed the producer as a ValueType without retaining to avoid working with reference counter
    public var boxed: ActivableBoardProducer {
        return BoardProducerBox(producer: self)
    }
}

public final class BoardProducer: BoardDynamicProducer {
    public private(set) var registrations = Set<BoardRegistration>()

    private var externalProducer: ActivableBoardProducer

    public init(externalProducer: ActivableBoardProducer = NoBoardProducer(), registrations: [BoardRegistration]) {
        self.externalProducer = externalProducer
        self.registrations = Set(registrations)
    }

    @discardableResult
    public func add(registration: BoardRegistration) -> Bool {
        guard !registrations.contains(registration) else {
            return false
        }
        registrations.insert(registration)
        return true
    }

    @discardableResult
    public func remove(registration: BoardRegistration) -> Bool {
        guard registrations.contains(registration) else {
            return false
        }
        registrations.remove(registration)
        return true
    }

    public func produceBoard(identifier: BoardID) -> ActivatableBoard? {
        let registration = registrations.first { $0.identifier == identifier }
        return registration?.constructor(identifier)
    }

    public func registerBoard(_ identifier: BoardID, factory: @escaping BoardConstructor) {
        let registration = BoardRegistration(identifier, constructor: factory)
        add(registration: registration)
    }

    public func matchBoard(withIdentifier identifier: BoardID, to anotherIdentifier: BoardID) -> ActivatableBoard? {
        if let registration = registrations.first { $0.identifier == identifier } {
            return registration.constructor(anotherIdentifier)
        } else if let board = externalProducer.matchBoard(withIdentifier: identifier, to: anotherIdentifier) {
            return board
        } else {
            return nil
        }
    }
}

struct BoardProducerBox: ActivableBoardProducer {
    weak var producer: BoardDynamicProducer?

    func produceBoard(identifier: BoardID) -> ActivatableBoard? {
        producer?.produceBoard(identifier: identifier)
    }

    func matchBoard(withIdentifier identifier: BoardID, to anotherIdentifier: BoardID) -> ActivatableBoard? {
        producer?.matchBoard(withIdentifier: identifier, to: anotherIdentifier)
    }
}
