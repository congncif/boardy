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

final class RootBoard: ContinuousBoard, GuaranteedBoard {
    typealias InputType = [UIApplication.LaunchOptionsKey: Any]?

    @LazyInjected var builder: RootBuildable

    init(motherboard: AppMotherboard) {
        super.init(identifier: .root, motherboard: motherboard)
    }

    func activate(withGuaranteedInput _: [UIApplication.LaunchOptionsKey: Any]?) {
        let viewController = builder.build()
        viewController.delegate = self
        window.setRootViewController(viewController)
    }
}

extension RootBoard: RootDelegate {
    func didReadyToShow() {
        motherboard.activateBoard(.login)
    }

    func startApplication() {
        motherboard.activateBoard(.login)
    }
}
