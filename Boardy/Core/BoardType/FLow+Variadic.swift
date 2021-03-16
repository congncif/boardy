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
    public func registerFlow<Target: AnyObject, Output>(
        matchedIdentifiers: FlowID...,
        target: Target,
        uniqueOutputType: Output.Type = Output.self,
        nextHandler: @escaping (Target, Output) -> Void
    ) -> Self {
        let listIds: [FlowID] = matchedIdentifiers
        return self.registerFlow(matchedIdentifiers: listIds, target: target, nextHandler: nextHandler)
    }

    /// Guaranteed Flow ensures data must match with Output type if not handler will fatal in debug and will be skipped in release mode.
    @discardableResult
    public func registerGuaranteedFlow<Target: AnyObject, Output>(
        matchedIdentifiers: FlowID...,
        target: Target,
        uniqueOutputType: Output.Type = Output.self,
        handler: @escaping (Target, Output) -> Void
    ) -> Self {
        let listIds: [FlowID] = matchedIdentifiers
        return self.registerGuaranteedFlow(matchedIdentifiers: listIds, target: target, uniqueOutputType: uniqueOutputType, handler: handler)
    }

    /// Chain Flow handles step by step of chain of handlers until a handler in chain is executed. Eventually handler is mandatory to register this flow.
    public func registerChainFlow<Target: AnyObject>(matchedIdentifiers: FlowID..., target: Target) -> ChainBoardFlow<Target> {
        let listIds: [FlowID] = matchedIdentifiers
        return self.registerChainFlow(matchedIdentifiers: listIds, target: target)
    }
}
