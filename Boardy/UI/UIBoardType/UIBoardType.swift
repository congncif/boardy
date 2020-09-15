//
//  BoardType.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/31/19.
//  Copyright © 2019 NGUYEN CHI CONG. All rights reserved.
//

import Foundation
import UIKit

// MARK: - UIViewControllerBoard

public protocol UILinkableViewControllerBoard: ActivatableBoard {
    func buildInterface(withOption option: Any?) -> UIViewController?
    func linkInterface(_ viewController: UIViewController)
}

extension UILinkableViewControllerBoard {
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
