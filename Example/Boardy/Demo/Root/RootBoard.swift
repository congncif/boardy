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

// Wrap an array to pass LazyInjected convention of Resolver.
struct RootBoardCollection {
    let boards: [ActivatableBoard]
}

final class RootBoard: ContinuousBoard, GuaranteedBoard {
    typealias InputType = [UIApplication.LaunchOptionsKey: Any]?

    @LazyInjected var builder: RootBuildable
    @LazyInjected var boardCollection: RootBoardCollection

    // To defer initializing sub-boards, use mainboard instead of motherboard (default) for activation related activities.
    private lazy var mainboard: FlowMotherboard = {
        motherboard.extended(boards: boardCollection.boards)
    }()

    init(motherboard: AppMotherboard) {
        super.init(identifier: .root, motherboard: motherboard)
    }

    func activate(withGuaranteedInput input: [UIApplication.LaunchOptionsKey: Any]?) {
        let viewController = builder.build()
        viewController.delegate = self
        window.setRootViewController(viewController)
    }
}

extension RootBoard: RootDelegate {
    func didReadyToShow() {
        mainboard.activateBoard(.login)
    }

    func startApplication() {
        mainboard.activateBoard(.login)
    }
}
