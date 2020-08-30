//
//  HeadlineBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/30/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Boardy
import Foundation
import UIKit

final class HeadlineUIBoard: UIViewControllerOpenBoard {
    typealias InputType = Any?

    private let builder: HeadlineBuildable

    init(builder: HeadlineBuildable) {
        self.builder = builder
        super.init()
    }

    override func buildInterface(withGuaranteedInput input: Any?) -> UIViewController? {
        let viewController = builder.build()
        viewController.delegate = self
        return viewController
    }
}

extension HeadlineUIBoard: HeadlineDelegate {}
