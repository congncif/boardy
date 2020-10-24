//
//  ComposableMotherboard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/22/20.
//

import Foundation
import UIComposable

public protocol ComposableMotherboardType: MotherboardType {
    func connect(to interface: ComposableInterface)
}

public typealias FlowComposableMotherboard = ComposableMotherboardType & FlowManageable

open class ComposableMotherboard: Motherboard, ComposableMotherboardType {
    var composableInterface: ComposableInterface?

    public func connect(to interface: ComposableInterface) {
        if let object = interface as? ComposableInterfaceObject {
            composableInterface = UIComposableAdapter(object: object)
        } else {
            composableInterface = interface
        }
    }

    override func registerDefaultFlows() {
        forwardActionFlow(to: self)

        registerGeneralFlow { [weak self] in
            self?.interactWithBoard(command: $0)
        }

        registerGeneralFlow { [weak self] in
            self?.handleUIElementAction($0)
        }
    }

    func handleUIElementAction(_ action: UIElementAction) {
        composableInterface?.putUIElementAction(action)
    }
}

extension IdentifiableBoard {
    public func putToComposer(elementAction: UIElementAction) {
        sendToMotherboard(data: elementAction)
    }
}

extension Board {
    /// Create a new ComposableMotherboard which use internal a board. Chain of action will be set up.
    public func getComposableMotherboard(identifier: BoardID = UUID().uuidString, elementBoards: [ActivatableBoard] = []) -> ComposableMotherboard {
        let motherboard = ComposableMotherboard(identifier: identifier, boards: elementBoards)
        motherboard.forwardActionFlow(to: self)
        motherboard.forwardActivationFlow(to: self)
        return motherboard
    }
}
