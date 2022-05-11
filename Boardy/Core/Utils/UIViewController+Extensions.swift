//
//  UIViewController+Extensions.swift
//  Boardy
//
//  Created by CONGNC7 on 11/05/2022.
//

import Foundation
import UIKit

extension UIViewController {
    var allPresentedViewControllers: [UIViewController] {
        if let presented = presentedViewController {
            return [presented] + presented.allPresentedViewControllers
        } else {
            return []
        }
    }

    var allPresentingViewControllers: [UIViewController] {
        if let presenting = presentingViewController {
            return [presenting] + presenting.allPresentingViewControllers
        } else {
            return []
        }
    }
}

extension UITabBarController {
    @objc override var topMostViewController: UIViewController {
        selectedViewController?.topMostViewController ?? self
    }
}

extension UINavigationController {
    @objc override var topMostViewController: UIViewController {
        topViewController?.topMostViewController ?? self
    }
}

extension UIViewController {
    @objc var topMostViewController: UIViewController {
        self
    }
}

extension UIViewController {
    var topPresentedViewController: UIViewController {
        allPresentedViewControllers.last?.topMostViewController ?? self
    }
}
