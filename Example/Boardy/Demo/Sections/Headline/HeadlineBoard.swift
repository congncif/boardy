//
//  Headline2Board.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/22/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Boardy
import Foundation
import Resolver
import UIComposable
import UIKit

final class HeadlineBoard: Board, GuaranteedBoard {
    typealias InputType = Any

    @LazyInjected var builder: HeadlineBuildable

    init() {
        super.init(identifier: .headline)
    }

    func activate(withGuaranteedInput input: Any) {
        let viewController = builder.build()
        viewController.delegate = self

        let element = UIElement(identifier: identifier, contentViewController: viewController)
        putToComposer(elementAction: .update(element: element))
    }
}

extension HeadlineBoard: HeadlineDelegate {
    func returnRoot() {
        sendAction(.return)
    }

    func gotoNext() {
        nextToBoard(.dashboard)
    }
}
