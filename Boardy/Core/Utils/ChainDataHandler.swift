//
//  ChainDataHandler.swift
//  Boardy
//
//  Created by FOLY on 5/9/21.
//

import Foundation

/// Useful in handling an Any data which to be able matched with different data types

public final class ChainDataHandler<Target: AnyObject> {
    public weak var target: Target?

    private var handlers: [TargetHandler<Target>] = []

    public init(_ target: Target) {
        self.target = target
    }

    public func with<Value>(dataType: Value.Type, handler: @escaping (Target, Value) -> Void) -> Self {
        let matcher = TargetHandler { (object: Target, data) in
            if let output = data as? Value {
                handler(object, output)
                return true
            } else {
                return false
            }
        }
        handlers.append(matcher)
        return self
    }

    public func fallback(handler: @escaping (Target, Any?) -> Void = { target, data in
        #if DEBUG
        print(
            """
            ⚠️ [\(String(describing: ChainDataHandler.self))] fallback handling:
            🎯 Target: \(String(describing: target))
            🌸 Data: \(String(describing: data))
            """
        )
        #endif
    }) -> Self {
        let matcher = TargetHandler { (object: Target, data) in
            handler(object, data)
            return true
        }
        handlers.append(matcher)
        return self
    }

    public func handle(data: Any?) {
        guard let target = target else { return }
        for matchedHandler in handlers {
            if matchedHandler.handler(target, data) {
                return
            }
        }
    }
}

private final class TargetHandler<Target: AnyObject> {
    let handler: (Target, Any?) -> Bool

    init(handler: @escaping (Target, Any?) -> Bool) {
        self.handler = handler
    }
}
