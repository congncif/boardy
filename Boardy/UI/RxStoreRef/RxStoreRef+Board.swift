//
//  RxStoreRef+Board.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/15/20.
//

import Foundation

extension Board: ObjectReferenceStorable {}

// MARK: - UIMotherboard pair

public typealias FlowUIMotherboardObject = FlowUIMotherboard & ObjectReferenceStorable

extension Board {
    public func pairUIMotherboard(_ uimotherboard: FlowUIMotherboardObject, with viewController: UIViewController) {
        uimotherboard.registerGeneralFlow { [weak self] in
            self?.sendFlowAction($0)
        }
        uimotherboard.install(into: viewController)
        uimotherboard.pairWith(object: viewController)
    }
}
