//
//  DashboardBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/27/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Boardy
import Foundation
import SiFUtilities
import UIKit

final class DashboardBoard: Board, GuaranteedBoard {
    typealias InputType = Any?

    private let builder: DashboardBuildable

    init(builder: DashboardBuildable) {
        self.builder = builder
        super.init(identifier: .dashboard)
    }

    func activate(withGuaranteedInput input: Any?) {
        let dashboard = builder.build()
        rootViewController.topPresentedViewController.show(dashboard)
    }
}

extension DashboardBoard: DashboardDelegate {}
