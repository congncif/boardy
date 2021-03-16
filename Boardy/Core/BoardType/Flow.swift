//
//  Flow.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation

/// Special data type which should be forwarded through all of steps of the flow.
public protocol BoardFlowAction {}

public typealias FlowID = BoardID

public protocol BoardFlow {
    func match(with output: BoardOutputModel) -> Bool
    func doNext(with output: BoardOutputModel)
}

public protocol FlowManageable: AnyObject {
    var flows: [BoardFlow] { get }

    @discardableResult
    func registerFlow(_ flow: BoardFlow) -> Self

    func resetFlows()
}

extension FlowManageable {
    @discardableResult
    public func registerFlows(_ flows: [BoardFlow]) -> Self {
        flows.forEach { [unowned self] in
            self.registerFlow($0)
        }
        return self
    }

    /// A General Flow doesn't check identifier of sender, handler will be executed whenever data matches with Output type. This mean it will be applied for all senders in workflow.
    @discardableResult
    public func registerGeneralFlow<Output>(uniqueOutputType: Output.Type = Output.self, nextHandler: @escaping (Output) -> Void) -> Self {
        let generalFlow = BoardActivateFlow(matcher: { _ in true }, nextHandler: { data in
            guard let output = data as? Output else { return }
            nextHandler(output)
        })
        registerFlow(generalFlow)
        return self
    }

    /// A General Flow doesn't check identifier of sender, handler will be executed whenever data matches with Output type. This mean it will be applied for all senders in workflow.
    @discardableResult
    public func registerGeneralFlow<Target: AnyObject, Output>(
        target: Target,
        uniqueOutputType: Output.Type = Output.self,
        nextHandler: @escaping (Target, Output) -> Void
    ) -> Self {
        let generalFlow = BoardActivateFlow(matcher: { _ in true }, nextHandler: { [weak target] data in
            guard let output = data as? Output, let target = target else { return }
            nextHandler(target, output)
        })
        registerFlow(generalFlow)
        return self
    }

    /// Default flow is a dedicated flow with specified output type. If data matches with Output type, handler will be executed, otherwise the handler will be skipped.
    @discardableResult
    public func registerFlow<Output>(
        matchedIdentifiers: [FlowID],
        uniqueOutputType: Output.Type = Output.self,
        nextHandler: @escaping (Output) -> Void
    ) -> Self {
        let generalFlow = BoardActivateFlow(matchedIdentifiers: matchedIdentifiers, dedicatedNextHandler: { (output: Output?) in
            guard let output = output else { return }
            nextHandler(output)
        })
        registerFlow(generalFlow)
        return self
    }

    /// Default flow is a dedicated flow with specified output type. If data matches with Output type, handler will be executed, otherwise the handler will be skipped.
    @discardableResult
    public func registerFlow<Target: AnyObject, Output>(
        matchedIdentifiers: [FlowID],
        target: Target,
        uniqueOutputType: Output.Type = Output.self,
        nextHandler: @escaping (Target, Output) -> Void
    ) -> Self {
        let generalFlow = BoardActivateFlow(matchedIdentifiers: matchedIdentifiers, dedicatedNextHandler: { [weak target] (output: Output?) in
            guard let output = output, let target = target else { return }
            nextHandler(target, output)
        })
        registerFlow(generalFlow)
        return self
    }

    /// Guaranteed Flow ensures data must match with Output type if not handler will fatal in debug and will be skipped in release mode.
    @discardableResult
    public func registerGuaranteedFlow<Target: AnyObject, Output>(
        matchedIdentifiers: [FlowID],
        target: Target,
        uniqueOutputType: Output.Type = Output.self,
        handler: @escaping (Target, Output) -> Void
    ) -> Self {
        let generalFlow = BoardActivateFlow(matchedIdentifiers: matchedIdentifiers, guaranteedNextHandler: { [weak target] (ouput: Output) in
            if let target = target {
                handler(target, ouput)
            }
        })
        registerFlow(generalFlow)
        return self
    }

    /// Chain Flow handles step by step of chain of handlers until a handler in chain is executed. Eventually handler is mandatory to register this flow.
    public func registerChainFlow<Target: AnyObject>(matchedIdentifiers: [FlowID], target: Target) -> ChainBoardFlow<Target> {
        let flow = ChainBoardFlow(manager: self, target: target) {
            matchedIdentifiers.contains($0.identifier)
        }
        return flow
    }
}

extension FlowManageable where Self: MotherboardType {
    /// Flow Steps will skip Silent Data Types (`BoardFlowAction`, `BoardInputModel`, `BoardCommandModel`, `CompleteAction`). So to register Flow Steps, the Board InputType can't be Silent Data Types. If you still want to handle Silent Data Types as Input of your board, you must register by regular `BoardActivateFlow`.
    @discardableResult
    public func registerFlowSteps(_ flowSteps: [IDFlowStep]) -> Self {
        let activateFlows = flowSteps.map { flowStep in
            BoardActivateFlow(
                matcher: { board -> Bool in
                    flowStep.source == board.identifier
                },
                nextHandler: { [weak self] data in
                    // Guaranteed data is not Slient Data Types otherwise skip handling.
                    guard !isSilentData(data) else { return }
                    self?.activateBoard(identifier: flowStep.destination, withOption: data)
                }
            )
        }
        registerFlows(activateFlows)
        return self
    }
}

private final class HandlerInfo<Target: AnyObject> {
    let handler: (Target, BoardOutputModel) -> Bool

    init(handler: @escaping (Target, BoardOutputModel) -> Bool) {
        self.handler = handler
    }
}

public final class ChainBoardFlow<Target: AnyObject>: BoardFlow {
    private var handlers: [HandlerInfo<Target>] = []
    private let matcher: (BoardOutputModel) -> Bool

    private unowned let manager: FlowManageable
    private weak var target: Target?

    init(manager: FlowManageable, target: Target, matcher: @escaping (BoardOutputModel) -> Bool) {
        self.manager = manager
        self.matcher = matcher
        self.target = target
    }

    public func handle<Output>(outputType: Output.Type, handler: @escaping (Target, Output) -> Void) -> Self {
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
    public func eventuallyHandle<Output>(outputType: Output.Type, handler: @escaping (Target, Output?) -> Void) -> FlowManageable {
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
        return eventuallyHandle { _, _ in }
    }

    public func match(with output: BoardOutputModel) -> Bool {
        return matcher(output)
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

public struct BoardActivateFlow: BoardFlow {
    private let matcher: (BoardOutputModel) -> Bool
    private let outputNextHandler: (BoardOutputModel) -> Void

    public init(
        matcher: @escaping (BoardOutputModel) -> Bool,
        outputNextHandler: @escaping (BoardOutputModel) -> Void
    ) {
        self.matcher = matcher
        self.outputNextHandler = outputNextHandler
    }

    public init(
        matcher: @escaping (BoardOutputModel) -> Bool,
        nextHandler: @escaping (Any?) -> Void
    ) {
        self.matcher = matcher
        outputNextHandler = {
            nextHandler($0.data)
        }
    }

    public init<Ouput>(
        matcher: @escaping (BoardOutputModel) -> Bool,
        dedicatedNextHandler: @escaping (Ouput?) -> Void
    ) {
        self.matcher = matcher
        outputNextHandler = { output in
            let data = output.data as? Ouput
            dedicatedNextHandler(data)
        }
    }

    public init<Ouput>(
        matcher: @escaping (BoardOutputModel) -> Bool,
        guaranteedNextHandler: @escaping (Ouput) -> Void
    ) {
        self.matcher = matcher
        outputNextHandler = { output in
            guard let data = output.data as? Ouput else {
                // Guaranteed output is Silent Data Types otherwise raise an assertion.
                guard isSilentData(output.data) else {
                    assertionFailure("⛈ Cannot convert output of board \(output.identifier) from type \(String(describing: output.data)) to type \(Ouput.self)")
                    return
                }
                return
            }
            guaranteedNextHandler(data)
        }
    }

    public init(matchedIdentifiers: [FlowID], outputNextHandler: @escaping (BoardOutputModel) -> Void) {
        self.init(matcher: { matchedIdentifiers.contains($0.identifier) }, outputNextHandler: outputNextHandler)
    }

    public init(matchedIdentifiers: [FlowID], nextHandler: @escaping (Any?) -> Void) {
        self.init(matcher: { matchedIdentifiers.contains($0.identifier) }, nextHandler: nextHandler)
    }

    public init<Output>(matchedIdentifiers: [FlowID], dedicatedNextHandler: @escaping (Output?) -> Void) {
        self.init(matcher: { matchedIdentifiers.contains($0.identifier) }, dedicatedNextHandler: dedicatedNextHandler)
    }

    public init<Output>(matchedIdentifiers: [FlowID], guaranteedNextHandler: @escaping (Output) -> Void) {
        self.init(matcher: { matchedIdentifiers.contains($0.identifier) }, guaranteedNextHandler: guaranteedNextHandler)
    }

    public func match(with output: BoardOutputModel) -> Bool {
        return matcher(output)
    }

    public func doNext(with output: BoardOutputModel) {
        outputNextHandler(output)
    }
}

public struct IDFlowStep {
    public let source: FlowID
    public let destination: FlowID

    public init(source: FlowID, destination: FlowID) {
        self.source = source
        self.destination = destination
    }
}

infix operator ->>>: MultiplicationPrecedence
public func ->>> (left: FlowID, right: FlowID) -> [IDFlowStep] {
    return [IDFlowStep(source: left, destination: right)]
}

public func ->>> (left: [IDFlowStep], right: FlowID) -> [IDFlowStep] {
    guard let lastLeft = left.last else {
        assertionFailure("Empty flow is not allowed")
        return []
    }
    return left + [IDFlowStep(source: lastLeft.destination, destination: right)]
}

public typealias FlowMotherboard = MotherboardType & FlowManageable

extension BoardDelegate where Self: FlowManageable {
    public func board(_ board: IdentifiableBoard, didSendData data: Any?) {
        // Handle dedicated flow actions
        let output = OutputModel(identifier: board.identifier, data: data)
        flows.filter { $0.match(with: output) }.forEach { $0.doNext(with: output) }
    }
}

// MARK: - Forward functions

extension FlowManageable {
    public func forwardActionFlow(to board: IdentifiableBoard) {
        registerGeneralFlow { [weak board] in
            board?.sendFlowAction($0)
        }
    }

    public func forwardActivationFlow(to board: IdentifiableBoard) {
        registerGeneralFlow { [weak board] in
            board?.nextToBoard(model: $0)
        }
    }
}

struct OutputModel: BoardOutputModel {
    let identifier: BoardID
    let data: Any?
}
