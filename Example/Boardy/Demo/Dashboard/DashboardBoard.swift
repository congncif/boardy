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

        motherboard.registerGuaranteedFlow(matchedIdentifiers: [.headline], target: self, uniqueOutputType: String.self) { _, output in
            print(output)
        }
    }

    func activate(withGuaranteedInput _: Any?) {
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
//
        let contentBoard = produceComposableMotherboard(elementBoards: [headline])
//
        contentBoard.putIntoContext(dashboard)
        dashboard.attachObject(contentBoard)

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

// Legacy support
extension Board {
    /// Create a new ComposableMotherboard which uses internally by a board. Chain of actions will be set up.
    func produceComposableMotherboard(identifier: BoardID = .random(),
                                      boardProducer: ActivableBoardProducer = NoBoardProducer(),
                                      elementBoards: [ActivatableBoard] = []) -> ComposableMotherboard {
        let motherboard = ComposableMotherboard(identifier: identifier, boardProducer: boardProducer, boards: elementBoards)
        // Setup chain of actions.
        motherboard.forwardActionFlow(to: self)

        // ComposableMotherboard should forward activation flow to previous Motherboard.
        motherboard.forwardActivationFlow(to: self)

        return motherboard
    }
}
