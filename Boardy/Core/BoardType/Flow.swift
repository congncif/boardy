//
//  Flow.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation

/// Special data type which should be forwarded through all of steps of the flow.
public protocol BoardFlowAction {}

public typealias FlowID = String

public protocol BoardFlow {
    func matchWithBoard(_ board: IdentifiableBoard) -> Bool
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
    public func registerGeneralFlow<Input>(nextHandler: @escaping (Input) -> Void) -> Self {
        let generalFlow = BoardActivateFlow(matcher: { _ in true }, nextHandler: { data in
            guard let input = data as? Input else { return }
            nextHandler(input)
        })
        registerFlow(generalFlow)
        return self
    }
}

extension FlowManageable where Self: MotherboardType {
    @discardableResult
    public func registerFlowSteps(_ flowSteps: [IDFlowStep]) -> Self {
        let activateFlows = flowSteps.map { flowStep in
            BoardActivateFlow(
                matcher: { board -> Bool in
                    flowStep.source == board.identifier
                },
                nextHandler: { [weak self] data in
                    self?.activateBoard(identifier: flowStep.destination, withOption: data)
                }
            )
        }
        registerFlows(activateFlows)
        return self
    }
}

public struct BoardActivateFlow: BoardFlow {
    private let matcher: (IdentifiableBoard) -> Bool
    private let nextHandler: (Any?) -> Void

    public init(matcher: @escaping (IdentifiableBoard) -> Bool,
                nextHandler: @escaping (Any?) -> Void) {
        self.matcher = matcher
        self.nextHandler = nextHandler
    }

    public init<Input>(matcher: @escaping (IdentifiableBoard) -> Bool,
                       guaranteedNextHandler: @escaping (Input) -> Void) {
        self.matcher = matcher
        self.nextHandler = { input in
            guard let data = input as? Input else {
                assertionFailure("Cannot convert input from \(String(describing: input)) to type \(Input.self)")
                return
            }
            guaranteedNextHandler(data)
        }
    }

    public init<Input>(matcher: @escaping (IdentifiableBoard) -> Bool,
                       dedicatedNextHandler: @escaping (Input?) -> Void) {
        self.matcher = matcher
        self.nextHandler = { input in
            let data = input as? Input
            dedicatedNextHandler(data)
        }
    }

    public init(matchedIdentifiers: [FlowID], nextHandler: @escaping (Any?) -> Void) {
        self.init(matcher: { matchedIdentifiers.contains($0.identifier) }, nextHandler: nextHandler)
    }

    public init<Input>(matchedIdentifiers: [FlowID], dedicatedNextHandler: @escaping (Input?) -> Void) {
        self.init(matcher: { matchedIdentifiers.contains($0.identifier) }, dedicatedNextHandler: dedicatedNextHandler)
    }

    public init<Input>(matchedIdentifiers: [FlowID], guaranteedNextHandler: @escaping (Input) -> Void) {
        self.init(matcher: { matchedIdentifiers.contains($0.identifier) }, guaranteedNextHandler: guaranteedNextHandler)
    }

    public func matchWithBoard(_ board: IdentifiableBoard) -> Bool {
        return matcher(board)
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

infix operator >=>: MultiplicationPrecedence
public func >=> (left: FlowID, right: FlowID) -> [IDFlowStep] {
    return [IDFlowStep(source: left, destination: right)]
}

public func >=> (left: [IDFlowStep], right: FlowID) -> [IDFlowStep] {
    guard let lastLeft = left.last else {
        assertionFailure("Empty flow is not allowed")
        return []
    }
    return left + [IDFlowStep(source: lastLeft.destination, destination: right)]
}

extension BoardDelegate where Self: FlowManageable {
    public func board(_ board: IdentifiableBoard, didSendData data: Any?) {
        flows.filter { $0.matchWithBoard(board) }.forEach { $0.doNext(data) }
    }
}

public typealias FlowMotherboard = MotherboardType & FlowManageable

// MARK: - Forward functions

extension FlowManageable {
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
