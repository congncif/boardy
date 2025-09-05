//
//  IOInterface+ComponentKit.swift
//  Boardy
//
//  Created by CONGNC7 on 18/05/2022.
//

import Foundation

public struct BlockTaskBoardActivation<In, Out>: BoardActivating {
    public typealias Input = BlockTaskParameter<In, Out>

    let destinationID: BoardID
    let source: ActivatableBoard

    public func activate(with input: BlockTaskParameter<In, Out>) {
        source.nextToBoard(.target(destinationID, input))
    }

    public func activate(with input: In) {
        source.nextToBoard(.target(destinationID, input))
    }
}

public struct BlockTaskMainboardActivation<In, Out>: BoardActivating {
    public typealias Input = BlockTaskParameter<In, Out>

    let destinationID: BoardID
    let mainboard: MotherboardType

    /// Activate a board from its Motherboard
    public func activate(with input: Input) {
        mainboard.activateBoard(.target(destinationID, input))
    }

    public func activate(with input: In) {
        mainboard.activateBoard(.target(destinationID, input))
    }
}

public extension ActivatableBoard {
    func blockActivation<Input, Output>(_ destinationID: BoardID, with _: BlockTaskParameter<Input, Output>.Type) -> BlockTaskBoardActivation<Input, Output> {
        BlockTaskBoardActivation(destinationID: destinationID, source: self)
    }
}

public extension MotherboardType {
    func blockActivation<Input, Output>(_ destinationID: BoardID, with _: BlockTaskParameter<Input, Output>.Type) -> BlockTaskMainboardActivation<Input, Output> {
        BlockTaskMainboardActivation(destinationID: destinationID, mainboard: self)
    }
}

public extension MainboardGenericDestination {
    var blockActivation: BlockTaskMainboardActivation<Input, Output> {
        mainboard.blockActivation(destinationID, with: BlockTaskParameter<Input, Output>.self)
    }
}
