//
//  ModernContinuousBoard+Composable.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/26/21.
//

import Foundation
import UIComposable

public extension ModernContinuableBoard {
    @discardableResult
    func mountComposableMotherboard(
        to interface: ComposableInterfaceObject,
        configurationBuilder: (FlowComposableMotherboard) -> Void = { _ in }
    ) -> FlowComposableMotherboard {
        let newBoard = produceComposableMotherboard()
        configurationBuilder(newBoard)

        newBoard.putIntoContext(interface)
        newBoard.connect(to: interface)

        return newBoard
    }

    @discardableResult
    func mountComposableMotherboard<Mainboard: FlowComposableMotherboard>(
        to interface: ComposableInterfaceObject,
        build: (ActivatableBoardProducer) -> Mainboard
    ) -> Mainboard {
        let newBoard = build(producer)

        newBoard.putIntoContext(interface)
        newBoard.connect(to: interface)

        return newBoard
    }

    internal func produceComposableMotherboard() -> FlowComposableMotherboard {
        producer.produceComposableMotherboard(identifier: identifier.appending("composable-main"), from: self)
    }
}

// MARK: - Attachable

public extension ModernContinuableBoard {
    @discardableResult
    func attachComposableMotherboard(
        to interface: AttachableObject & ComposableInterface,
        configurationBuilder: (FlowComposableMotherboard) -> Void = { _ in }
    ) -> FlowComposableMotherboard {
        let newBoard = mountComposableMotherboard(to: interface, configurationBuilder: configurationBuilder)
        interface.attachObject(newBoard)

        return newBoard
    }

    @discardableResult
    func attachComposableMotherboard<Mainboard: FlowComposableMotherboard>(
        to interface: AttachableObject & ComposableInterface,
        build: (ActivatableBoardProducer) -> Mainboard
    ) -> Mainboard {
        let newBoard = mountComposableMotherboard(to: interface, build: build)
        interface.attachObject(newBoard)
        return newBoard
    }
}
