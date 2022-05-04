//
//  MotherboardType+Interface.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/22/20.
//

import Foundation

public extension MotherboardType {
    /// Activate all of installed boards in Motherboard at once. This is useful for preparing to plug them in Interface.
    func activateAllBoards(withOptions options: [BoardID: Any] = [:], defaultOption: Any? = nil) {
        for board in boards {
            let option = options[board.identifier] ?? defaultOption
            activateBoard(identifier: board.identifier, withOption: option)
        }
    }

    /// Activate all of installed boards in Motherboard at once. The boards is not in models parameter will be activated with option defaultOption.
    func activateAllBoards(models: [BoardInputModel], defaultOption: Any? = nil) {
        let options: [BoardID: Any] = models.reduce([:]) { result, model in
            result.merging([model.identifier: model.option as Any]) { $1 }
        }
        activateAllBoards(withOptions: options, defaultOption: defaultOption)
    }

    /// Activate all of installed boards in Motherboard at once when they have same input type. If the input of a board is unavailable, the board will be activated with default input.
    func activateAllBoards<Input>(withInputs inputs: [BoardInput<Input>] = [], defaultInput: Input) {
        for board in boards {
            guard let input = inputs.first(where: { $0.identifier == board.identifier }) else {
                let input = BoardInput<Input>(target: board.identifier, input: defaultInput)
                activateBoard(input)
                return
            }
            activateBoard(input)
        }
    }

    /// Activate all of installed boards in Motherboard at once when they have same input type without default value. If the input of a board is unavailable, the board will be activated with nil option.
    func activateAllBoards<Input>(withInputs inputs: [BoardInput<Input>]) {
        for board in boards {
            guard let input = inputs.first(where: { $0.identifier == board.identifier }) else {
                activateBoard(identifier: board.identifier)
                return
            }
            activateBoard(input)
        }
    }
}
