//
//  UIBoardManager.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/12/20.
//

import Foundation
import RxCocoa
import RxSwift

// Another branch of UIMotherboard management which using RxCocoa instead of runtime associated property.

open class ContainerBoard: ContinuousBoard {
    private let manager: UIMotherboardManager = UIMotherboardManager()

    public func attachUIMotherboard(_ uimotherboard: FlowUIMotherboard, untilDone viewController: UIViewController) {
        board(self, attach: uimotherboard, using: manager, untilDone: viewController)
    }
}

open class ContainerUIBoard<OptionType>: ContinuousUIBoard<OptionType> {
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

private func board(_ board: Board, attach uimotherboard: FlowUIMotherboard, using manager: UIMotherboardManager, untilDone viewController: UIViewController) {
    uimotherboard.registerGeneralFlow { [weak board] in
        board?.sendFlowAction($0)
    }
    uimotherboard.install(into: viewController)
    manager.attachUIMotherboard(uimotherboard, untilDone: viewController)
}
