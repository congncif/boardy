//
//  ComposingMotherboard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/22/20.
//

import Foundation

public protocol ComposingMotherboardType: MotherboardType {
    func connect(to interface: ComposableInterface)
}

public typealias FlowComposingMotherboard = ComposingMotherboardType & FlowManageable

open class ComposingMotherboard: Motherboard, ComposingMotherboardType {
    var composableInterface: ComposableInterface?

    public func connect(to interface: ComposableInterface) {
        if let object = interface as? ComposableInterfaceObject {
            composableInterface = UIComposableAdapter(object: object)
        } else {
            composableInterface = interface
        }
    }

    override public init(identifier: BoardID = UUID().uuidString, boards: [ActivatableBoard] = []) {
        super.init(identifier: identifier, boards: boards)

        // reset flows
        flows = []

        forwardActionFlow(to: self)

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
    /// Create a new ComposingMotherboard which use internal a board. Chain of action will be set up.
    public func getComposingMotherboard(identifier: BoardID = UUID().uuidString, elementBoards: [ActivatableBoard] = []) -> ComposingMotherboard {
        let motherboard = ComposingMotherboard(identifier: identifier, boards: elementBoards)
        motherboard.forwardActionFlow(to: self)
        motherboard.forwardActivationFlow(to: self)
        return motherboard
    }
}
