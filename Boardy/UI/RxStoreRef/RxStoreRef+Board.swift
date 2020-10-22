//
//  RxStoreRef+Board.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/15/20.
//

import Foundation
import UIKit

// MARK: - Board + pair

extension Board {
    public func pairInstallWith(object: NSObject) {
        installIntoRoot(object)
        pairWith(object: object)
    }
}

/***/
extension UIBoardInterface where Self: ReactiveDisposableObject {
    public func justPlugUIMotherboard(_ board: UIMotherboardType) {
        board.plug(in: self, with: freshDisposeBag)
    }
}

extension UIMotherboardType where Self: ReactiveDisposableObject {
    public func justPlug(in interface: UIBoardInterface) {
        plug(in: interface, with: freshDisposeBag)
    }
}

// MARK: - Board + Compatible

import RxSwift

extension Board: ReferenceStorableObject {}

extension Board: ReactiveCompatible {}

extension Board: ReactiveDisposableObject {}
