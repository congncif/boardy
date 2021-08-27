//
//  Board+Attachable.swift
//  Boardy
//
//  Created by FOLY on 1/26/21.
//

import Foundation

extension NSObject: AttachableObject {}

extension Board: AttachableObject {}

extension ModernContinuableBoard {
    @discardableResult
    public func attachContinuousMotherboard(to context: AttachableObject,
                                            configurationBuilder: (FlowMotherboard) -> Void = { _ in }) -> FlowMotherboard {
        let newBoard = produceContinuousMotherboard()
        configurationBuilder(newBoard)

        newBoard.installIntoRoot(context)
        context.attachObject(newBoard)

        return newBoard
    }
}
