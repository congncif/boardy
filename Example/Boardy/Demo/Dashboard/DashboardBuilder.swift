//
//  DashboardBuilder.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/27/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SiFUtilities

struct DashboardBuilder: DashboardBuildable {
    func build() -> DashboardController {
        DashboardViewController()
    }
}
