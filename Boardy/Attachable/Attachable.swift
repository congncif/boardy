//
//  Attachable.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 1/28/21.
//

import Foundation

public protocol AttachableObject: AnyObject {
    func attach(to object: AnyObject)
    func attachObject(_ object: AnyObject)
    func attachedObjects() -> [AnyObject]
    func detachObject(_ object: AnyObject)
    func detachAllObjects()
}

enum StaticStorage {
    static let mapTable = NSMapTable<AnyObject, NSHashTable<AnyObject>>.weakToStrongObjects()
}

public extension AttachableObject {
    private var storage: NSMapTable<AnyObject, NSHashTable<AnyObject>> {
        return StaticStorage.mapTable
    }

    func attach(to object: AnyObject) {
        if storage.object(forKey: object) == nil {
            storage.setObject(NSHashTable<AnyObject>(), forKey: object)
        }
        let value = storage.object(forKey: object)
        value?.add(self)
    }

    func attachObject(_ object: AnyObject) {
        if storage.object(forKey: self) == nil {
            storage.setObject(NSHashTable<AnyObject>(), forKey: self)
        }
        let value = storage.object(forKey: self)
        value?.add(object)
    }

    func attachedObjects() -> [AnyObject] {
        if let value = storage.object(forKey: self) {
            return value.allObjects
        }
        return []
    }

    func attachedObjects<ObjectType>(_ objectType: ObjectType.Type = ObjectType.self) -> [ObjectType] {
        attachedObjects().compactMap { $0 as? ObjectType }
    }

    func firstAttachedObject<ObjectType>(_ objectType: ObjectType.Type = ObjectType.self) -> ObjectType? {
        attachedObjects().first
    }

    func lastAttachedObject<ObjectType>(_ objectType: ObjectType.Type = ObjectType.self) -> ObjectType? {
        attachedObjects().last
    }

    func detachObject(_ object: AnyObject) {
        if let value = storage.object(forKey: self) {
            value.remove(object)
        }
    }

    func detachObjects<ObjectType: AnyObject>(_ objectType: ObjectType.Type) {
        let objects: [ObjectType] = attachedObjects()
        objects.forEach {
            detachObject($0)
        }
    }

    func detachAllObjects() {
        if let value = storage.object(forKey: self) {
            value.removeAllObjects()
        }
    }
}
