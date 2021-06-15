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
                                             @BoardRegistrationBuilder registrationsBuilder: (_ producer: ActivableBoardProducer) -> [BoardRegistration]) -> ComposableMotherboard {
        let producer = createProducer(from: externalProducer, registrationsBuilder: registrationsBuilder)
        return produceComposableMotherboard(identifier: identifier, boardProducer: producer, elementBoards: [])
    }
}

#endif
