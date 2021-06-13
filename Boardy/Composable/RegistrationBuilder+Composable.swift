//
//  RegistrationBuilder+Composable.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 6/13/21.
//

import Foundation

#if swift(>=5.4)

extension Board {
    public func produceComposableMotherboard(identifier: BoardID = .random(),
                                             externalProducer: ActivableBoardProducer = NoBoardProducer(),
                                             @BoardRegistrationBuilder registrationsBuilder: (_ externalProducer: ActivableBoardProducer) -> [BoardRegistration]) -> ComposableMotherboard {
        let registrations = registrationsBuilder(externalProducer)
        return produceComposableMotherboard(identifier: identifier, boardProducer: BoardProducer(registrations: registrations), elementBoards: [])
    }
}

#endif
