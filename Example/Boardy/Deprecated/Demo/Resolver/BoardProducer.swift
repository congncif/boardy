//
//  BoardProducer.swift
//  Boardy_Example
//
//  Created by FOLY on 11/25/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Boardy
import Foundation
import Resolver

struct BoardProducer: ActivatableBoardProducer {
    func produceBoard(identifier: BoardID) -> ActivatableBoard? {
        switch identifier {
        case .login:
            return LoginBoard()
        case .main:
            return MainBoard(homeBoard: HomeMainboard())
        default:
            return NoBoard(identifier: identifier)
        }
    }
}
