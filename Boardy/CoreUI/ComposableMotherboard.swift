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

        // ComposableMotherboard should forward activation flow to previous Motherboard, so skip register activation flow here. Will setup this flow in getComposableMotherboard function.

        registerGeneralFlow { [weak self] in
            self?.handleUIElementAction($0)
        }
    }

    func handleUIElementAction(_ action: UIElementAction) {
        composableInterface?.putUIElementAction(action)
    }
}
