//
//  DashboardViewController.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 8/27/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Boardy
import UIKit

final class DashboardViewController: ListViewController, DashboardController {
    weak var delegate: DashboardDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
