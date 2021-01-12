//
//  Flow.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation

/// Silent Data Types is pre-defined types (`BoardFlowAction`, `BoardInputModel`, `BoardCommandModel`, `CompleteAction`) for the certain purpose of the board activities. They should be excluded from type checking to avoid raising unnecessary problems.
func isSilentData(_ data: Any?) -> Bool {
    if data is BoardFlowAction || data is BoardInputModel || data is BoardCommandModel || data is CompleteAction {
        return true
    }
    return false
}

/// Special data type which should be forwarded through all of steps of the flow.
public protocol BoardFlowAction {}

public typealias FlowID = String

public protocol BoardFlow {
    func matchWithOutput(_ output: BoardOutputModel) -> Bool
    func doNext(_ data: Any?)
}

public protocol FlowManageable: AnyObject {
    var flows: [BoardFlow] { get set }
}

extension FlowManageable {
    @discardableResult
    public func registerFlow(_ flow: BoardFlow) -> Self {
        flows.append(flow)
        return self
    }

    @discardableResult
    public func registerFlows(_ flows: [BoardFlow]) -> Self {
        self.flows.append(contentsOf: flows)
        return self
    }

    @discardableResult
    public func registerGeneralFlow<Output>(nextHandler: @escaping (Output) -> Void) -> Self {
        let generalFlow = BoardActivateFlow(matcher: { _ in true }, nextHandler: { data in
            guard let output = data as? Output else { return }
            nextHandler(output)
        })
        registerFlow(generalFlow)
        return self
    }

    @discardableResult
    public func registerFlow<Output>(matchedIdentifiers: [FlowID], nextHandler: @escaping (Output) -> Void) -> Self {
        let generalFlow = BoardActivateFlow(matchedIdentifiers: matchedIdentifiers, guaranteedNextHandler: nextHandler)
        registerFlow(generalFlow)
        return self
    }

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
    let handler: (Target, Any?) -> Bool

    init(handler: @escaping (Target, Any?) -> Bool) {
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
        let matcher = HandlerInfo { (object: Target, data) in
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
        let matcher = HandlerInfo { (object: Target, data) in
            let output = data as? Output
            handler(object, output)
            return true
        }
        handlers.append(matcher)
        return manager.registerFlow(self)
    }

    @discardableResult
    public func eventuallyHandle(skipSilentData: Bool = true, handler: @escaping (Target, Any?) -> Void) -> FlowManageable {
        let matcher = HandlerInfo { (object: Target, data) in
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

    public func matchWithOutput(_ output: BoardOutputModel) -> Bool {
        return matcher(output)
    }

    public func doNext(_ data: Any?) {
        guard let target = target else { return }
        for matcher in handlers {
            if matcher.handler(target, data) {
                return
            }
        }
    }
}

public struct BoardActivateFlow: BoardFlow {
    private let matcher: (BoardOutputModel) -> Bool
    private let nextHandler: (Any?) -> Void

    public init(
        matcher: @escaping (BoardOutputModel) -> Bool,
        nextHandler: @escaping (Any?) -> Void
    ) {
        self.matcher = matcher
        self.nextHandler = nextHandler
    }

    public init<Ouput>(
        matcher: @escaping (BoardOutputModel) -> Bool,
        guaranteedNextHandler: @escaping (Ouput) -> Void
    ) {
        self.matcher = matcher
        nextHandler = { output in
            guard let data = output as? Ouput else {
                // Guaranteed output is Silent Data Types otherwise raise an assertion.
                guard isSilentData(output) else {
                    assertionFailure("⛈ Cannot convert output from \(String(describing: output)) to type \(Ouput.self)")
                    return
                }
                return
            }
            guaranteedNextHandler(data)
        }
    }

    public init<Ouput>(
        matcher: @escaping (BoardOutputModel) -> Bool,
        dedicatedNextHandler: @escaping (Ouput?) -> Void
    ) {
        self.matcher = matcher
        nextHandler = { output in
            let data = output as? Ouput
            dedicatedNextHandler(data)
        }
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

    public func matchWithOutput(_ output: BoardOutputModel) -> Bool {
        return matcher(output)
    }

    public func doNext(_ data: Any?) {
        nextHandler(data)
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
        flows.filter { $0.matchWithOutput(output) }.forEach { $0.doNext(data) }
    }
}

// MARK: - Forward functions

extension FlowManageable {
    public func resetFlows() { flows = [] }

    public func forwardActionFlow(to board: IdentifiableBoard) {
        registerGeneralFlow {
            board.sendFlowAction($0)
        }
    }

    public func forwardActivationFlow(to board: IdentifiableBoard) {
        registerGeneralFlow {
            board.nextToBoard(model: $0)
        }
    }
}

struct OutputModel: BoardOutputModel {
    let identifier: BoardID
    let data: Any?
}
