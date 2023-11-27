//
//  BoardActivateFlow.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 27/11/2023.
//

import Foundation

public struct BoardActivateFlow: BoardFlow {
    public let identifier: String
    private let matcher: (BoardOutputModel) -> Bool
    private let outputNextHandler: (BoardOutputModel) -> Void

    public init(
        identifier: String = UUID().uuidString,
        matcher: @escaping (BoardOutputModel) -> Bool,
        outputNextHandler: @escaping (BoardOutputModel) -> Void
    ) {
        self.identifier = identifier
        self.matcher = matcher
        self.outputNextHandler = outputNextHandler
    }

    public init(
        identifier: String = UUID().uuidString,
        matcher: @escaping (BoardOutputModel) -> Bool,
        nextHandler: @escaping (Any?) -> Void
    ) {
        self.identifier = identifier
        self.matcher = matcher
        outputNextHandler = {
            nextHandler($0.data)
        }
    }

    public init<Output>(
        identifier: String = UUID().uuidString,
        matcher: @escaping (BoardOutputModel) -> Bool,
        dedicatedNextHandler: @escaping (Output?) -> Void
    ) {
        self.identifier = identifier
        self.matcher = matcher
        outputNextHandler = { output in
            let data = output.data as? Output
            dedicatedNextHandler(data)
        }
    }

    public init<Output>(
        identifier: String = UUID().uuidString,
        matcher: @escaping (BoardOutputModel) -> Bool,
        guaranteedNextHandler: @escaping (Output) -> Void
    ) {
        self.identifier = identifier
        self.matcher = matcher
        outputNextHandler = { output in
            guard let data = output.data as? Output else {
                // Guaranteed output is Silent Data Types otherwise raise an assertion.
                guard isSilentData(output.data) else {
                    assertionFailure("🔥 [Flow with mismatch data type] [\(output.identifier)]  Cannot convert output of board \(output.identifier) from type \(String(describing: output.data)) to type \(Output.self)")
                    return
                }
                return
            }
            guaranteedNextHandler(data)
        }
    }

    public init(identifier: String = UUID().uuidString, matchedIdentifiers: [FlowStepID], outputNextHandler: @escaping (BoardOutputModel) -> Void) {
        self.init(identifier: identifier, matcher: { matchedIdentifiers.contains($0.identifier) }, outputNextHandler: outputNextHandler)
    }

    public init(identifier: String = UUID().uuidString, matchedIdentifiers: [FlowStepID], nextHandler: @escaping (Any?) -> Void) {
        self.init(identifier: identifier, matcher: { matchedIdentifiers.contains($0.identifier) }, nextHandler: nextHandler)
    }

    public init<Output>(identifier: String = UUID().uuidString, matchedIdentifiers: [FlowStepID], dedicatedNextHandler: @escaping (Output?) -> Void) {
        self.init(identifier: identifier, matcher: { matchedIdentifiers.contains($0.identifier) }, dedicatedNextHandler: dedicatedNextHandler)
    }

    public init<Output>(identifier: String = UUID().uuidString, matchedIdentifiers: [FlowStepID], guaranteedNextHandler: @escaping (Output) -> Void) {
        self.init(identifier: identifier, matcher: { matchedIdentifiers.contains($0.identifier) }, guaranteedNextHandler: guaranteedNextHandler)
    }

    public func match(with output: BoardOutputModel) -> Bool {
        matcher(output)
    }

    public func doNext(with output: BoardOutputModel) {
        outputNextHandler(output)
    }
}
