//
//  FeaturedUIBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/30/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Boardy
import Foundation
import Resolver
import UIKit

final class FeaturedUIBoard: UIBoard, UIGuaranteedViewControllerBoard {
    typealias InputType = Any?

    @LazyInjected var builder: FeaturedBuildable

    init() {
        super.init()
    }

    func buildInterface(withGuaranteedInput input: Any?) -> UIViewController? {
        let featured = builder.build()
        featured.delegate = self
        return featured
    }
}

extension FeaturedUIBoard: FeaturedDelegate {}
