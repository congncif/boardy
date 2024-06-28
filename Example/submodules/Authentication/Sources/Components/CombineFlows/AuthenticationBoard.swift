//
//  RootBoard.swift
//  Authentication
//
//  Created by BOARDY on 10/22/21.
//
//

import Authentication
import Boardy
import Foundation

enum AuthenticationBoardFactory {
    static func make(identifier: BoardID, producer: ActivatableBoardProducer) -> ActivatableBoard {
        FlowBoard<AuthenticationInput, AuthenticationOutput, AuthenticationCommand, AuthenticationAction>(identifier: identifier, producer: producer) { _ in
            // <#register flows#>
        } flowActivation: { _, _ in
            // <#activate#>
        }
    }
}
