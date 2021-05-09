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

protocol HeadlineBoardOutput: AnyObject {
    func receive(label: String)
}

final class HeadlineBoard: Board, GuaranteedBoard, GuaranteedInteractableBoard {
    typealias InputType = Any
    typealias Command = BoardCommand<String>

    @LazyInjected var builder: HeadlineBuildable

//    private lazy var adapter = HeadlineBoardOutputAdapter()

    private lazy var refreshBus = Bus<String>()

    init() {
        super.init(identifier: .headline)
    }

    func activate(withGuaranteedInput input: Any) {
        let viewController = builder.build()
        viewController.delegate = self

//        let contentAdapter = HeadlineInputAdapter(target: viewController)
//        adapter.connect(adapter: contentAdapter)

        let cable = TargetBusCable(target: viewController) { target, text in
            target.accept(label: text)
        }
        refreshBus.connect(cable)

        let element = UIElement(identifier: identifier, contentViewController: viewController)
        putToComposer(elementAction: .update(element: element))
    }

    func interact(guaranteedCommand: Command) {
        let value = guaranteedCommand.input
        refreshBus.transport(input: value)
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
