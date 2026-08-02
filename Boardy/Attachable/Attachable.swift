//
//  Attachable.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 1/28/21.
//

import Foundation

public protocol DetachableObject: AnyObject {
    func detachObject(_ object: AnyObject)
}

public protocol AttachableObject: DetachableObject {
    func attach(to object: AnyObject)
    func attachObject(_ object: AnyObject)

    func attachedObjects() -> [AnyObject]
    func detachAllObjects()
}

enum AttachableStaticStorage {
    private static let storage = Locked(
        NSMapTable<AnyObject, NSHashTable<AnyObject>>.weakToStrongObjects()
    )

    static func withLock<Result>(
        _ body: (NSMapTable<AnyObject, NSHashTable<AnyObject>>) throws -> Result
    ) rethrows -> Result {
        try storage.withLock { table in
            try body(table)
        }
    }

    static func removeAll() {
        withLock { table in
            table.removeAllObjects()
        }
    }
}

public extension AttachableObject {
    func attach(to object: AnyObject) {
        AttachableStaticStorage.withLock { storage in
            if storage.object(forKey: object) == nil {
                storage.setObject(NSHashTable<AnyObject>(), forKey: object)
            }
            storage.object(forKey: object)?.add(self)
        }
    }

    func attachObject(_ object: AnyObject) {
        AttachableStaticStorage.withLock { storage in
            if storage.object(forKey: self) == nil {
                storage.setObject(NSHashTable<AnyObject>(), forKey: self)
            }
            storage.object(forKey: self)?.add(object)
        }
    }

    func attachedObjects() -> [AnyObject] {
        AttachableStaticStorage.withLock { storage in
            storage.object(forKey: self)?.allObjects ?? []
        }
    }

    func attachedObjects<ObjectType>(_: ObjectType.Type = ObjectType.self) -> [ObjectType] {
        attachedObjects().compactMap { $0 as? ObjectType }
    }

    func firstAttachedObject<ObjectType>(_: ObjectType.Type = ObjectType.self) -> ObjectType? {
        attachedObjects().first
    }

    func lastAttachedObject<ObjectType>(_: ObjectType.Type = ObjectType.self) -> ObjectType? {
        attachedObjects().last
    }

    func detachObject(_ object: AnyObject) {
        AttachableStaticStorage.withLock { storage in
            storage.object(forKey: self)?.remove(object)
        }
    }

    func detachObjects<ObjectType>(_: ObjectType.Type, where condition: (ObjectType) -> Bool = { _ in true }) {
        let objects: [AnyObject] = attachedObjects().filter {
            guard let object = $0 as? ObjectType else { return false }
            return condition(object)
        }
        objects.forEach {
            detachObject($0)
        }
    }

    func detachObjects(where condition: (AnyObject) -> Bool) {
        let objects = attachedObjects()
        objects.filter(condition).forEach {
            detachObject($0)
        }
    }

    func detachAllObjects() {
        AttachableStaticStorage.withLock { storage in
            storage.object(forKey: self)?.removeAllObjects()
        }
    }
}
