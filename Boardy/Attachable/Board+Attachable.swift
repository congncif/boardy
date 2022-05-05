//
//  Board+Attachable.swift
//  Boardy
//
//  Created by FOLY on 1/26/21.
//

import Foundation

extension NSObject: AttachableObject {}

extension Board: AttachableObject {}

public extension ModernContinuableBoard {
    @discardableResult
    func attachContinuousMotherboard(to context: AttachableObject,
                                     configurationBuilder: (FlowMotherboard) -> Void = { _ in }) -> FlowMotherboard {
        let newBoard = mountContinuousMotherboard(to: context, configurationBuilder: configurationBuilder)
        context.attachObject(newBoard)
        return newBoard
    }

    @discardableResult
    func attachContinuousMotherboard<Mainboard: FlowMotherboard>(to context: AttachableObject, build: (ActivatableBoardProducer) -> Mainboard) -> Mainboard {
        let newBoard = mountContinuousMotherboard(to: context, build: build)
        context.attachObject(newBoard)
        return newBoard
    }
}
