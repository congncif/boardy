//
//  HeadlineBuilder.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/30/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SiFUtilities

struct HeadlineBuilder: HeadlineBuildable {
    func build() -> HeadlineController {
        HeadlineViewController.instantiateFromStoryboard()
    }
}
