//
//  RIBBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/8/20.
//

import Foundation
import RIBs
import UIKit

open class RIBBoard: IdentifiableBoard, InstallableRIBBoard {
    public let identifier: String
    public weak var delegate: BoardDelegate?

    private weak var currentRouter: ViewableRouting?
    private lazy var placeholderRouter: PlaceholderRouting = PlaceholderBuilder().build()

    public init(identifier: String = UUID().uuidString) {
        self.identifier = identifier
    }

    open func install(into rootRouter: ViewableRouting) {
        currentRouter = rootRouter
    }

    open func install(into rootViewController: UIViewController) {
        placeholderRouter.injectViewController(rootViewController)
    }

    public var rootRouter: ViewableRouting {
        guard let internalRouter = currentRouter else {
            return placeholderRouter
        }
        return internalRouter
    }

    public var rootViewController: UIViewController {
        rootRouter.viewControllable.uiviewController
    }
}

/*
 open class RIBBoard: IdentifiableBoard, InstallableRIBBoard {
     public let identifier: String
     public weak var delegate: BoardDelegate?

     private lazy var router: PlaceholderRouting = PlaceholderBuilder().build()

     public init(identifier: String = UUID().uuidString) {
         self.identifier = identifier
     }

     open func install(into rootViewController: UIViewController) {
         router.injectViewController(rootViewController)
     }

     public var rootRouter: ViewableRouting { router }
 }
 */
