//
//  ModernContinuousBoard+Composable.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/26/21.
//

import Foundation
import UIComposable

extension ModernContinuableBoard {
    @discardableResult
    public func mountComposableMotherboard(to interface: ComposableInterfaceObject,
                                           configurationBuilder: (FlowComposableMotherboard) -> Void = { _ in }) -> FlowComposableMotherboard {
        let newBoard = produceComposableMotherboard()
        configurationBuilder(newBoard)

        newBoard.putIntoContext(interface)
        newBoard.connect(to: interface)

        return newBoard
    }

    func produceComposableMotherboard() -> FlowComposableMotherboard {
        producer.produceComposableMotherboard(identifier: identifier.appending("composable-main"), from: self)
    }
}

// MARK: - Attachable

extension ModernContinuableBoard {
    @discardableResult
    public func attachComposableMotherboard(to interface: AttachableObject & ComposableInterface,
                                            configurationBuilder: (FlowComposableMotherboard) -> Void = { _ in }) -> FlowComposableMotherboard {
        let newBoard = produceComposableMotherboard()
        configurationBuilder(newBoard)

        newBoard.putIntoContext(interface)
        newBoard.connect(to: interface)
        interface.attachObject(newBoard)

        return newBoard
    }
}
