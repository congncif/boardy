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

// protocol DashboardElementManufacturing {
//    func getElementBoards() -> [UIActivatableBoard]
// }

final class DashboardBoard: ContinuousBoard, GuaranteedBoard {
    typealias InputType = Any?

    @LazyInjected var builder: DashboardBuildable
//    @LazyInjected var elementFactory: DashboardElementManufacturing

    private let disposeBag = DisposeBag()

    init() {
        super.init(identifier: .dashboard)
    }

    func activate(withGuaranteedInput input: Any?) {
        let dashboard = builder.build()
        dashboard.delegate = self
        rootViewController.topPresentedViewController.show(dashboard)

        /*
         /// 4 steps to set up an UIMotherboard

         // Step 1: Init UIMotherboard.
         let drawingBoard = getUIMotherboard(elementBoards: elementFactory.getElementBoards())

         // Step 2: attach & install UIMotherboard to root.
         drawingBoard.pairInstallWith(object: dashboard)

         // Step 3: Activate all available boards in Motherboard.
         drawingBoard.activateAllUIBoards()

         // Step 4: Plug UIMotherboard to BoardInterface.
         drawingBoard.justPlug(in: dashboard)
         */

        let headline = HeadlineBoard()

        let contentBoard = getComposableMotherboard(elementBoards: [headline])

        contentBoard.pairInstallWith(object: dashboard)
//        contentBoard.attach(to: dashboard)

        contentBoard.connect(to: dashboard)

        contentBoard.activateAllBoards()
    }
}

extension DashboardBoard: DashboardDelegate {
    func changePlugins(viewController: UIViewController) {
        guard let contentBoard: FlowComposableMotherboard = viewController.pairedObject() else {
            return
        }

        let featured = FeaturedBoard()

        contentBoard.addBoard(featured)

        featured.activate()
    }
}
