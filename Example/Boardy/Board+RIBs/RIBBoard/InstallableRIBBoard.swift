//
//  InstallableRIBBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/8/20.
//

import Foundation
import RIBs
import UIKit

public protocol InstallableRIBBoard: OriginalBoard {
    var rootRouter: ViewableRouting { get }

    func installRootRouter(_ rootRouter: ViewableRouting)
}

// Backward support to compatiate older version.
extension InstallableRIBBoard {
    @available(*, deprecated, message: "Use rootRouter instead")
    public var router: ViewableRouting { rootRouter }
}
