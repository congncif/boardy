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

extension [BoardRegistration]: BoardRegistrationsConvertible {
    public func asBoardRegistrations() -> [BoardRegistration] { self }
}

public protocol BoardDynamicProducer: ActivatableBoardProducer {
    func registerBoard(_ identifier: BoardID, factory: @escaping (BoardID) -> ActivatableBoard)
    func registerGatewayBoard(_ identifier: BoardID, factory: @escaping (BoardID) -> ActivatableBoard)
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
    public private(set) var gatewayRegistrations = Set<BoardRegistration>()

    private var externalProducer: ActivatableBoardProducer

    public init(externalProducer: ActivatableBoardProducer = NoBoardProducer(),
                registrations: [BoardRegistration] = [],
                gatewayRegistrations: [BoardRegistration] = []) {
        self.externalProducer = externalProducer
        self.registrations = Set(registrations)
        self.gatewayRegistrations = Set(gatewayRegistrations)
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

    public func produceGatewayBoard(identifier: BoardID) -> (any ActivatableBoard)? {
        let id = identifier.gateway
        let registration = gatewayRegistrations.first { $0.identifier == id } ?? gatewayRegistrations.first { $0.identifier == .wildcard.gateway }
        return registration?.constructor(id) ?? externalProducer.produceGatewayBoard(identifier: identifier)
    }

    public func registerGatewayBoard(_ identifier: BoardID, factory: @escaping (BoardID) -> (any ActivatableBoard)) {
        let id = identifier.gateway
        let registration = BoardRegistration(id, constructor: factory)
        guard !gatewayRegistrations.contains(registration) else {
            #if DEBUG
                if identifier == .wildcard {
                    print("⚠️ [GatewayBarrier] is already registered. The registration will be ignored.")
                } else {
                    print("⚠️ [GatewayBarrier] with identifier \(identifier) is already registered. The registration will be ignored.")
                }
            #endif
            return
        }
        gatewayRegistrations.insert(registration)
    }

    public func registerBoard(_ identifier: BoardID, factory: @escaping BoardConstructor) {
        let registration = BoardRegistration(identifier, constructor: factory)
        add(registration: registration)
    }

    public func matchBoard(withIdentifier identifier: BoardID, to anotherIdentifier: BoardID) -> ActivatableBoard? {
        if let registration = registrations.first(where: { $0.identifier == identifier }) {
            registration.constructor(anotherIdentifier)
        } else if let board = externalProducer.matchBoard(withIdentifier: identifier, to: anotherIdentifier) {
            board
        } else {
            nil
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

    func registerGatewayBoard(_ identifier: BoardID, factory: @escaping (BoardID) -> (any ActivatableBoard)) {
        producer?.registerGatewayBoard(identifier, factory: factory)
    }

    func produceGatewayBoard(identifier: BoardID) -> (any ActivatableBoard)? {
        producer?.produceGatewayBoard(identifier: identifier)
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

    func produceGatewayBoard(identifier: BoardID) -> (any ActivatableBoard)? {
        producer?.produceGatewayBoard(identifier: identifier)
    }
}
