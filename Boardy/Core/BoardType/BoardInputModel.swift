//
//  BoardInputModel.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 12/14/20.
//

import Foundation

public protocol BoardInputModel {
    var identifier: BoardID { get }
    var option: Any? { get }
}

public struct BoardInput<Input>: BoardInputModel {
    public let identifier: BoardID
    public let input: Input

    public var option: Any? { input }

    public init(target: BoardID, input: Input) {
        identifier = target
        self.input = input
    }
}

public extension BoardInput {
    static func target<InputValue>(_ id: BoardID, _ input: InputValue) -> BoardInput<InputValue> {
        BoardInput<InputValue>(target: id, input: input)
    }
}

public extension BoardInput where Input == Void {
    init(target: BoardID) {
        identifier = target
        input = ()
    }

    static func target(_ id: BoardID) -> BoardInput<Void> {
        BoardInput<Void>(target: id)
    }
}

public extension BoardInput where Input: ExpressibleByNilLiteral {
    init(target: BoardID) {
        identifier = target
        input = nil
    }

    static func target(_ id: BoardID) -> BoardInput<Input> {
        BoardInput<Input>(target: id)
    }
}

public extension BoardID {
    func with<Input>(input: Input) -> BoardInput<Input> {
        BoardInput<Input>(target: self, input: input)
    }

    var withoutInput: BoardInput<Void> {
        BoardInput<Void>(target: self)
    }
}
