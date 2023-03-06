//
//  UIViewController+Extensions.swift
//  Boardy
//
//  Created by CONGNC7 on 11/05/2022.
//

import Foundation
import UIKit

extension UIViewController {
    var boardy_allPresentedViewControllers: [UIViewController] {
        if let presented = presentedViewController {
            return [presented] + presented.boardy_allPresentedViewControllers
        } else {
            return []
        }
    }

    var boardy_allPresentingViewControllers: [UIViewController] {
        if let presenting = presentingViewController {
            return [presenting] + presenting.boardy_allPresentingViewControllers
        } else {
            return []
        }
    }
}

extension UITabBarController {
    @objc override var boardy_topMostViewController: UIViewController {
        selectedViewController?.boardy_topMostViewController ?? self
    }
}

extension UINavigationController {
    @objc override var boardy_topMostViewController: UIViewController {
        topViewController?.boardy_topMostViewController ?? self
    }
}

extension UIViewController {
    @objc var boardy_topMostViewController: UIViewController {
        self
    }
}

extension UIViewController {
    var boardy_topPresentedViewController: UIViewController {
        boardy_allPresentedViewControllers.last?.boardy_topMostViewController ?? self
    }
}
