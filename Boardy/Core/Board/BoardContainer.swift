//
//  BoardContainer.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 12/23/20.
//

import Foundation

extension BoardID {
    static let wildcard: BoardID = "*"

    var gateway: BoardID {
        appending("___GATEWAY___", separator: ".")
    }

    var isGateway: Bool {
        rawValue.hasSuffix(".___GATEWAY___")
    }
}

/// A dictionary-backed board producer, with bulk registration.
///
/// Prefer this over ``BoardProducer`` when many identifiers share one factory:
///
/// ```swift
/// container.registerBoards(.settings, .about, .help) { id in StaticPageBoard(identifier: id) }
/// ```
///
/// - Note: registering the same identifier twice **replaces** the existing factory — the opposite
///   of ``BoardProducer``, and of this type's own gateway registration. When a duplicate is
///   deliberate, use ``BoardDynamicProducer/registerBoard(_:replacingExisting:factory:)``.
public final class BoardContainer: BoardDynamicProducer {
    private var externalProducer: ActivatableBoardProducer?
    private var container: [BoardID: BoardConstructor] = [:]
    private var gatewayContainer: [BoardID: BoardConstructor] = [:]

    public init(externalProducer: ActivatableBoardProducer? = nil) {
        self.externalProducer = externalProducer
    }

    /// Registers `factory`, replacing any existing registration for `identifier`.
    ///
    /// This container has always replaced on duplicate registration, which is the opposite of
    /// `BoardProducer` and of this type's own gateway registration below. Neither is being
    /// changed; use `registerBoard(_:replacingExisting:factory:)` when the choice matters.
    public func registerBoard(_ identifier: BoardID, factory: @escaping BoardConstructor) {
        #if DEBUG
            if container[identifier] != nil {
                print("⚠️ [BoardContainer] Board with identifier \(identifier) is already registered. The existing factory is replaced. Use registerBoard(_:replacingExisting:factory:) to state which one you want.")
            }
        #endif

        registerBoard(identifier, replacingExisting: true, factory: factory)
    }

    public func registerBoard(_ identifier: BoardID, replacingExisting: Bool, factory: @escaping BoardConstructor) {
        guard container[identifier] == nil else {
            guard replacingExisting else { return }
            container[identifier] = factory
            return
        }

        container[identifier] = factory
    }

    public func registerBoards(_ identifiers: [BoardID], factory: @escaping BoardConstructor) {
        identifiers.forEach { identifier in
            registerBoard(identifier, factory: factory)
        }
    }

    public func registerBoards(_ identifiers: BoardID..., factory: @escaping BoardConstructor) {
        registerBoards(identifiers, factory: factory)
    }

    public func registerGatewayBoard(_ identifier: BoardID, factory: @escaping (BoardID) -> any ActivatableBoard) {
        let id = identifier.gateway

        if gatewayContainer[id] == nil {
            gatewayContainer[id] = factory
        } else {
            #if DEBUG
                if identifier == .wildcard {
                    print("⚠️ [GatewayBarrier] is already registered. The registration will be ignored.")
                } else {
                    print("⚠️ [GatewayBarrier] with identifier \(identifier) is already registered. The registration will be ignored.")
                }
            #endif
        }
    }

    public func produceBoard(identifier: BoardID) -> ActivatableBoard? {
        if let boardFactory = container[identifier] {
            boardFactory(identifier)
        } else if let board = externalProducer?.produceBoard(identifier: identifier) {
            board
        } else {
            nil
        }
    }

    public func produceGatewayBoard(identifier: BoardID) -> (any ActivatableBoard)? {
        let id = identifier.gateway
        return if let boardFactory = gatewayContainer[id] {
            boardFactory(id)
        } else if let boardFactory = gatewayContainer[.wildcard.gateway] {
            boardFactory(.wildcard.gateway)
        } else if let board = externalProducer?.produceGatewayBoard(identifier: identifier) {
            board
        } else {
            nil
        }
    }

    public func matchBoard(withIdentifier identifier: BoardID, to anotherIdentifier: BoardID) -> ActivatableBoard? {
        if let boardFactory = container[identifier] {
            boardFactory(anotherIdentifier)
        } else if let board = externalProducer?.matchBoard(withIdentifier: identifier, to: anotherIdentifier) {
            board
        } else {
            nil
        }
    }
}
