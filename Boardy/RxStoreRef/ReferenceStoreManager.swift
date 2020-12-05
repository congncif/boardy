//
//  ReferenceStoreManager.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/15/20.
//

import Foundation
import RxCocoa
import RxSwift

// MARK: - ObjectReferenceStorable

public final class ReferenceStoreManager {
    private var storage: [AnyHashable: [AnyObject]] = [:]
    private var disposeBags: [AnyHashable: DisposeBag] = [:]

    public init() {}

    public static let shared = ReferenceStoreManager()

    public func storeObject<Object>(_ object: AnyObject, untilObjectKilled pairObject: Object) where Object: ReactiveCompatible, Object: AnyObject {
        let key = ObjectIdentifier(pairObject)

        if var objects = storage[key] {
            if objects.contains(where: { $0 === object }) {
                return
            }
            objects.append(object)
            storage[key] = objects
        } else {
            storage[key] = [object]
        }

        if let disposeBag = disposeBags[key] { return }

        let disposeBag = DisposeBag()
        disposeBags[key] = disposeBag

        pairObject.rx.deallocated
            .subscribe(onNext: { [weak self] in
                self?.storage.removeValue(forKey: key)
                self?.disposeBags.removeValue(forKey: key)
            })
            .disposed(by: disposeBag)
    }

    public func storedObjects(pairedWith object: AnyObject) -> [AnyObject] {
        let key = ObjectIdentifier(object)
        return storage[key] ?? []
    }
}

public protocol ReferenceStorableObject: AnyObject {
    var referenceStoreManager: ReferenceStoreManager { get }

    func pairWith<Object>(object: Object) where Object: ReactiveCompatible, Object: AnyObject
}

extension ReferenceStorableObject {
    public var referenceStoreManager: ReferenceStoreManager { .shared }

    public func pairWith<Object>(object: Object) where Object: ReactiveCompatible, Object: AnyObject {
        referenceStoreManager.storeObject(self, untilObjectKilled: object)
    }

    public func pairedObjects<Object>() -> [Object] {
        referenceStoreManager.storedObjects(pairedWith: self).compactMap {
            $0 as? Object
        }
    }

    public func pairedObject<Object>() -> Object? {
        pairedObjects().first
    }
}

// MARK: - ReactiveDisposableObject

public final class DisposeContainer {
    private var disposeBags: [AnyHashable: DisposeBag] = [:]

    public static let shared = DisposeContainer()

    public func generateDisposeBag<Object>(for object: Object) -> DisposeBag where Object: ReactiveCompatible, Object: AnyObject {
        let key = ObjectIdentifier(object)
        if let disposeBag = disposeBags[key] {
            return disposeBag
        }

        let disposeBag = DisposeBag()
        disposeBags[key] = disposeBag

        object.rx.deallocated
            .subscribe(onNext: { [weak self] in
                self?.disposeBags.removeValue(forKey: key)
            })
            .disposed(by: disposeBag)

        return disposeBag
    }
}

public protocol ReactiveDisposableObject: AnyObject {
    var disposeContainer: DisposeContainer { get }
    var freshDisposeBag: DisposeBag { get }
}

extension ReactiveDisposableObject where Self: ReactiveCompatible {
    public var disposeContainer: DisposeContainer { .shared }

    public var freshDisposeBag: DisposeBag {
        disposeContainer.generateDisposeBag(for: self)
    }
}

// MARK: - Utility Extensions

extension NSObject: ReferenceStorableObject {}
extension NSObject: ReactiveDisposableObject {}
