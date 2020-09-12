//
//  ContainerRIBBoard.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 9/12/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Foundation
import RIBs
import RxCocoa
import RxSwift

open class ContainerBoard: ContinuousRIBBoard {
    private let manager: UIMotherboardManager = UIMotherboardManager()

    public func attachUIMotherboard(_ uimotherboard: FlowUIMotherboard, untilDone viewController: UIViewController) {
        board(self, attach: uimotherboard, using: manager, untilDone: viewController)
    }
}

open class ContainerUIRIBBoard: ContinuousUIRIBBoard {
    private let manager: UIMotherboardManager = UIMotherboardManager()

    public func attachUIMotherboard(uimotherboard: FlowUIMotherboard, untilDone viewController: UIViewController) {
        board(self, attach: uimotherboard, using: manager, untilDone: viewController)
    }
}

// MARK: - UIMotherboardManager

final class UIMotherboardManager {
    private var uimotherboardRoom: [AnyHashable: FlowUIMotherboard] = [:]

    private let disposeBag = DisposeBag()

    func attachUIMotherboard(_ uimotherboard: FlowUIMotherboard, untilDone viewController: UIViewController) {
        let key = ObjectIdentifier(viewController)
        uimotherboardRoom[key] = uimotherboard

        viewController.rx.deallocated
            .subscribe(onNext: { [weak self] in
                self?.uimotherboardRoom.removeValue(forKey: key)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Function Decomposition

private func board(_ board: RIBBoard, attach uimotherboard: FlowUIMotherboard, using manager: UIMotherboardManager, untilDone viewController: UIViewController) {
    uimotherboard.registerGeneralFlow { [weak board] in
        board?.sendFlowAction($0)
    }
    uimotherboard.install(into: viewController)
    manager.attachUIMotherboard(uimotherboard, untilDone: viewController)
}
