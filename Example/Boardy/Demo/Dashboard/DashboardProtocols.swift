//
//  DashboardProtocols.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/27/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Boardy
import UIKit

protocol DashboardController: UIViewController, UIBoardInterface, ComposableInterface {
    var delegate: DashboardDelegate? { get set }
}

protocol DashboardDelegate: AnyObject {}

protocol DashboardBuildable {
    func build() -> DashboardController
}
