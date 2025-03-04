//
//  ActivableBoardProducer.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 6/13/21.
//

import Foundation

public protocol ActivatableBoardProducer {
    func produceBoard(identifier: BoardID) -> ActivatableBoard?
    func produceGatewayBoard(identifier: BoardID) -> ActivatableBoard?
    func matchBoard(withIdentifier identifier: BoardID, to anotherIdentifier: BoardID) -> ActivatableBoard?
}

public extension ActivatableBoardProducer {
    func matchBoard(withIdentifier _: BoardID, to anotherIdentifier: BoardID) -> ActivatableBoard? {
        produceBoard(identifier: anotherIdentifier)
    }

    func produceGatewayBoard(identifier _: BoardID) -> ActivatableBoard? { nil }
}

@available(*, deprecated, renamed: "ActivatableBoardProducer", message: "The protocol was renamed to ActivatableBoardProducer to fix typo")
public typealias ActivableBoardProducer = ActivatableBoardProducer
