//
//  InstallableBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/17/20.
//

import Foundation
import UIKit

public protocol InstallableBoard: OriginalBoard {
    var rootViewController: UIViewController { get }

    func installIntoRootViewController(_ rootViewController: UIViewController)
}

extension InstallableBoard {
    public var rootViewController: UIViewController {
        guard let viewController = root as? UIViewController else {
            assertionFailure("\(String(describing: self)) \n🔥 [CONTEXT NOT FOUND] Could not access `rootViewController` because it is not set or deallocated. Make sure install \(self) into a `rootViewController` before accessing it.")
            return UIViewController()
        }
        return viewController
    }

    public func installIntoRootViewController(_ rootViewController: UIViewController) {
        installIntoRoot(rootViewController)
    }

    public var navigationController: UINavigationController {
        if let controller = rootViewController as? UINavigationController {
            return controller
        } else if let controller = rootViewController.navigationController {
            return controller
        } else if let tabBarController = rootViewController as? UITabBarController, let controller = tabBarController.selectedViewController as? UINavigationController {
            return controller
        } else {
            assertionFailure("\(String(describing: self)) \n🔥 [CONTEXT NOT FOUND] Could not access `navigationController` because it is not set or deallocated or `rootViewController` doesn't have `UINavigationController`. Make sure install \(self) into a `rootViewController` which based on `UINavigationController` before accessing it.")
            return UINavigationController()
        }
    }

    public var tabBarController: UITabBarController {
        if let controller = rootViewController as? UITabBarController {
            return controller
        } else if let controller = rootViewController.tabBarController {
            return controller
        } else if let navigationController = rootViewController as? UINavigationController, let controller = navigationController.tabBarController {
            return controller
        } else {
            assertionFailure("\(String(describing: self)) \n🔥 [CONTEXT NOT FOUND] Could not access `tabBarController` because it is not set or deallocated or `rootViewController` doesn't have `UITabBarController`. Make sure install \(self) into a `rootViewController` which based on `UITabBarController` before accessing it.")
            return UITabBarController()
        }
    }
}

public protocol WindowInstallableBoard: OriginalBoard {
    var window: UIWindow { get }

    func installIntoWindow(_ window: UIWindow)
}

extension WindowInstallableBoard {
    public var window: UIWindow {
        guard let current = root as? UIWindow else {
            assertionFailure("\(String(describing: self)) \n🔥 [CONTEXT NOT FOUND] Could not access `window` because it is not set or deallocated. Make sure install \(self) into a `window` before accessing it.")
            return UIWindow()
        }
        return current
    }

    public func installIntoWindow(_ window: UIWindow) {
        installIntoRoot(window)
    }
}

extension InstallableBoard where Self: WindowInstallableBoard {
    public var rootViewController: UIViewController {
        if let currentWindow = root as? UIWindow, let viewController = currentWindow.rootViewController {
            return viewController
        } else if let viewController = root as? UIViewController {
            return viewController
        } else {
            assertionFailure("\(String(describing: self)) \n🔥 [CONTEXT NOT FOUND] Could not access `rootViewController` because it is not set or deallocated. Make sure install \(self) into a `rootViewController` before accessing it.")
            return UIViewController()
        }
    }
}
