//
//  FeaturedUIBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/30/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Boardy
import Foundation
import UIKit

final class FeaturedUIBoard: UIViewControllerOpenBoard {
    private let builder: FeaturedBuildable

    init(builder: FeaturedBuildable) {
        self.builder = builder
        super.init(identifier: .featured)
    }

    override func buildInterface(withGuaranteedInput input: Any?) -> UIViewController? {
        builder.build()
    }
}

extension FeaturedUIBoard: FeaturedDelegate {}
