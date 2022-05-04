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

open class UIRIBBoard: RIBBoard, UIChangableBoard {
    public var version: Int = 0
    public var isVisible: Bool = true
    public var options: Any?

    weak var contentViewController: UIViewController?

    open var pluggableInterface: UIViewController {
        assert(contentViewController != nil, "Content view controller was not set.")
        return contentViewController ?? UIViewController()
    }

    private let changeRelay = PublishRelay<UIChangableBoard>()

    open var changeSequence: Observable<UIChangableBoard> {
        changeRelay.asObservable()
    }

    open func reload() {
        version += 1
        changeRelay.accept(self)
    }
}

public extension UILinkableRIBBoard where Self: UIRIBBoard {
    func linkInterface(_ viewRouter: ViewableRouting) {
        rootRouter.attachChild(viewRouter)
        contentViewController = viewRouter.viewControllable.uiviewController
    }
}
