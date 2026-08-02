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
        mainboardBox.setObject(mainboard)
    }

    public let destinationID: BoardID

    private let mainboardBox = ObjectBox()

    /// The motherboard is held weakly.
    ///
    /// A destination is meant to be stored — that is the point of the type — and the natural place
    /// to store it is the motherboard it came from, or one of its boards. Holding it strongly makes
    /// that shape a retain cycle, and every other reference in this framework (`ObjectBox`,
    /// `ContentBox`, `BarrierOwnerToken`, `BoardProducerBox`) is already weak.
    ///
    /// Once the motherboard is gone the destination becomes inert: it answers with a detached
    /// stand-in, so sending through it does nothing instead of trapping.
    var mainboard: FlowMotherboard {
        mainboardBox.unboxed(FlowMotherboard.self) ?? DetachedDestination.makeMotherboard()
    }
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
        sourceBox.setObject(source)
    }

    public let destinationID: BoardID

    private let sourceBox = ObjectBox()

    /// The source board is held weakly; see ``MainboardDestination/mainboard`` for why.
    ///
    /// Once the source is gone the destination becomes inert: it answers with a detached stand-in
    /// that has no motherboard, so messages sent through it go nowhere.
    var source: ActivatableBoard {
        sourceBox.unboxed(ActivatableBoard.self) ?? DetachedDestination.makeBoard()
    }
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

// MARK: - Detached stand-ins

/// Answers every identifier with a board that does nothing.
///
/// A detached motherboard must not fall back to `NoBoardProducer`: that answers with a ``NoBoard``,
/// which presents a "feature not found" alert and traps in DEBUG when it has no context. Sending
/// through a dead destination should be silent, not fatal.
private final class InertBoard: Board, ActivatableBoard {
    func activate(withOption _: Any?) {}
}

private final class InertBoardProducer: ActivatableBoardProducer {
    func produceBoard(identifier: BoardID) -> ActivatableBoard? {
        InertBoard(identifier: identifier)
    }

    func produceGatewayBoard(identifier _: BoardID) -> ActivatableBoard? {
        nil
    }

    func matchBoard(withIdentifier _: BoardID, to anotherIdentifier: BoardID) -> ActivatableBoard? {
        InertBoard(identifier: anotherIdentifier)
    }
}

private enum DetachedDestination {
    static let boardIdentifier: BoardID = "boardy.detached-destination-source"

    /// Stand-in source for a destination whose board is gone. It has no motherboard, so anything
    /// sent through it goes nowhere.
    static func makeBoard() -> ActivatableBoard {
        InertBoard(identifier: boardIdentifier)
    }

    /// Stand-in for a destination whose motherboard is gone.
    static func makeMotherboard() -> FlowMotherboard {
        Motherboard(identifier: boardIdentifier, boardProducer: InertBoardProducer())
    }
}
