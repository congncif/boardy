//
//  RxStoreRef+Board.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/15/20.
//

import Foundation
import UIKit

// MARK: - Board + pair

public typealias FlowUIMotherboardObject = FlowUIMotherboard & ReferenceStorableObject

extension Board {
    public func pairInstallWith(object: NSObject) {
        installIntoRoot(object)
        pairWith(object: object)
    }

    public func pairInstallUIMotherboard(_ uimotherboard: FlowUIMotherboardObject, with other: NSObject) {
        uimotherboard.registerGeneralFlow { [weak self] in
            self?.sendFlowAction($0)
        }
        uimotherboard.installIntoRoot(other)
        uimotherboard.pairWith(object: other)
    }

    public func plugPairUIMotherboard(_ uimotherboard: FlowUIMotherboardObject, with viewController: UIViewControllerBoardInterface, activateOptions: [BoardID: Any] = [:], defaultOption: Any? = nil) {
        pairInstallUIMotherboard(uimotherboard, with: viewController)
        uimotherboard.activateAllUIBoards(withOptions: activateOptions, defaultOption: defaultOption)
        viewController.justPlugUIMotherboard(uimotherboard)
    }

    public func plugPairUIMotherboard(_ uimotherboard: FlowUIMotherboardObject, with viewController: UIViewControllerBoardInterface, modelOptions: [BoardInputModel], defaultOption: Any? = nil) {
        pairInstallUIMotherboard(uimotherboard, with: viewController)
        uimotherboard.activateAllUIBoards(models: modelOptions, defaultOption: defaultOption)
        viewController.justPlugUIMotherboard(uimotherboard)
    }
}

extension UIBoardInterface where Self: ReactiveDisposableObject {
    public func justPlugUIMotherboard(_ board: UIMotherboardType) {
        board.plug(in: self, with: freshDisposeBag)
    }
}

// MARK: - Board + Compatible

import RxSwift

extension Board: ReferenceStorableObject {}

extension Board: ReactiveCompatible {}

extension Board: ReactiveDisposableObject {}
