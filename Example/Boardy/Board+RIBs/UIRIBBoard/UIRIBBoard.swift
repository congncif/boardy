//
//  UIRIBBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/8/20.
//

import Foundation
import RIBs
import RxRelay
import RxSwift
import UIKit

open class UIRIBBoard: RIBBoard, UILinkableRIBBoard, UIActivatableBoard, UIPluggableBoard {
    public var version: Int = 0
    public var isVisible: Bool = true
    public var options: Any?

    weak var contentViewController: UIViewController?

    open var pluggableInterface: UIViewController {
        assert(contentViewController != nil, "Content view controller was not set.")
        return contentViewController ?? UIViewController()
    }

    private let changeRelay = PublishRelay<UIActivatableBoard>()

    open var changeSequence: Observable<UIActivatableBoard> {
        return changeRelay.asObservable()
    }

    open func reload() {
        version += 1
        changeRelay.accept(self)
    }

    open func buildInterface(withOption option: Any?) -> ViewableRouting? {
        assertionFailure("Abstract method should be overridden in subclass")
        return nil
    }

    open func linkInterface(_ viewRouter: ViewableRouting) {
        rootRouter.attachChild(viewRouter)
        contentViewController = viewRouter.viewControllable.uiviewController
    }
}
