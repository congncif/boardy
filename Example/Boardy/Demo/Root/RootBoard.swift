//
//  RootBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/13/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Boardy
import Foundation
import Resolver
import SiFUtilities
import UIKit

final class RootBoard: Board, GuaranteedBoard {
    typealias InputType = [UIApplication.LaunchOptionsKey: Any]?

    @LazyInjected var appMainBoard: AppMotherboard
    @LazyInjected var builder: RootBuildable

    private weak var window: UIWindow?

    func install(into newWindow: UIWindow?) {
        window = newWindow
    }

    init() {
        super.init(identifier: .root)
    }

    func activate(withGuaranteedInput input: [UIApplication.LaunchOptionsKey: Any]?) {
        let viewController = builder.build()
        viewController.delegate = self

        viewController.attachMotheboard(appMainBoard)

        activeWindow.setRootViewController(viewController)
    }
}

extension RootBoard {
    private var activeWindow: UIWindow {
        if let window = self.window {
            return window
        } else {
            return rootViewController.view.window!
        }
    }
}

extension RootBoard: RootDelegate {
    func didReadyToShow() {
        appMainBoard.activateBoard(.login)
    }

    func startApplication() {
        appMainBoard.activateBoard(.login)
    }
}
