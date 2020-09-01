//
//  DashboardBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/27/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Boardy
import Foundation
import Resolver
import RxSwift
import SiFUtilities
import UIKit

final class DashboardBoard: SuperBoard, GuaranteedBoard {
    typealias InputType = Any?

    @LazyInjected var builder: DashboardBuildable

    private let disposeBag = DisposeBag()

    init(elementBoards: [UIActivatableBoard]) {
        let uicontainerBoard = UIMotherboard(uiboards: elementBoards)
        super.init(identifier: .dashboard, uimotherboard: uicontainerBoard)
    }

    func activate(withGuaranteedInput input: Any?) {
        let dashboard = builder.build()
        rootViewController.topPresentedViewController.show(dashboard)

        uimotherboard.activateAllUIBoards()
        uimotherboard.plug(in: dashboard, with: disposeBag)
    }
}

extension DashboardBoard: DashboardDelegate {}
