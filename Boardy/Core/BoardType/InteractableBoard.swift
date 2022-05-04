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
    func interact(command: Any?)
}

public extension InteractableBoard {
    func interact(command: BoardCommandModel) {
        #if DEBUG
            print("\(String(describing: self)) \n⚠️ Has called \(#function) with \(command)")
        #endif
    }
}

public protocol GuaranteedCommandBoard: InteractableBoard {
    associatedtype CommandType

    func interact(guaranteedCommand: CommandType)
}

public extension GuaranteedCommandBoard {
    func interact(command: Any?) {
        guard let commandData = command as? CommandType else {
            #if DEBUG
                assertionFailure("\(String(describing: self)) \n⚠️ Received command \(String(describing: command)) while expected type is \(CommandType.self)")
            #endif
            return
        }
        interact(guaranteedCommand: commandData)
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

public extension BoardCommand {
    func withIdentifier(_ identifier: BoardID) -> BoardCommand {
        BoardCommand(identifier: identifier, input: input)
    }
}

public extension BoardCommand {
    static func target<Input>(_ id: BoardID, _ input: Input) -> BoardCommand<Input> {
        BoardCommand<Input>(identifier: id, input: input)
    }
}

public extension BoardCommand where Input == Void {
    init(identifier: BoardID) {
        self.init(identifier: identifier, input: ())
    }

    static func target(_ id: BoardID) -> BoardCommand<Input> {
        BoardCommand<Input>(identifier: id)
    }
}

public extension BoardCommand where Input: ExpressibleByNilLiteral {
    init(identifier: BoardID) {
        self.init(identifier: identifier, input: nil)
    }

    static func target(_ id: BoardID) -> BoardCommand<Input> {
        BoardCommand<Input>(identifier: id)
    }
}
