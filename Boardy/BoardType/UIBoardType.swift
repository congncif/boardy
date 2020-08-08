//
//  BoardType.swift
//  
//
//  Created by NGUYEN CHI CONG on 10/31/19.
//  Copyright © 2019 NGUYEN CHI CONG. All rights reserved.
//

import Foundation
import RIBs
import UIKit

// MARK: - RIBBoard

public protocol UILinkableRIBBoard {
    func buildInterface(withOption option: Any?) -> ViewableRouting?
    func linkInterface(_ viewRouter: ViewableRouting)
}

extension UILinkableRIBBoard where Self: ActivatableBoard {
    public func activate(withOption option: Any?) {
        guard let childRouter = buildInterface(withOption: option) else {
            assertionFailure("Cannot build interface for \(self) with option \(String(describing: option))")
            return
        }
        linkInterface(childRouter)
    }
}

public protocol UIDedicatedRIBBoard: UILinkableRIBBoard, AdaptableBoard {
    func buildInterface(withInput input: InputType?) -> ViewableRouting?
}

extension UIDedicatedRIBBoard {
    public func buildInterface(withOption option: Any?) -> ViewableRouting? {
        buildInterface(withInput: convertOptionToInput(option))
    }
}

public protocol UIGuaranteedRIBBoard: UILinkableRIBBoard, AdaptableBoard {
    func buildInterface(withGuaranteedInput input: InputType) -> ViewableRouting?
}

extension UIGuaranteedRIBBoard {
    public func buildInterface(withOption option: Any?) -> ViewableRouting? {
        guard let input = convertOptionToInput(option) else {
            assertionFailure("Cannot convert input from \(String(describing: option)) to type \(InputType.self)")
            return nil
        }
        return buildInterface(withGuaranteedInput: input)
    }
}

// MARK: - UIViewControllerBoard

public protocol UILinkableViewControllerBoard {
    func buildInterface(withOption option: Any?) -> UIViewController?
    func linkInterface(_ viewController: UIViewController)
}

extension UILinkableViewControllerBoard where Self: ActivatableBoard {
    public func activate(withOption option: Any?) {
        guard let viewController = buildInterface(withOption: option) else {
            assertionFailure("Cannot build interface for \(self) with option \(String(describing: option))")
            return
        }
        linkInterface(viewController)
    }
}

public protocol UIDedicatedViewControllerBoard: UILinkableViewControllerBoard, AdaptableBoard {
    func buildInterface(withInput input: InputType?) -> UIViewController?
}

extension UIDedicatedViewControllerBoard {
    public func buildInterface(withOption option: Any?) -> UIViewController? {
        buildInterface(withInput: convertOptionToInput(option))
    }
}

public protocol UIGuaranteedViewControllerBoard: UILinkableViewControllerBoard, AdaptableBoard {
    func buildInterface(withGuaranteedInput input: InputType) -> UIViewController?
}

extension UIGuaranteedViewControllerBoard {
    public func buildInterface(withOption option: Any?) -> UIViewController? {
        guard let input = convertOptionToInput(option) else {
            assertionFailure("Cannot convert input from \(String(describing: option)) to type \(InputType.self)")
            return nil
        }
        return buildInterface(withGuaranteedInput: input)
    }
}
