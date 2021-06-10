//
//  Activation.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 6/9/21.
//

import Foundation

// MARK: - Activate

public protocol BoardActivating {
    associatedtype Input

    func activate(with input: Input)
}

extension BoardActivating where Input: ExpressibleByNilLiteral {
    public func activate() {
        activate(with: nil)
    }
}

extension BoardActivating where Input == Void {
    public func activate() {
        activate(with: ())
    }
}

// iOS 13+ internal
public struct MainboardActivation<Input>: BoardActivating {
    let destinationID: BoardID
    let mainboard: MotherboardType

    public func activate(with input: Input) {
        mainboard.activateBoard(.target(destinationID, input))
    }
}

// iOS 13+ internal
public struct BoardActivation<Input>: BoardActivating {
    let destinationID: BoardID
    let source: ActivatableBoard

    public func activate(with input: Input) {
        source.nextToBoard(.target(destinationID, input))
    }
}

extension ActivatableBoard {
    // When min iOS version up to 13+, please change return type to opaque type `some BoardActivatable`, and make concrete type `BoardActivation` to `internal`.
    public func activation<Input>(_ destinationID: BoardID, with inputType: Input.Type) -> BoardActivation<Input> {
        BoardActivation(destinationID: destinationID, source: self)
    }

    public func activation(_ destinationID: BoardID) -> BoardActivation<Any> {
        activation(destinationID, with: Any.self)
    }
}

extension MotherboardType {
    public func activation<Input>(_ destinationID: BoardID, with inputType: Input.Type) -> MainboardActivation<Input> {
        MainboardActivation(destinationID: destinationID, mainboard: self)
    }

    public func activation(_ destinationID: BoardID) -> MainboardActivation<Any> {
        activation(destinationID, with: Any.self)
    }
}

// MARK: - Flow

public protocol FlowHandling {
    associatedtype Output

    func addTarget<Target>(_ target: Target, action: @escaping (Target, Output) -> Void)
    func bind(to bus: Bus<Output>)
}

extension FlowHandling where Output == Void {
    public func addTarget<Target>(_ target: Target, action: @escaping (Target) -> Void) {
        addTarget(target) { internalTarget, _ in
            action(internalTarget)
        }
    }
}

// iOS 13+ internal
public struct FlowHandler<Output>: FlowHandling {
    let matchedIdentifier: BoardID
    let manager: FlowManageable

    public func addTarget<Target>(_ target: Target, action: @escaping (Target, Output) -> Void) {
        manager.registerGuaranteedFlow(matchedIdentifiers: matchedIdentifier, target: target, uniqueOutputType: Output.self, handler: action)
    }

    public func bind(to bus: Bus<Output>) {
        manager.registerGuaranteedFlow(matchedIdentifiers: matchedIdentifier, bindToBus: bus)
    }
}

extension FlowManageable {
    public func matchedFlow<Output>(_ identifier: BoardID, with outputType: Output.Type) -> FlowHandler<Output> {
        return FlowHandler(matchedIdentifier: identifier, manager: self)
    }

    public func matchedFlow(_ identifier: BoardID) -> FlowHandler<Any> {
        matchedFlow(identifier, with: Any.self)
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
        mainboard.interactWithOtherBoard(.target(destinationID, command))
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

extension ActivatableBoard {
    // When min iOS version up to 13+, please change return type to opaque type `some BoardActivatable`, and make concrete type `BoardActivation` to `internal`.
    public func interaction<Input>(_ destinationID: BoardID, with inputType: Input.Type) -> BoardInteraction<Input> {
        BoardInteraction(destinationID: destinationID, source: self)
    }

    public func interaction(_ destinationID: BoardID) -> BoardInteraction<Any> {
        interaction(destinationID, with: Any.self)
    }
}

extension MotherboardType {
    public func interaction<Input>(_ destinationID: BoardID, with inputType: Input.Type) -> MainboardInteraction<Input> {
        MainboardInteraction(destinationID: destinationID, mainboard: self)
    }

    public func interaction(_ destinationID: BoardID) -> MainboardInteraction<Any> {
        interaction(destinationID, with: Any.self)
    }
}
