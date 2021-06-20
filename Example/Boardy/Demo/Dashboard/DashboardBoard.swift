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
import SiFUtilities
import UIKit

// protocol DashboardElementManufacturing {
//    func getElementBoards() -> [UIActivatableBoard]
// }

final class DashboardBoard: ContinuousBoard, GuaranteedBoard {
    typealias InputType = Any?

    @LazyInjected var builder: DashboardBuildable
//    @LazyInjected var elementFactory: DashboardElementManufacturing

    init() {
        super.init(identifier: .dashboard, motherboard: Motherboard())

        motherboard.registerChainFlow(matchedIdentifiers: [.headline], target: self)
            .handle(outputType: Int.self) { _, output in
                print(output)
            }
            .eventuallySkipHandling()
        
        motherboard.registerGuaranteedFlow(matchedIdentifiers: [.headline], target: self, uniqueOutputType: String.self) { (target, output) in
            print(output)
        }
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

        contentBoard.attachInstall(to: dashboard)
//        contentBoard.attach(to: dashboard)

        contentBoard.connect(to: dashboard)

        contentBoard.activateAllBoards()
    }
}

extension DashboardBoard: DashboardDelegate {
    func changePlugins(viewController: UIViewController) {
//        rootViewController.returnHere()
//        complete()
        guard let contentBoard: FlowComposableMotherboard = viewController.firstAttachedObject() else {
            return
        }

        let featured = FeaturedBoard()

        contentBoard.addBoard(featured)

        featured.activate(withGuaranteedInput: nil)
    }
}
