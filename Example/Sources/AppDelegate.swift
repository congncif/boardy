//
//  AppDelegate.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Copyright © 2024 [iF] Solution. All rights reserved.
//

import Boardy
import Foundation
import SiFUtilities
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, willFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        true
    }

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIViewController.swizzling()
        launchPlugins()
        return true
    }
}
