//
//  Board.swift
//  
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation
import RIBs
import UIKit

open class Board: InstallableBoard, IdentifiableBoard {
    public let identifier: String

    public weak var delegate: BoardDelegate?

    private weak var rootRouter: ViewableRouting?
    private lazy var placeholderRouter: PlaceholderRouting = PlaceholderBuilder().build()

    public init(identifier: String = UUID().uuidString) {
        self.identifier = identifier
    }

    open func install(into rootRouter: ViewableRouting) {
        self.rootRouter = rootRouter
    }

    open func install(into rootViewController: UIViewController) {
        placeholderRouter.injectViewController(rootViewController)
    }

    public var router: ViewableRouting {
        guard let internalRouter = rootRouter else {
            return placeholderRouter
        }
        return internalRouter
    }
}
