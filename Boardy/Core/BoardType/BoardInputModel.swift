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
}
