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
import UIComposable
import UIKit

final class FeaturedBoard: Board, GuaranteedBoard {
    typealias InputType = Any?

    @LazyInjected var builder: FeaturedBuildable

    init() {
        super.init(identifier: .random())
    }

    func activate(withGuaranteedInput _: Any?) {
        let viewController = builder.build()
        viewController.delegate = self

        let element = UIElement(identifier: identifier, contentViewController: viewController)
        putToComposer(elementAction: .update(element: element))
    }
}

extension FeaturedBoard: FeaturedDelegate {
    func removeFeaturedContent() {
        putToComposer(elementAction: .removeContent(identifier: identifier.rawValue))
    }

    func refreshHeadline() {
//        interactWithOtherBoard(command: HeadlineCommand.refresh(label: "BOARDY!!"))
        headline.refresh(label: "Board!!")
    }
}

// MARK: - Define in scope

extension ActivatableBoard {
    var headline: HeadlineActivatable {
        headline(identifier: .headline)
    }
}
