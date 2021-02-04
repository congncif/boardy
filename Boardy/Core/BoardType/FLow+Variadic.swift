//
//  FLow+Variadic.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 2/4/21.
//

import Foundation

extension FlowManageable {
    @discardableResult
    public func registerFlow<Output>(matchedIdentifiers: FlowID..., nextHandler: @escaping (Output) -> Void) -> Self {
        let generalFlow = BoardActivateFlow(matchedIdentifiers: matchedIdentifiers, guaranteedNextHandler: nextHandler)
        registerFlow(generalFlow)
        return self
    }

    @discardableResult
    public func registerGuaranteedFlow<Target: AnyObject, Output>(
        matchedIdentifiers: FlowID...,
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

    public func registerChainFlow<Target: AnyObject>(matchedIdentifiers: FlowID..., target: Target) -> ChainBoardFlow<Target> {
        let flow = ChainBoardFlow(manager: self, target: target) {
            matchedIdentifiers.contains($0.identifier)
        }
        return flow
    }
}
