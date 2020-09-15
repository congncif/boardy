//
//  UIBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

/// Unlike normal Board, an UIBoard must be activated(built & linked) before using.

open class UIBoard: Board, UIChangableBoard {
    public var version: Int = 0
    public var isVisible: Bool = true
    public var options: Any?

    weak var contentViewController: UIViewController?

    open var pluggableInterface: UIViewController {
        assert(contentViewController != nil, "Content view controller was not set.")
        return contentViewController ?? UIViewController()
    }

    // Changable

    private let changeRelay = PublishRelay<UIChangableBoard>()

    open var changeSequence: Observable<UIChangableBoard> {
        return changeRelay.asObservable()
    }

    open func reload() {
        version += 1
        changeRelay.accept(self)
    }
}

extension UILinkableViewControllerBoard where Self: UIBoard {
    public func linkInterface(_ viewController: UIViewController) {
        rootViewController.addChild(viewController)
        contentViewController = viewController
    }
}
