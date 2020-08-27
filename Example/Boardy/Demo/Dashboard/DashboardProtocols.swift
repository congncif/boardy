//
//  DashboardProtocols.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/27/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

protocol DashboardController: UIViewController {
    var delegate: DashboardDelegate? { get set }
}

protocol DashboardDelegate: AnyObject {}

protocol DashboardBuildable {
    func build() -> DashboardController
}
