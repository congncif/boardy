//
//  CurrentUserBoard.swift
//  AuthenticationPlugins
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import Boardy
import Foundation

enum CurrentUserBoardFactory {
    static func make(identifier: BoardID, executingType: ExecutingType = .concurrent) -> ActivatableBoard {
        BlockTaskBoard<CurrentUserInput, CurrentUserOutput>(identifier: identifier, executingType: executingType, executor: { _, _, completion in
            completion(.success(AuthStorage.currentUser))
            return .none
        })
    }
}
