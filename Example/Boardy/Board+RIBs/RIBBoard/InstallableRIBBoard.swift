//
//  InstallableRIBBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/8/20.
//

import Foundation
import RIBs
import UIKit

public protocol InstallableRIBBoard: InstallableBoard {
    var rootRouter: ViewableRouting { get }

    func install(into rootRouter: ViewableRouting)
}

extension InstallableRIBBoard {
    public var rootViewController: UIViewController {
        rootRouter.viewControllable.uiviewController
    }

    public func install(into rootRouter: ViewableRouting) {
        install(into: rootRouter.viewControllable.uiviewController)
    }
}

extension ViewableRouting {
    public func install(board: InstallableRIBBoard) {
        board.install(into: self)
    }
}
