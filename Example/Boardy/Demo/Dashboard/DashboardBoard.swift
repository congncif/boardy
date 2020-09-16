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

final class DashboardBoard: ContinuousBoard, GuaranteedBoard {
    typealias InputType = Any?

    @LazyInjected var builder: DashboardBuildable

    @LazyInjected var headlineBoard: HeadlineUIBoard
    @LazyInjected var featuredBoard: FeaturedUIBoard

    private let disposeBag = DisposeBag()

    init() {
        super.init(identifier: .dashboard)
    }

    func activate(withGuaranteedInput input: Any?) {
        let dashboard = builder.build()
        rootViewController.topPresentedViewController.show(dashboard)

        /// 4 steps to set up an UIMotherboard

        // Step 1: Init UIMotherboard.
        let drawingBoard = UIMotherboard(uiboards: [headlineBoard, featuredBoard])

        // Step 2: attach & install UIMotherboard to root.
        pairInstallUIMotherboard(drawingBoard, with: dashboard)

        // Step 3: Activate all available boards in Motherboard.
        drawingBoard.activateAllUIBoards()

        // Step 4: Plug UIMotherboard to BoardInterface.
        dashboard.justPlugUIMotherboard(drawingBoard)

        // Or use single line setup below 😂
        // plugAttachUIMotherboard(drawingBoard, to: dashboard)
    }
}

extension DashboardBoard: DashboardDelegate {}
