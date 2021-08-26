//
//  ModernContinuousBoard+Composable.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/26/21.
//

import Foundation
import UIComposable

extension ModernContinuousBoard {
    @discardableResult
    public func mountComposableMotherboard(to interface: ComposableInterfaceObject,
                                           configurationBuilder: (FlowComposableMotherboard) -> Void = { _ in }) -> FlowComposableMotherboard {
        let newBoard = producer.produceComposableMotherboard(identifier: identifier.appending("composable-main"), from: self)
        configurationBuilder(newBoard)

        newBoard.installIntoRoot(interface)
        newBoard.connect(to: interface)

        return newBoard
    }

    @discardableResult
    public func attachComposableMotherboard(to interface: AttachableObject & ComposableInterface,
                                            configurationBuilder: (FlowComposableMotherboard) -> Void = { _ in }) -> FlowComposableMotherboard {
        let newBoard = producer.produceComposableMotherboard(identifier: identifier.appending("composable-main"), from: self)
        configurationBuilder(newBoard)

        newBoard.installIntoRoot(interface)
        newBoard.connect(to: interface)
        interface.attachObject(newBoard)

        return newBoard
    }

    func produceComposableMotherboard() -> FlowComposableMotherboard {
        producer.produceComposableMotherboard(identifier: identifier.appending("composable-main"), from: self)
    }
}
