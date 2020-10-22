//
//  FeaturedBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/22/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Boardy
import Foundation
import Resolver
import UIKit

final class FeaturedBoard: Board, GuaranteedBoard {
    typealias InputType = Any?

    @LazyInjected var builder: FeaturedBuildable

    init() {
        super.init()
    }

    func activate(withGuaranteedInput input: Any?) {
        let viewController = builder.build()
        viewController.delegate = self

        let element = UIElement(identifier: identifier, contentViewController: viewController)
        putToComposer(elementAction: .update(element: element))
    }
}

extension FeaturedBoard: FeaturedDelegate {}
