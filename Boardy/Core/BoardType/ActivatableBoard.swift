//
//  ActivatableBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation
import UIKit

public protocol ActivatableBoard: IdentifiableBoard, OriginalBoard {
    func activate(withOption option: Any?)
}

extension ActivatableBoard {
    public func activate() {
        activate(withOption: nil)
    }
}

public typealias NormalBoard = InstallableBoard & ActivatableBoard
