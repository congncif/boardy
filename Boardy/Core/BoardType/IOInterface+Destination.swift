//
//  IOInterface+Destination.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 21/8/24.
//

import Foundation

public class MainboardDestination {
    public init(destinationID: BoardID, mainboard: any FlowMotherboard) {
        self.destinationID = destinationID
        self.mainboard = mainboard
    }

    public let destinationID: BoardID
    let mainboard: FlowMotherboard
}

public extension MotherboardType where Self: FlowManageable {
    func ioDestination(_ identifier: BoardID) -> MainboardDestination {
        MainboardDestination(destinationID: identifier, mainboard: self)
    }
}

public extension MainboardDestination {
    func activation<Input>(with inputType: Input.Type = Input.self) -> MainboardActivation<Input> {
        mainboard.activation(destinationID, with: inputType)
    }

    func interaction<Command>(with commandType: Command.Type = Command.self) -> MainboardInteraction<Command> {
        mainboard.interaction(destinationID, with: commandType)
    }

    func flow<Output>(with outputType: Output.Type = Output.self) -> FlowHandler<Output> {
        mainboard.matchedFlow(destinationID, with: outputType)
    }

    func actionFlow<Action: BoardFlowAction>(with actionType: Action.Type = Action.self) -> ActionFlowHandler<Action> {
        mainboard.actionFlow(destinationID, with: actionType)
    }

    var completer: MainboardCompleter {
        mainboard.completer(destinationID)
    }

    var completion: CompletionFlowHandler {
        mainboard.completionFlow(destinationID)
    }
}

public final class MainboardGenericDestination<Input, Output, Command, Action: BoardFlowAction>: MainboardDestination {
    public init(destinationID: BoardID, mainboard: any FlowMotherboard, inputType _: Input.Type = Input.self, outputType _: Output.Type = Output.self, commandType _: Command.Type = Command.self, actionType _: Action.Type = Action.self) {
        super.init(destinationID: destinationID, mainboard: mainboard)
    }

    public var activation: MainboardActivation<Input> {
        self.activation(with: Input.self)
    }

    public var interaction: MainboardInteraction<Command> {
        self.interaction(with: Command.self)
    }

    public var flow: FlowHandler<Output> {
        self.flow(with: Output.self)
    }

    public var actionFlow: ActionFlowHandler<Action> {
        self.actionFlow(with: Action.self)
    }
}

public class BoardDestination {
    public init(destinationID: BoardID, source: any ActivatableBoard) {
        self.destinationID = destinationID
        self.source = source
    }

    public let destinationID: BoardID
    let source: ActivatableBoard
}

public extension ActivatableBoard {
    func ioDestination(_ identifier: BoardID) -> BoardDestination {
        BoardDestination(destinationID: identifier, source: self)
    }
}

public final class BoardGenericDestination<Input, Command>: BoardDestination {
    public init(destinationID: BoardID, source: any ActivatableBoard, inputType _: Input.Type = Input.self, commandType _: Command.Type = Command.self) {
        super.init(destinationID: destinationID, source: source)
    }

    public var activation: BoardActivation<Input> {
        activation(with: Input.self)
    }

    public var interaction: BoardInteraction<Command> {
        self.interaction(with: Command.self)
    }
}

public extension BoardDestination {
    func activation<Input>(with inputType: Input.Type = Input.self) -> BoardActivation<Input> {
        source.activation(destinationID, with: inputType)
    }

    func interaction<Command>(with commandType: Command.Type = Command.self) -> BoardInteraction<Command> {
        source.interaction(destinationID, with: commandType)
    }

    var completer: BoardCompleter {
        source.completer(destinationID)
    }
}
