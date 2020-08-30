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
        super.init()
    }

    override func buildInterface(withGuaranteedInput input: Any?) -> UIViewController? {
        let featured = builder.build()
        featured.delegate = self
        return featured
    }
}

extension FeaturedUIBoard: FeaturedDelegate {
    func featuredContentDidUpdate() {
        reload()
    }
}
