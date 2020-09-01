//
//  FeaturedBuilder.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/30/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import UIKit
import SiFUtilities

struct FeaturedBuilder: FeaturedBuildable {
    func build() -> FeaturedController {
        FeaturedViewController.instantiateFromStoryboard()
    }
}
