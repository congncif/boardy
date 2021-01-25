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
    weak var object: AnyObject?
    var value: Any?

    func unboxed<Object>(_ objectType: Object.Type = Object.self) -> Object? {
        object as? Object ?? value as? Object
    }

    var isEmpty: Bool {
        object == nil && value == nil
    }
}

public final class TargetBusCable<Input, Target>: BusCable<Input> {
    var box = ObjectBox()

    public init(target: Target, handler: @escaping (Input, Target) -> Void) {
        if let object = target as? AnyObject {
            box.object = object
        } else {
            box.value = target
        }
        super.init(transportHandler: { [weak box] input in
            guard let destination = box?.unboxed(Target.self) else { return }
            handler(input, destination)
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
