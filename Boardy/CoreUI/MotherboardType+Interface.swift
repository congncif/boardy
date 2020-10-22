//
//  MotherboardType+Interface.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/22/20.
//

import Foundation

extension MotherboardType {
    /// Activate all of boards in Motherboard at once. This is useful for preparing to plug them in Interface.
    public func activateAllBoards(withOptions options: [BoardID: Any] = [:], defaultOption: Any? = nil) {
        for board in boards {
            let option = options[board.identifier] ?? defaultOption
            board.activate(withOption: option)
        }
    }

    /// Activate all of boards in Motherboard at once. The boards is not in models parameter will be activated with option defaultOption.
    public func activateAllBoards(models: [BoardInputModel], defaultOption: Any? = nil) {
        let options: [BoardID: Any] = models.reduce([:]) { result, model in
            result.merging([model.identifier: model.option as Any]) { $1 }
        }
        activateAllBoards(withOptions: options, defaultOption: defaultOption)
    }
}
