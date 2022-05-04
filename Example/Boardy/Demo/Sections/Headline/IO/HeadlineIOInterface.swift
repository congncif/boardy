//
//  HeadlineIOInterface.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 5/10/21.
//  Copyright © 2021 [iF] Solution. All rights reserved.
//

import Boardy
import Foundation

public protocol HeadlineActivatable {
    func activate()
    func refresh(label: String)
}

// MARK: - Activations

/// For Motherboard call
struct HeadlineMainActivation {
    let identifier: BoardID
    let mainboard: FlowMotherboard
}

extension HeadlineMainActivation: HeadlineActivatable {
    func activate() {
        mainboard.activateBoard(BoardInput(target: identifier))
    }

    func refresh(label: String) {
        mainboard.interactWithBoard(BoardCommand(identifier: identifier, input: label))
    }
}

/// For other Board call
struct HeadlineActivation {
    let identifier: BoardID
    let source: ActivatableBoard
}

extension HeadlineActivation: HeadlineActivatable {
    func activate() {
        source.nextToBoard(BoardInput(target: identifier))
    }

    func refresh(label: String) {
        source.interactWithOtherBoard(BoardCommand(identifier: identifier, input: label))
    }
}

// MARK: - Factory

public extension ActivatableBoard {
    func headline(identifier: BoardID) -> HeadlineActivatable {
        switch self {
        case let main as FlowMotherboard:
            return HeadlineMainActivation(identifier: identifier, mainboard: main)
        default:
            return HeadlineActivation(identifier: identifier, source: self)
        }
    }
}
