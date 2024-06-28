//
//  HeadlineBuilder.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/30/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import SiFUtilities
import UIKit

struct HeadlineBuilder: HeadlineBuildable {
    func build() -> HeadlineController {
        HeadlineViewController.instantiateFromStoryboard()
    }
}
