//
//  Activation.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 6/9/21.
//

import Foundation

public protocol Completable {
    func complete(_ isDone: Bool)
}

public struct MainboardCompleter: Completable {
    let destinationID: BoardID
    let mainboard: MotherboardType

    /// Complete a board from its Motherboard
    public func complete(_ isDone: Bool = true) {
        mainboard.getBoard(identifier: destinationID)?.complete(isDone)
    }
}

public struct BoardCompleter: Completable {
    let destinationID: BoardID
    let source: ActivatableBoard

    /// Complete the destination board which has the same Motherboard with the `source`
    public func complete(_ isDone: Bool = true) {
        let completeAction = CompleteAction(identifier: destinationID, isDone: isDone)
        source.sendToMotherboard(data: completeAction)
    }
}

public extension ActivatableBoard {
    func completer(_ destinationID: BoardID) -> BoardCompleter {
        BoardCompleter(destinationID: destinationID, source: self)
    }
}

public extension MotherboardType {
    func completer(_ destinationID: BoardID) -> MainboardCompleter {
        MainboardCompleter(destinationID: destinationID, mainboard: self)
    }
}

// MARK: - Activate

public protocol BoardActivating {
    associatedtype Input

    func activate(with input: Input)
}

public extension BoardActivating where Input: ExpressibleByNilLiteral {
    func activate() {
        activate(with: nil)
    }
}

public extension BoardActivating where Input == Void {
    func activate() {
        activate(with: ())
    }
}

// iOS 13+ internal
public struct MainboardActivation<Input>: BoardActivating {
    let destinationID: BoardID
    let mainboard: MotherboardType

    /// Activate a board from its Motherboard
    public func activate(with input: Input) {
        mainboard.activateBoard(.target(destinationID, input))
    }
}

// iOS 13+ internal
public struct BoardActivation<Input>: BoardActivating {
    let destinationID: BoardID
    let source: ActivatableBoard

    /// Activate the next board in the same Motherboard with the `source`
    public func activate(with input: Input) {
        source.nextToBoard(.target(destinationID, input))
    }
}

public extension ActivatableBoard {
    // When min iOS version up to 13+, please change return type to opaque type `some BoardActivatable`, and make concrete type `BoardActivation` to `internal`.
    func activation<Input>(_ destinationID: BoardID, with inputType: Input.Type) -> BoardActivation<Input> {
        BoardActivation(destinationID: destinationID, source: self)
    }

    func activation(_ destinationID: BoardID) -> BoardActivation<Any?> {
        activation(destinationID, with: Any?.self)
    }
}

public extension MotherboardType {
    func activation<Input>(_ destinationID: BoardID, with inputType: Input.Type) -> MainboardActivation<Input> {
        MainboardActivation(destinationID: destinationID, mainboard: self)
    }

    func activation(_ destinationID: BoardID) -> MainboardActivation<Any?> {
        activation(destinationID, with: Any?.self)
    }
}

// MARK: - Flow

public protocol FlowHandling {
    associatedtype Output

    func addTarget<Target>(_ target: Target, action: @escaping (Target, Output) -> Void)
    func bind(to bus: Bus<Output>)
    func sendOutput<OutBoard>(through board: OutBoard) where OutBoard: GuaranteedOutputSendingBoard, OutBoard.OutputType == Output
    func handle(_ handler: @escaping (Output) -> Void)
    func activate<NextActivation>(_ activation: NextActivation) where NextActivation: BoardActivating, NextActivation.Input == Output
}

public extension FlowHandling {
    func bind(to bus: Bus<Output?>) {
        handle { [weak bus] output in
            bus?.transport(input: output)
        }
    }

    func sendOutput<OutBoard>(through board: OutBoard) where OutBoard: GuaranteedOutputSendingBoard, OutBoard.OutputType == Output? {
        handle { [weak board] output in
            board?.sendOutput(output)
        }
    }
}

public extension FlowHandling where Output == Void {
    func addTarget<Target>(_ target: Target, action: @escaping (Target) -> Void) {
        addTarget(target) { internalTarget, _ in
            action(internalTarget)
        }
    }

    func handle(_ handler: @escaping () -> Void) {
        handle { (_: Void) in
            handler()
        }
    }
}

// iOS 13+ internal
public struct FlowHandler<Output>: FlowHandling {
    let matchedIdentifier: BoardID
    let manager: FlowManageable

    public func addTarget<Target>(_ target: Target, action: @escaping (Target, Output) -> Void) {
        manager.registerGuaranteedFlow(matchedIdentifiers: matchedIdentifier, target: target, handler: action)
    }

    public func bind(to bus: Bus<Output>) {
        manager.registerGuaranteedFlow(matchedIdentifiers: matchedIdentifier, bindToBus: bus)
    }

    public func sendOutput<OutBoard>(through board: OutBoard) where OutBoard: GuaranteedOutputSendingBoard, OutBoard.OutputType == Output {
        manager.registerGuaranteedFlow(matchedIdentifiers: matchedIdentifier, sendOutputThrough: board)
    }

    public func handle(_ handler: @escaping (Output) -> Void) {
        let noneTarget = NoneTarget()
        manager.registerGuaranteedFlow(matchedIdentifiers: matchedIdentifier, target: noneTarget, handler: { _, output in
            handler(output)
        })
    }

    public func activate<NextActivation>(_ activation: NextActivation) where NextActivation: BoardActivating, NextActivation.Input == Output {
        handle { output in
            activation.activate(with: output)
        }
    }

    public var specifications: GuaranteedOutputSpecifications<Output> {
        return GuaranteedOutputSpecifications<Output>(identifier: matchedIdentifier, valueType: Output.self)
    }
}

public struct CompletionFlowHandler {
    let matchedIdentifier: BoardID
    let manager: FlowManageable

    public func handle(_ handler: @escaping () -> Void) {
        manager.registerGeneralFlow { (output: CompleteAction) in
            if output.identifier == matchedIdentifier {
                handler()
            }
        }
    }

    public func addTarget<Target>(_ target: Target, action: @escaping (Target) -> Void) {
        manager.registerGeneralFlow(target: target) { (target, output: CompleteAction) in
            if output.identifier == matchedIdentifier {
                action(target)
            }
        }
    }
}

public struct ActionFlowHandler<Action: BoardFlowAction> {
    let matchedIdentifier: BoardID
    let manager: FlowManageable

    public func handle(_ handler: @escaping (Action) -> Void) {
        manager.registerGeneralFlow { (output: Action) in
            handler(output)
        }
    }

    public func addTarget<Target>(_ target: Target, action: @escaping (Target, Action) -> Void) {
        manager.registerGeneralFlow(target: target) { (target, output: Action) in
            action(target, output)
        }
    }
}

public extension FlowManageable {
    func matchedFlow<Output>(_ identifier: BoardID, with outputType: Output.Type) -> FlowHandler<Output> {
        FlowHandler(matchedIdentifier: identifier, manager: self)
    }

    func matchedFlow(_ identifier: BoardID) -> FlowHandler<Any?> {
        matchedFlow(identifier, with: Any?.self)
    }

    func completionFlow(_ identifier: BoardID) -> CompletionFlowHandler {
        CompletionFlowHandler(matchedIdentifier: identifier, manager: self)
    }

    func actionFlow<Action: BoardFlowAction>(_ identifier: BoardID, with actionType: Action.Type) -> ActionFlowHandler<Action> {
        ActionFlowHandler(matchedIdentifier: identifier, manager: self)
    }
}

// MARK: - Interaction

public protocol BoardInteracting {
    associatedtype IncomeCommand

    func send(command: IncomeCommand)
}

// iOS 13+ internal
public struct MainboardInteraction<Input>: BoardInteracting {
    let destinationID: BoardID
    let mainboard: MotherboardType

    public func send(command: Input) {
        mainboard.interactWithBoard(.target(destinationID, command))
    }
}

// iOS 13+ internal
public struct BoardInteraction<Input>: BoardInteracting {
    let destinationID: BoardID
    let source: ActivatableBoard

    public func send(command: Input) {
        source.interactWithOtherBoard(.target(destinationID, command))
    }
}

public extension ActivatableBoard {
    // When min iOS version up to 13+, please change return type to opaque type `some BoardActivatable`, and make concrete type `BoardActivation` to `internal`.
    func interaction<Input>(_ destinationID: BoardID, with inputType: Input.Type) -> BoardInteraction<Input> {
        BoardInteraction(destinationID: destinationID, source: self)
    }

    func interaction(_ destinationID: BoardID) -> BoardInteraction<Any?> {
        interaction(destinationID, with: Any?.self)
    }
}

public extension MotherboardType {
    func interaction<Input>(_ destinationID: BoardID, with inputType: Input.Type) -> MainboardInteraction<Input> {
        MainboardInteraction(destinationID: destinationID, mainboard: self)
    }

    func interaction(_ destinationID: BoardID) -> MainboardInteraction<Any?> {
        interaction(destinationID, with: Any?.self)
    }
}

struct NoneTarget {}
