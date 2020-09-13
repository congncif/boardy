//
//  RootBuilder.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/13/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import UIKit
import SiFUtilities

struct RootBuilder: RootBuildable {
    func build() -> RootController {
        RootViewController.instantiateFromStoryboard()
    }
}
