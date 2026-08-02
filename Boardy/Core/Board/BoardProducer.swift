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

/// A producer whose registrations can be added at runtime.
///
/// This is what plugins register into while an app is being assembled. Two implementations ship —
/// ``BoardProducer`` and ``BoardContainer`` — and they differ on duplicate registration; see either
/// type, or `docs/BU.md`.
public protocol BoardDynamicProducer: ActivatableBoardProducer {
    func registerBoard(_ identifier: BoardID, factory: @escaping (BoardID) -> ActivatableBoard)
    func registerGatewayBoard(_ identifier: BoardID, factory: @escaping (BoardID) -> ActivatableBoard)

    /// Registers `factory` for `identifier`, stating explicitly what should happen when one is
    /// already registered.
    ///
    /// Prefer this over `registerBoard(_:factory:)` whenever a duplicate registration is possible,
    /// because the two built-in producers disagree on the default and always have:
    /// `BoardProducer` keeps the existing factory, `BoardContainer` replaces it. Both honour this
    /// method identically.
    func registerBoard(_ identifier: BoardID, replacingExisting: Bool, factory: @escaping (BoardID) -> ActivatableBoard)
}

public extension BoardDynamicProducer {
    /// ⚠️ Using autoclosure board might be not good for performance of initializers
    func registerBoard(_ boardCreator: @autoclosure () -> ActivatableBoard) {
        let board = boardCreator()
        registerBoard(board.identifier, factory: { _ in board })
    }

    /// Default for conformers written before this requirement existed.
    ///
    /// It cannot honour `replacingExisting` — the protocol has no primitive for removing a
    /// registration — so it falls back to the conformer's own duplicate behavior. `BoardProducer`
    /// and `BoardContainer` both override this and do honour the flag.
    func registerBoard(_ identifier: BoardID, replacingExisting _: Bool, factory: @escaping (BoardID) -> ActivatableBoard) {
        registerBoard(identifier, factory: factory)
    }
}

/// Creates boards on demand from registered factories.
///
/// A motherboard holding a producer stays empty until something is activated, so a screen deep in
/// a flow costs nothing until it is reached. Registrations can be inspected through
/// ``registrations``, which is what distinguishes this from ``BoardContainer``.
///
/// ```swift
/// let producer = BoardProducer()
/// producer.registerBoard(.checkout) { id in CheckoutBoard(identifier: id) }
/// ```
///
/// - Note: registering the same identifier twice keeps the **first** factory and ignores the
///   second. ``BoardContainer`` does the opposite. When a duplicate is deliberate, use
///   ``BoardDynamicProducer/registerBoard(_:replacingExisting:factory:)``, which both honour
///   identically.
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

    /// Hashed lookup by identifier.
    ///
    /// `BoardRegistration` hashes and compares on `identifier` alone, so the sets are already
    /// identifier-keyed indexes — but a `first { $0.identifier == … }` scan pays O(n) and throws
    /// that away. A probe carrying the identifier finds the *stored* element in constant time.
    private static func registration(
        for identifier: BoardID,
        in registrations: Set<BoardRegistration>
    ) -> BoardRegistration? {
        let probe = BoardRegistration(identifier) { _ in nil }
        guard let index = registrations.firstIndex(of: probe) else { return nil }
        return registrations[index]
    }

    public func produceBoard(identifier: BoardID) -> ActivatableBoard? {
        let registration = Self.registration(for: identifier, in: registrations)
        return registration?.constructor(identifier) ?? externalProducer.produceBoard(identifier: identifier)
    }

    public func produceGatewayBoard(identifier: BoardID) -> (any ActivatableBoard)? {
        let id = identifier.gateway
        let registration = Self.registration(for: id, in: gatewayRegistrations)
            ?? Self.registration(for: .wildcard.gateway, in: gatewayRegistrations)
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

    /// Registers `factory`, keeping any existing registration for `identifier`.
    ///
    /// This producer has always kept the first registration and ignored later ones. `BoardContainer`
    /// does the opposite. Neither is being changed; use
    /// `registerBoard(_:replacingExisting:factory:)` when the choice matters.
    public func registerBoard(_ identifier: BoardID, factory: @escaping BoardConstructor) {
        #if DEBUG
            if Self.registration(for: identifier, in: registrations) != nil {
                print("⚠️ [BoardProducer] Board with identifier \(identifier) is already registered. The existing factory is kept and this registration is ignored. Use registerBoard(_:replacingExisting:factory:) to state which one you want.")
            }
        #endif

        registerBoard(identifier, replacingExisting: false, factory: factory)
    }

    public func registerBoard(_ identifier: BoardID, replacingExisting: Bool, factory: @escaping BoardConstructor) {
        let registration = BoardRegistration(identifier, constructor: factory)

        guard registrations.contains(registration) else {
            registrations.insert(registration)
            return
        }

        guard replacingExisting else { return }

        // `insert` keeps the existing element when one compares equal; `update` swaps it.
        registrations.update(with: registration)
    }

    public func matchBoard(withIdentifier identifier: BoardID, to anotherIdentifier: BoardID) -> ActivatableBoard? {
        if let registration = Self.registration(for: identifier, in: registrations) {
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

    func registerBoard(_ identifier: BoardID, replacingExisting: Bool, factory: @escaping (BoardID) -> ActivatableBoard) {
        producer?.registerBoard(identifier, replacingExisting: replacingExisting, factory: factory)
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
