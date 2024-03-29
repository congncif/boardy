//
//  Flow.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation

/// Special data type which should be forwarded through all of steps of the flow.
public protocol BoardFlowAction {}

public enum BoardFlowNoneAction: BoardFlowAction {}

public typealias FlowStepID = BoardID

public protocol FlowManageable: AnyObject {
    var flows: [BoardFlow] { get }

    @discardableResult
    func registerFlow(_ flow: BoardFlow) -> Self

    func resetFlows()

    func removeFlow(by identifier: String)
}

public extension FlowManageable {
    @discardableResult
    func registerFlows(_ flows: [BoardFlow]) -> Self {
        flows.forEach { [unowned self] in
            self.registerFlow($0)
        }
        return self
    }

    /// A General Flow doesn't check identifier of sender, handler will be executed whenever data matches with Output type. This mean it will be applied for all senders in workflow.
    @discardableResult
    func registerGeneralFlow<Output>(uniqueOutputType _: Output.Type = Output.self, nextHandler: @escaping (Output) -> Void) -> Self {
        let generalFlow = BoardActivateFlow(matcher: { _ in true }, nextHandler: { data in
            guard let output = data as? Output else { return }
            nextHandler(output)
        })
        registerFlow(generalFlow)
        return self
    }

    /// A General Flow doesn't check identifier of sender, handler will be executed whenever data matches with Output type. This mean it will be applied for all senders in workflow.
    @discardableResult
    func registerGeneralFlow<Target, Output>(
        target: Target,
        uniqueOutputType _: Output.Type = Output.self,
        nextHandler: @escaping (Target, Output) -> Void
    ) -> Self {
        let box = ObjectBox()
        box.setObject(target)
        let generalFlow = BoardActivateFlow(matcher: { _ in true }, nextHandler: { [box] data in
            guard let output = data as? Output, let target = box.unboxed(Target.self) else { return }
            nextHandler(target, output)
        })
        registerFlow(generalFlow)
        return self
    }

    /// Default flow is a dedicated flow with specified output type. If data matches with Output type, handler will be executed, otherwise the handler will be skipped.
    @discardableResult
    func registerFlow<Output>(
        matchedIdentifiers: [FlowStepID],
        uniqueOutputType _: Output.Type = Output.self,
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
    func registerFlow<Target, Output>(
        matchedIdentifiers: [FlowStepID],
        target: Target,
        uniqueOutputType _: Output.Type = Output.self,
        nextHandler: @escaping (Target, Output) -> Void
    ) -> Self {
        let box = ObjectBox()
        box.setObject(target)
        let generalFlow = BoardActivateFlow(matchedIdentifiers: matchedIdentifiers, dedicatedNextHandler: { [box] (output: Output?) in
            guard let output = output, let target = box.unboxed(Target.self) else { return }
            nextHandler(target, output)
        })
        registerFlow(generalFlow)
        return self
    }

    /// Guaranteed Flow ensures data must match with Output type if not handler will fatal in debug and will be skipped in release mode.
    @discardableResult
    func registerGuaranteedFlow<Target, Output>(
        matchedIdentifiers: [FlowStepID],
        target: Target,
        uniqueOutputType _: Output.Type = Output.self,
        handler: @escaping (Target, Output) -> Void
    ) -> Self {
        let box = ObjectBox()
        box.setObject(target)
        let generalFlow = BoardActivateFlow(matchedIdentifiers: matchedIdentifiers, guaranteedNextHandler: { [box] (output: Output) in
            if let target = box.unboxed(Target.self) {
                handler(target, output)
            }
        })
        registerFlow(generalFlow)
        return self
    }

    /// Chain Flow handles step by step of chain of handlers until a handler in chain is executed. Eventually handler is mandatory to register this flow.
    func registerChainFlow<Target>(matchedIdentifiers: [FlowStepID], target: Target) -> ChainBoardFlow<Target> {
        let flow = ChainBoardFlow(manager: self, target: target) {
            matchedIdentifiers.contains($0.identifier)
        }
        return flow
    }

    @discardableResult
    func registerCompletionFlow(
        matchedIdentifiers: [FlowStepID],
        nextHandler: @escaping (_ isDone: Bool) -> Void
    ) -> Self {
        let flow = BoardActivateFlow(matchedIdentifiers: matchedIdentifiers, nextHandler: { data in
            guard let completionAction = data as? CompleteAction else { return }
            nextHandler(completionAction.isDone)
        })
        registerFlow(flow)
        return self
    }
}

public extension FlowManageable where Self: MotherboardType {
    /// Flow Steps will skip Silent Data Types (`BoardFlowAction`, `BoardInputModel`, `BoardCommandModel`, `CompleteAction`). So to register Flow Steps, the Board InputType can't be Silent Data Types. If you still want to handle Silent Data Types as Input of your board, you must register by regular `BoardActivateFlow`.
    @discardableResult
    func registerFlowSteps(_ flowSteps: [IDFlowStep]) -> Self {
        let activateFlows = flowSteps.map { flowStep in
            BoardActivateFlow(
                matcher: { board -> Bool in
                    flowStep.source == board.identifier
                },
                nextHandler: { [weak self] data in
                    // Guaranteed data is not Silent Data Types otherwise skip handling.
                    guard !isSilentData(data) else { return }
                    self?.activateBoard(identifier: flowStep.destination, withOption: data)
                }
            )
        }
        registerFlows(activateFlows)
        return self
    }
}

public struct IDFlowStep {
    public let source: FlowStepID
    public let destination: FlowStepID

    public init(source: FlowStepID, destination: FlowStepID) {
        self.source = source
        self.destination = destination
    }
}

infix operator ->>: MultiplicationPrecedence
public func ->> (left: FlowStepID, right: FlowStepID) -> [IDFlowStep] {
    [IDFlowStep(source: left, destination: right)]
}

public func ->> (left: [IDFlowStep], right: FlowStepID) -> [IDFlowStep] {
    guard let lastLeft = left.last else {
        assertionFailure("Empty flow is not allowed")
        return []
    }
    return left + [IDFlowStep(source: lastLeft.destination, destination: right)]
}

public typealias FlowMotherboard = MotherboardType & FlowManageable

public extension BoardDelegate where Self: FlowManageable {
    func board(_ board: IdentifiableBoard, didSendData data: Any?) {
        // Handle dedicated flow actions
        let output = OutputModel(identifier: board.identifier, data: data)
        flows.filter { $0.match(with: output) }.forEach { $0.doNext(with: output) }
    }
}

// MARK: - Forward functions

public extension FlowManageable {
    func forwardActionFlow(to board: IdentifiableBoard) {
        registerGeneralFlow { [weak board] in
            board?.sendFlowAction($0)
        }
    }

    func forwardActivationFlow(to board: IdentifiableBoard) {
        registerGeneralFlow { [weak board] in
            board?.nextToBoard(model: $0)
        }
    }
}

struct OutputModel: BoardOutputModel {
    let identifier: BoardID
    let data: Any?
}
