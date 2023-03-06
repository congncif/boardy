//
//  FLow+Variadic.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 2/4/21.
//

import Foundation

public extension FlowManageable {
    /// Default flow is a dedicated flow with specified output type. If data matches with Output type, handler will be executed, otherwise the handler will be skipped.
    @discardableResult
    func registerFlow<Target, Output>(
        matchedIdentifiers: FlowStepID...,
        target: Target,
        uniqueOutputType: Output.Type = Output.self,
        nextHandler: @escaping (Target, Output) -> Void
    ) -> Self {
        let listIds: [FlowStepID] = matchedIdentifiers
        return registerFlow(matchedIdentifiers: listIds, target: target, uniqueOutputType: uniqueOutputType, nextHandler: nextHandler)
    }

    @discardableResult
    func registerFlow<Output>(
        matchedIdentifiers: FlowStepID...,
        bindToBus bus: Bus<Output>
    ) -> Self {
        let listIds: [FlowStepID] = matchedIdentifiers
        return registerFlow(matchedIdentifiers: listIds, target: bus, uniqueOutputType: Output.self, nextHandler: { target, data in
            target.transport(input: data)
        })
    }

    @discardableResult
    func registerFlow<Output, OutBoard>(
        matchedIdentifiers: FlowStepID...,
        uniqueOutputType _: Output.Type = Output.self,
        sendOutputThrough board: OutBoard
    ) -> Self where OutBoard: GuaranteedOutputSendingBoard, OutBoard.OutputType == Output {
        let listIds: [FlowStepID] = matchedIdentifiers
        return registerFlow(matchedIdentifiers: listIds, target: board, uniqueOutputType: Output.self, nextHandler: { target, data in
            target.sendOutput(data)
        })
    }

    /// Guaranteed Flow ensures data must match with Output type if not handler will fatal in debug and will be skipped in release mode.
    @discardableResult
    func registerGuaranteedFlow<Target, Output>(
        matchedIdentifiers: FlowStepID...,
        target: Target,
        uniqueOutputType: Output.Type = Output.self,
        handler: @escaping (Target, Output) -> Void
    ) -> Self {
        let listIds: [FlowStepID] = matchedIdentifiers
        return registerGuaranteedFlow(matchedIdentifiers: listIds, target: target, uniqueOutputType: uniqueOutputType, handler: handler)
    }

    @discardableResult
    func registerGuaranteedFlow<Output>(
        matchedIdentifiers: FlowStepID...,
        bindToBus bus: Bus<Output>
    ) -> Self {
        let listIds: [FlowStepID] = matchedIdentifiers
        return registerGuaranteedFlow(matchedIdentifiers: listIds, target: bus, uniqueOutputType: Output.self, handler: { target, data in
            target.transport(input: data)
        })
    }

    @discardableResult
    func registerGuaranteedFlow<Output, OutBoard>(
        matchedIdentifiers: FlowStepID...,
        uniqueOutputType _: Output.Type = Output.self,
        sendOutputThrough board: OutBoard
    ) -> Self where OutBoard: GuaranteedOutputSendingBoard, OutBoard.OutputType == Output {
        let listIds: [FlowStepID] = matchedIdentifiers
        return registerGuaranteedFlow(matchedIdentifiers: listIds, target: board, uniqueOutputType: Output.self, handler: { target, data in
            target.sendOutput(data)
        })
    }

    /// Chain Flow handles step by step of chain of handlers until a handler in chain is executed. Eventually handler is mandatory to register this flow.
    func registerChainFlow<Target>(matchedIdentifiers: FlowStepID..., target: Target) -> ChainBoardFlow<Target> {
        let listIds: [FlowStepID] = matchedIdentifiers
        return registerChainFlow(matchedIdentifiers: listIds, target: target)
    }

    @discardableResult
    func registerCompletionFlow(
        matchedIdentifiers: FlowStepID...,
        nextHandler: @escaping (_ isDone: Bool) -> Void
    ) -> Self {
        let listIds: [FlowStepID] = matchedIdentifiers
        return registerCompletionFlow(matchedIdentifiers: listIds, nextHandler: nextHandler)
    }
}
