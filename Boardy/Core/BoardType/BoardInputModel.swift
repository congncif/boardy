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

extension BoardInput where Input == Void {
    public init(target: BoardID) {
        identifier = target
        input = ()
    }

    public static func target(_ id: BoardID) -> BoardInput<Void> {
        BoardInput<Void>(target: id)
    }

    public static func target<Input>(_ id: BoardID, _ input: Input) -> BoardInput<Input> {
        BoardInput<Input>(target: id, input: input)
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
