//
//  UILinkableRIBBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/8/20.
//

import Foundation
import RIBs

// MARK: - RIBBoard

public protocol UILinkableRIBBoard: ActivatableBoard {
    func buildInterface(withOption option: Any?) -> ViewableRouting?
    func linkInterface(_ viewRouter: ViewableRouting)
}

public extension UILinkableRIBBoard {
    func activate(withOption option: Any?) {
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

public extension UIDedicatedRIBBoard {
    func buildInterface(withOption option: Any?) -> ViewableRouting? {
        buildInterface(withInput: convertOptionToInput(option))
    }
}

public protocol UIGuaranteedRIBBoard: UILinkableRIBBoard, AdaptableBoard {
    func buildInterface(withGuaranteedInput input: InputType) -> ViewableRouting?
}

public extension UIGuaranteedRIBBoard {
    func buildInterface(withOption option: Any?) -> ViewableRouting? {
        guard let input = convertOptionToInput(option) else {
            assertionFailure("Cannot convert input from \(String(describing: option)) to type \(InputType.self)")
            return nil
        }
        return buildInterface(withGuaranteedInput: input)
    }
}
