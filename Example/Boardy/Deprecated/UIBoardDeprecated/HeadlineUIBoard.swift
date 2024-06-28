//
//  HeadlineBoard.swift
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
final class HeadlineUIBoard: UIBoard, UIGuaranteedViewControllerBoard {
    typealias InputType = Any?

    @LazyInjected var builder: HeadlineBuildable

    init() {
        super.init()
    }

    func buildInterface(withGuaranteedInput _: Any?) -> UIViewController? {
        let viewController = builder.build()
        viewController.delegate = self
        return viewController
    }
}

extension HeadlineUIBoard: HeadlineDelegate {
    func returnRoot() {
        sendAction(.return)
    }

    func gotoNext() {
        nextToBoard(.dashboard)
    }
}
