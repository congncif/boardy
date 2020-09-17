//
//  RIBBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/8/20.
//

import Foundation
import RIBs
import UIKit

open class RIBBoard: Board, InstallableRIBBoard {
    private lazy var placeholderRouter: PlaceholderRouting = PlaceholderBuilder().build()

    public var rootRouter: ViewableRouting {
        if let internalRouter = root as? ViewableRouting {
            return internalRouter
        } else if let viewController = root as? UIViewController {
            placeholderRouter.injectViewController(viewController)

        } else if let window = root as? UIWindow, let rootViewController = window.rootViewController {
            placeholderRouter.injectViewController(rootViewController)

        } else {
            assertionFailure("💔 Board was not installed. Install \(self) into a rootRouter before activating it.")
        }
        return placeholderRouter
    }

    public var rootViewController: UIViewController {
        rootRouter.viewControllable.uiviewController
    }

    open func installRootRouter(_ rootRouter: ViewableRouting) {
        installIntoRoot(rootRouter)
    }
}
