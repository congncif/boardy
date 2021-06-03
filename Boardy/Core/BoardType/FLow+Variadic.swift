//
//  FLow+Variadic.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 2/4/21.
//

import Foundation

extension FlowManageable {
    /// Default flow is a dedicated flow with specified output type. If data matches with Output type, handler will be executed, otherwise the handler will be skipped.
    @discardableResult
    public func registerFlow<Target, Output>(
        matchedIdentifiers: FlowID...,
        target: Target,
        uniqueOutputType: Output.Type = Output.self,
        nextHandler: @escaping (Target, Output) -> Void
    ) -> Self {
        let listIds: [FlowID] = matchedIdentifiers
        return self.registerFlow(matchedIdentifiers: listIds, target: target, uniqueOutputType: uniqueOutputType, nextHandler: nextHandler)
    }

    @discardableResult
    public func registerFlow<Output>(
        matchedIdentifiers: FlowID...,
        bindToBus bus: Bus<Output>
    ) -> Self {
        let listIds: [FlowID] = matchedIdentifiers
        return self.registerFlow(matchedIdentifiers: listIds, target: bus, uniqueOutputType: Output.self, nextHandler: { target, data in
            target.transport(input: data)
        })
    }

    /// Guaranteed Flow ensures data must match with Output type if not handler will fatal in debug and will be skipped in release mode.
    @discardableResult
    public func registerGuaranteedFlow<Target, Output>(
        matchedIdentifiers: FlowID...,
        target: Target,
        uniqueOutputType: Output.Type = Output.self,
        handler: @escaping (Target, Output) -> Void
    ) -> Self {
        let listIds: [FlowID] = matchedIdentifiers
        return self.registerGuaranteedFlow(matchedIdentifiers: listIds, target: target, uniqueOutputType: uniqueOutputType, handler: handler)
    }

    @discardableResult
    public func registerGuaranteedFlow<Output>(
        matchedIdentifiers: FlowID...,
        bindToBus bus: Bus<Output>
    ) -> Self {
        let listIds: [FlowID] = matchedIdentifiers
        return self.registerGuaranteedFlow(matchedIdentifiers: listIds, target: bus, uniqueOutputType: Output.self, handler: { target, data in
            target.transport(input: data)
        })
    }

    /// Chain Flow handles step by step of chain of handlers until a handler in chain is executed. Eventually handler is mandatory to register this flow.
    public func registerChainFlow<Target>(matchedIdentifiers: FlowID..., target: Target) -> ChainBoardFlow<Target> {
        let listIds: [FlowID] = matchedIdentifiers
        return self.registerChainFlow(matchedIdentifiers: listIds, target: target)
    }
}
