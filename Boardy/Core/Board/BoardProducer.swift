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

public protocol BoardDynamicProducer: ActivatableBoardProducer {
    func registerBoard(_ identifier: BoardID, factory: @escaping (BoardID) -> ActivatableBoard)
}

public extension BoardDynamicProducer {
    /// ⚠️ Using autoclosure board might be not good for performance of initializers
    func registerBoard(_ boardCreator: @autoclosure () -> ActivatableBoard) {
        let board = boardCreator()
        registerBoard(board.identifier, factory: { _ in board })
    }
}

public final class BoardProducer: BoardDynamicProducer {
    public private(set) var registrations = Set<BoardRegistration>()

    private var externalProducer: ActivatableBoardProducer

    public init(externalProducer: ActivatableBoardProducer = NoBoardProducer(), registrations: [BoardRegistration] = []) {
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
        return registration?.constructor(identifier) ?? externalProducer.produceBoard(identifier: identifier)
    }

    public func registerBoard(_ identifier: BoardID, factory: @escaping BoardConstructor) {
        let registration = BoardRegistration(identifier, constructor: factory)
        add(registration: registration)
    }

    public func matchBoard(withIdentifier identifier: BoardID, to anotherIdentifier: BoardID) -> ActivatableBoard? {
        if let registration = registrations.first(where: { $0.identifier == identifier }) {
            return registration.constructor(anotherIdentifier)
        } else if let board = externalProducer.matchBoard(withIdentifier: identifier, to: anotherIdentifier) {
            return board
        } else {
            return nil
        }
    }
}

public extension BoardDynamicProducer where Self: AnyObject {
    /// Boxed the producer as a ValueType without retaining to avoid working with reference counter
    var boxed: BoardDynamicProducer {
        BoardDynamicProducerBox(producer: self)
    }
}

struct BoardDynamicProducerBox: BoardDynamicProducer {
    weak var producer: (BoardDynamicProducer & AnyObject)?

    func produceBoard(identifier: BoardID) -> ActivatableBoard? {
        producer?.produceBoard(identifier: identifier)
    }

    func matchBoard(withIdentifier identifier: BoardID, to anotherIdentifier: BoardID) -> ActivatableBoard? {
        producer?.matchBoard(withIdentifier: identifier, to: anotherIdentifier)
    }

    func registerBoard(_ identifier: BoardID, factory: @escaping (BoardID) -> ActivatableBoard) {
        producer?.registerBoard(identifier, factory: factory)
    }
}

public extension ActivatableBoardProducer where Self: AnyObject {
    /// Boxed the producer as a ValueType without retaining to avoid working with reference counter
    var boxed: ActivatableBoardProducer {
        BoardProducerBox(producer: self)
    }
}

struct BoardProducerBox: ActivatableBoardProducer {
    weak var producer: (ActivatableBoardProducer & AnyObject)?

    func produceBoard(identifier: BoardID) -> ActivatableBoard? {
        producer?.produceBoard(identifier: identifier)
    }

    func matchBoard(withIdentifier identifier: BoardID, to anotherIdentifier: BoardID) -> ActivatableBoard? {
        producer?.matchBoard(withIdentifier: identifier, to: anotherIdentifier)
    }
}
