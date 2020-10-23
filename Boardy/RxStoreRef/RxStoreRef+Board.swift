//
//  RxStoreRef+Board.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/15/20.
//

import Foundation

// MARK: - Board + pair

extension Board {
    public func pairInstallWith(object: NSObject) {
        installIntoRoot(object)
        pairWith(object: object)
    }
}

// MARK: - Board + Compatible

import RxSwift

extension Board: ReferenceStorableObject {}

extension Board: ReactiveCompatible {}

extension Board: ReactiveDisposableObject {}
