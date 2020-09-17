//
//  RootBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/13/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Boardy
import Foundation
import Resolver
import SiFUtilities
import UIKit

final class RootBoard: Board, GuaranteedBoard {
    typealias InputType = [UIApplication.LaunchOptionsKey: Any]?

    @LazyInjected var appMainBoard: AppMotherboard
    @LazyInjected var builder: RootBuildable

    init() {
        super.init(identifier: .root)
    }

    func activate(withGuaranteedInput input: [UIApplication.LaunchOptionsKey: Any]?) {
        let viewController = builder.build()
        viewController.delegate = self

        viewController.attachMotheboard(appMainBoard)

        window.setRootViewController(viewController)
    }
}

extension RootBoard: RootDelegate {
    func didReadyToShow() {
        appMainBoard.activateBoard(.login)
    }

    func startApplication() {
        appMainBoard.activateBoard(.login)
    }
}
