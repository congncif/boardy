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

open class UIBoard: Board, UIPluggableBoard {
    public var version: Int = 0
    public var isVisible: Bool = true
    public var options: Any?

    weak var contentViewController: UIViewController?

    open var pluggableInterface: UIViewController {
        assert(contentViewController != nil, "Content view controller was not set.")
        return contentViewController ?? UIViewController()
    }
}

open class UIViewControllerLinkableBoard: UIBoard, UIActivatableBoard, UILinkableViewControllerBoard {
    private let changeRelay = PublishRelay<UIActivatableBoard>()

    open var changeSequence: Observable<UIActivatableBoard> {
        return changeRelay.asObservable()
    }

    open func reload() {
        version += 1
        changeRelay.accept(self)
    }

    open func buildInterface(withOption option: Any?) -> UIViewController? {
        assertionFailure("Abstract method should be overridden in subclass")
        return nil
    }

    open func linkInterface(_ viewController: UIViewController) {
        rootViewController.addChild(viewController)
        contentViewController = viewController
    }
}

open class UIViewControllerGuaranteedBoard<OptionType>: UIBoard, UIActivatableBoard, UIGuaranteedViewControllerBoard {
    public typealias InputType = OptionType

    private let changeRelay = PublishRelay<UIActivatableBoard>()

    open var changeSequence: Observable<UIActivatableBoard> {
        return changeRelay.asObservable()
    }

    open func reload() {
        version += 1
        changeRelay.accept(self)
    }

    open func buildInterface(withGuaranteedInput input: OptionType) -> UIViewController? {
        assertionFailure("Abstract method should be overridden in subclass")
        return nil
    }

    open func linkInterface(_ viewController: UIViewController) {
        rootViewController.addChild(viewController)
        contentViewController = viewController
    }
}

// This special board accept every input but might not handle all.
public typealias UIViewControllerOpenBoard = UIViewControllerGuaranteedBoard<Any?>

public typealias UIViewControllerBoard = UIViewControllerGuaranteedBoard
