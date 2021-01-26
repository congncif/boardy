//
//  RxStoreRef+Board.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/15/20.
//

import Foundation
import ReferenceStoreManager

// MARK: - Board + pair

extension Board {
    public func pairInstall(to object: NSObject) {
        installIntoRoot(object)
        pairWith(object: object)
    }
}

// MARK: - Board + Compatible

import RxSwift

extension Board: PairableObject {}

extension Board: ReactiveCompatible {}

extension Board: ReactiveDisposableObject {}

extension Board: SelfStorableObject {}
