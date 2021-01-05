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
        print("⚠️ \(String(describing: self)) has called \(#function) with \(command)")
        #endif
    }
}

public protocol GuaranteedInteractableBoard: InteractableBoard {
    associatedtype Command: BoardCommandModel

    func interact(guaranteedCommand: Command)
}

extension GuaranteedInteractableBoard {
    public func interact(command: BoardCommandModel) {
        guard let dedicatedCommand = command as? Command else {
            #if DEBUG
            print("⚠️ The command was not sent. \(String(describing: self)) has called \(#function) with \(command) while expected model type is \(Command.self)")
            #endif
            return
        }
        interact(guaranteedCommand: dedicatedCommand)
    }
}

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
