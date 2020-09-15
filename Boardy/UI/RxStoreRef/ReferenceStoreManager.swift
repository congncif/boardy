//
//  ReferenceStoreManager.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/15/20.
//

import Foundation
import RxCocoa
import RxSwift

public final class ReferenceStoreManager {
    private var storage: [AnyHashable: AnyObject] = [:]
    private var disposeBags: [AnyHashable: DisposeBag] = [:]

    public init() {}

    public static let shared = ReferenceStoreManager()

    public func storeObject<Object>(_ object: AnyObject, untilObjectKilled pairObject: Object) where Object: ReactiveCompatible, Object: AnyObject {
        let key = ObjectIdentifier(pairObject)

        storage[key] = object

        let disposeBag = DisposeBag()
        disposeBags[key] = disposeBag

        let disposable = pairObject.rx.deallocated
            .subscribe(onNext: { [weak self] in
                self?.storage.removeValue(forKey: key)
                self?.disposeBags.removeValue(forKey: key)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - ObjectReferenceStorable

public protocol ObjectReferenceStorable: AnyObject {
    var referenceStoreManager: ReferenceStoreManager { get }

    func pairWith<Object>(object: Object) where Object: ReactiveCompatible, Object: AnyObject
}

extension ObjectReferenceStorable {
    public var referenceStoreManager: ReferenceStoreManager { .shared }

    public func pairWith<Object>(object: Object) where Object: ReactiveCompatible, Object: AnyObject {
        ReferenceStoreManager.shared.storeObject(self, untilObjectKilled: object)
    }
}

// MARK: - Utility Extensions

extension NSObject: ObjectReferenceStorable {}
