//
//  DashboardBuilder.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/27/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import SiFUtilities
import UIKit

struct DashboardBuilder: DashboardBuildable {
    func build() -> DashboardController {
        DashboardViewController()
    }
}
