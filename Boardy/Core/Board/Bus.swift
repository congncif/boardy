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

    public init(transportHandler: @escaping Handler) {
        self.transportHandler = transportHandler
    }

    open func transport(input: Input) {
        transportHandler(input)
    }

    var isValid: Bool { true }
}

final class ObjectBox {
    private weak var object: AnyObject?
    private var value: Any?

    func setObject(_ object: Any) {
        if type(of: object as Any) is AnyClass {
            self.object = object as AnyObject
        } else {
            value = object
        }
    }

    func unboxed<Object>(_ objectType: Object.Type = Object.self) -> Object? {
        object as? Object ?? value as? Object
    }

    var isEmpty: Bool {
        object == nil && value == nil
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

    override var isValid: Bool {
        !box.isEmpty
    }
}

public final class Bus<Input> {
    private var cables: [BusCable<Input>] = []

    public init() {}

    func cleanInvalidCablesIfNeeded() {
        cables.removeAll { !$0.isValid }
    }

    public func connect(_ cable: BusCable<Input>) {
        cleanInvalidCablesIfNeeded()
        cables.append(cable)
    }

    public func transport(input: Input) {
        cleanInvalidCablesIfNeeded()

        cables.forEach {
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
        transport(input: Optional<Any>.none as Any)
    }
}
