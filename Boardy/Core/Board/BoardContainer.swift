//
//  BoardContainer.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 12/23/20.
//

import Foundation

public final class BoardContainer: BoardDynamicProducer {
    private var externalProducer: ActivableBoardProducer?

    private var container: [BoardID: BoardConstructor] = [:]

    public init(externalProducer: ActivableBoardProducer? = nil) {
        self.externalProducer = externalProducer
    }

    public func registerBoard(_ identifier: BoardID, factory: @escaping BoardConstructor) {
        container[identifier] = factory
    }

    public func produceBoard(identifier: BoardID) -> ActivatableBoard? {
        if let boardFactory = container[identifier] {
            return boardFactory(identifier)
        } else if let board = externalProducer?.produceBoard(identifier: identifier) {
            return board
        } else {
            return nil
        }
    }

    public func matchBoard(withIdentifier identifier: BoardID, to anotherIdentifier: BoardID) -> ActivatableBoard? {
        if let boardFactory = container[identifier] {
            return boardFactory(anotherIdentifier)
        } else if let board = externalProducer?.matchBoard(withIdentifier: identifier, to: anotherIdentifier) {
            return board
        } else {
            return nil
        }
    }
}
