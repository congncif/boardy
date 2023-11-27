//
//  ChainFlow.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 27/11/2023.
//

import Foundation

private final class HandlerInfo<Target> {
    let handler: (Target, BoardOutputModel) -> Bool

    init(handler: @escaping (Target, BoardOutputModel) -> Bool) {
        self.handler = handler
    }
}

public final class ChainBoardFlow<Target>: BoardFlow {
    public let identifier: String
    private var handlers: [HandlerInfo<Target>] = []
    private let matcher: (BoardOutputModel) -> Bool

    private unowned let manager: FlowManageable
    private let box = ObjectBox()

    private var target: Target? {
        box.unboxed(Target.self)
    }

    public init(
        identifier: String = UUID().uuidString,
        manager: FlowManageable,
        target: Target,
        matcher: @escaping (BoardOutputModel) -> Bool
    ) {
        self.identifier = identifier
        self.manager = manager
        self.matcher = matcher
        box.setObject(target)
    }

    public func handle<Output>(outputType _: Output.Type, handler: @escaping (Target, Output) -> Void) -> Self {
        let matcher = HandlerInfo { (object: Target, output) in
            let data = output.data
            if let output = data as? Output {
                handler(object, output)
                return true
            } else {
                return false
            }
        }
        handlers.append(matcher)
        return self
    }

    @discardableResult
    public func eventuallyHandle<Output>(outputType _: Output.Type, handler: @escaping (Target, Output?) -> Void) -> FlowManageable {
        let matcher = HandlerInfo { (object: Target, output) in
            let data = output.data
            let output = data as? Output
            handler(object, output)
            return true
        }
        handlers.append(matcher)
        return manager.registerFlow(self)
    }

    @discardableResult
    public func eventuallyHandle(skipSilentData: Bool = true, handler: @escaping (Target, Any?) -> Void) -> FlowManageable {
        let matcher = HandlerInfo { (object: Target, output) in
            let data = output.data
            if skipSilentData, isSilentData(data) {
                return true
            }
            handler(object, data)
            return true
        }
        handlers.append(matcher)
        return manager.registerFlow(self)
    }

    @discardableResult
    public func eventuallySkipHandling() -> FlowManageable {
        eventuallyHandle { _, _ in }
    }

    public func match(with output: BoardOutputModel) -> Bool {
        matcher(output)
    }

    public func doNext(with output: BoardOutputModel) {
        guard let target = target else { return }
        for matcher in handlers {
            if matcher.handler(target, output) {
                return
            }
        }
    }
}
