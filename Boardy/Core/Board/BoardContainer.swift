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

public final class BoardContainer: BoardDynamicProducer {
    private var externalProducer: ActivatableBoardProducer?
    private var container: [BoardID: BoardConstructor] = [:]
    private var gatewayContainer: [BoardID: BoardConstructor] = [:]

    public init(externalProducer: ActivatableBoardProducer? = nil) {
        self.externalProducer = externalProducer
    }

    public func registerBoard(_ identifier: BoardID, factory: @escaping BoardConstructor) {
        container[identifier] = factory
    }

    public func registerBoards(_ identifiers: [BoardID], factory: @escaping BoardConstructor) {
        identifiers.forEach { identifier in
            container[identifier] = factory
        }
    }

    public func registerBoards(_ identifiers: BoardID..., factory: @escaping BoardConstructor) {
        identifiers.forEach { identifier in
            container[identifier] = factory
        }
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
