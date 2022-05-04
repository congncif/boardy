//
//  ActivableBoardProducer.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 6/13/21.
//

import Foundation

public protocol ActivableBoardProducer {
    func produceBoard(identifier: BoardID) -> ActivatableBoard?
    func matchBoard(withIdentifier identifier: BoardID, to anotherIdentifier: BoardID) -> ActivatableBoard?
}

public extension ActivableBoardProducer {
    func matchBoard(withIdentifier _: BoardID, to anotherIdentifier: BoardID) -> ActivatableBoard? {
        produceBoard(identifier: anotherIdentifier)
    }
}
