//
//  DisposeControllable.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/12/20.
//

import Foundation
import RxSwift

public protocol DisposeControllable {
    var disposeBag: DisposeBag { get }
}

private var disposeBagKey: UInt8 = 104

extension DisposeControllable {
    func getAssociatedDisposeBag() -> DisposeBag? {
        return objc_getAssociatedObject(self, &disposeBagKey) as? DisposeBag
    }

    func setAssociatedDisposeBag(_ value: DisposeBag?) {
        objc_setAssociatedObject(self, &disposeBagKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    public var disposeBag: DisposeBag {
        get {
            if let bag = getAssociatedDisposeBag() {
                return bag
            } else {
                let newBag = DisposeBag()
                setAssociatedDisposeBag(newBag)
                return newBag
            }
        }

        set {
            setAssociatedDisposeBag(newValue)
        }
    }
}
