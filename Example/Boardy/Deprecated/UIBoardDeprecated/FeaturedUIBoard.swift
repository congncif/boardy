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

// UIBoard is deprecated, use normal Board & ComposableMotherboard instead.
final class FeaturedUIBoard: UIBoard, UIGuaranteedViewControllerBoard {
    typealias InputType = Any?

    @LazyInjected var builder: FeaturedBuildable

    init() {
        super.init(identifier: .featured)
    }

    func buildInterface(withGuaranteedInput _: Any?) -> UIViewController? {
        let featured = builder.build()
        featured.delegate = self
        return featured
    }
}

extension FeaturedUIBoard: FeaturedDelegate {
    func refreshHeadline() {
        // code
    }

    func removeFeaturedContent() {
        // code
    }
}
