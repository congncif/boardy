//
//  InteractableBoard.swift
//  Boardy
//
//  Created by FOLY on 10/24/20.
//

import Foundation

public protocol BoardCommandModel {
    var identifier: BoardID { get }
    var data: Any? { get }
}

public protocol InteractableBoard: ActivatableBoard {
    func interact(command: BoardCommandModel)
}

extension InteractableBoard {
    public func interact(command: BoardCommandModel) {
        #if DEBUG
        print("\(String(describing: self)) \n⚠️ Has called \(#function) with \(command)")
        #endif
    }
}

public protocol GuaranteedInteractableBoard: InteractableBoard {
    /// Incoming Command type
    associatedtype BoardCommandType: BoardCommandModel

    /// Implement the function `interact(guaranteedCommand:)` to react with a received Command
    func interact(guaranteedCommand: BoardCommandType)
}

extension GuaranteedInteractableBoard {
    public func interact(command: BoardCommandModel) {
        guard let dedicatedCommand = command as? BoardCommandType else {
            #if DEBUG
            assertionFailure("\(String(describing: self)) \n⚠️ Received command \(command) while expected type is \(BoardCommandType.self)")
            #endif
            return
        }
        interact(guaranteedCommand: dedicatedCommand)
    }
}

public protocol GuaranteedCommandBoard: InteractableBoard {
    associatedtype CommandType

    func interact(command: CommandType)
}

extension GuaranteedCommandBoard {
    public func interact(command: BoardCommandModel) {
        guard let commandData = command.data as? CommandType else {
            #if DEBUG
            assertionFailure("\(String(describing: self)) \n⚠️ Received command \(command.data) while expected type is \(CommandType.self)")
            #endif
            return
        }
        interact(command: commandData)
    }
}

// MARK: - BoardCommand with Input

public struct BoardCommand<Input>: BoardCommandModel {
    public let identifier: BoardID
    public let input: Input

    public var data: Any? { input }

    public init(identifier: BoardID, input: Input) {
        self.identifier = identifier
        self.input = input
    }
}

extension BoardCommand {
    public func withIdentifier(_ identifier: BoardID) -> BoardCommand {
        BoardCommand(identifier: identifier, input: input)
    }
}

extension BoardCommand {
    public static func target<Input>(_ id: BoardID, _ input: Input) -> BoardCommand<Input> {
        BoardCommand<Input>(identifier: id, input: input)
    }
}

extension BoardCommand where Input == Void {
    public init(identifier: BoardID) {
        self.init(identifier: identifier, input: ())
    }

    public static func target(_ id: BoardID) -> BoardCommand<Input> {
        BoardCommand<Input>(identifier: id)
    }
}

extension BoardCommand where Input: ExpressibleByNilLiteral {
    public init(identifier: BoardID) {
        self.init(identifier: identifier, input: nil)
    }

    public static func target(_ id: BoardID) -> BoardCommand<Input> {
        BoardCommand<Input>(identifier: id)
    }
}

/*
 // MARK: - InteractableBoard sending a type safe command

 /// For Sender Board who want to guarantee always sending a type safe command
 public protocol GuaranteedCommandSendingBoard: IdentifiableBoard {
     associatedtype OutgoingCommand: BoardCommandModel
 }

 extension GuaranteedCommandSendingBoard {
     public func sendCommand(_ command: OutgoingCommand) {
         interactWithOtherBoard(command: command)
     }
 }
  */
