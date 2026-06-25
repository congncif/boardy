//
//  Bus.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 1/25/21.
//

import Foundation

open class BusCable<Input> {
    public typealias Handler = (Input) -> Void

    let transportHandler: Handler
    private let lock = NSRecursiveLock()
    private var valid: Bool = true

    public init(transportHandler: @escaping Handler) {
        self.transportHandler = transportHandler
    }

    open func transport(input: Input) {
        transportHandler(input)
    }

    open private(set) var isValid: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return valid
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            valid = newValue
        }
    }

    open func invalidate() {
        isValid = false
    }
}

final class ObjectBox {
    private weak var object: AnyObject?
    private var value: Any?
    private let lock = NSRecursiveLock()

    func setObject(_ object: Any) {
        lock.lock()
        defer { lock.unlock() }
        if type(of: object as Any) is AnyClass {
            self.object = object as AnyObject
        } else {
            value = object
        }
    }

    func makeEmpty() {
        lock.lock()
        defer { lock.unlock() }
        object = nil
        value = nil
    }

    func unboxed<Object>(_: Object.Type = Object.self) -> Object? {
        lock.lock()
        defer { lock.unlock() }
        return object as? Object ?? value as? Object
    }

    var isEmpty: Bool {
        lock.lock()
        defer { lock.unlock() }
        return object == nil && value == nil
    }
}

public final class TargetBusCable<Target, Input>: BusCable<Input> {
    private let box = ObjectBox()

    public init(target: Target, handler: @escaping (Target, Input) -> Void) {
        box.setObject(target)
        super.init(transportHandler: { [weak box] input in
            guard let destination = box?.unboxed(Target.self) else { return }
            handler(destination, input)
        })
    }

    override public var isValid: Bool {
        !box.isEmpty
    }

    override public func invalidate() {
        box.makeEmpty()
    }
}

public final class Bus<Input> {
    private var cables: [BusCable<Input>] = []
    private let lock = NSRecursiveLock()

    public init() {}

    func cleanInvalidCablesIfNeeded() {
        cables.removeAll { !$0.isValid }
    }

    public func connect(_ cable: BusCable<Input>) {
        lock.lock()
        defer { lock.unlock() }
        cleanInvalidCablesIfNeeded()
        cables.append(cable)
    }

    public func transport(input: Input) {
        let currentCables: [BusCable<Input>]
        lock.lock()
        cleanInvalidCablesIfNeeded()
        currentCables = cables
        lock.unlock()

        currentCables.forEach {
            $0.transport(input: input)
        }
    }
}

public extension Bus {
    func connect<Target>(target: Target, handler: @escaping (Target, Input) -> Void) {
        let cable = TargetBusCable<Target, Input>(target: target, handler: handler)
        connect(cable)
    }

    func connect<Target>(target: Target, handler: @escaping (Target) -> Void) {
        connect(target: target) { target, _ in
            handler(target)
        }
    }

    func deliver(handler: @escaping (Input) -> Void) {
        let cab = BusCable(transportHandler: handler)
        connect(cab)
    }
}

public extension Bus where Input == Void {
    func transport() {
        transport(input: ())
    }
}

public extension Bus where Input == Any? {
    func transport() {
        transport(input: nil)
    }
}

public extension Bus where Input == Any {
    func transport() {
        transport(input: Any?.none as Any)
    }
}
