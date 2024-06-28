//
//  RootBuilder.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/13/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import SiFUtilities
import UIKit

struct RootBuilder: RootBuildable {
    func build() -> RootController {
        RootViewController.instantiateFromStoryboard()
    }
}
