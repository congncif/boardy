//
//  DashboardProtocols.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/27/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Boardy
import UIComposable
import UIKit

protocol DashboardController: UIViewController, ComposableInterface {
    var delegate: DashboardDelegate? { get set }
}

protocol DashboardDelegate: AnyObject {
    func changePlugins(viewController: UIViewController)
}

protocol DashboardBuildable {
    func build() -> DashboardController
}
