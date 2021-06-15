//
//  BoardRegistrationBuilder.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 6/13/21.
//

import Foundation

#if swift(>=5.4)

@resultBuilder
public struct BoardRegistrationBuilder {
    // For loop
    public static func buildArray(_ components: [BoardRegistrationsConvertible]) -> [BoardRegistration] {
        components.flatMap { $0.asBoardRegistrations() }
    }

    public static func buildBlock(_ components: BoardRegistrationsConvertible...) -> [BoardRegistration] {
        components.flatMap { $0.asBoardRegistrations() }
    }

    public static func buildEither(first component: BoardRegistrationsConvertible) -> BoardRegistrationsConvertible {
        component
    }

    public static func buildEither(second component: BoardRegistrationsConvertible) -> BoardRegistrationsConvertible {
        component
    }

    public static func buildIf(_ value: BoardRegistrationsConvertible?) -> BoardRegistrationsConvertible {
        value ?? []
    }

    public static func buildOptional(_ component: BoardRegistrationsConvertible?) -> BoardRegistrationsConvertible {
        component ?? []
    }

    public static func buildExpression(_ component: BoardRegistrationsConvertible?) -> BoardRegistrationsConvertible {
        component ?? []
    }
}

extension Motherboard {
    public convenience init(identifier: BoardID = .random(),
                            externalProducer: ActivableBoardProducer = NoBoardProducer(),
                            @BoardRegistrationBuilder registrationsBuilder: (_ producer: ActivableBoardProducer) -> [BoardRegistration]) {
        let producer = createProducer(from: externalProducer, registrationsBuilder: registrationsBuilder)
        self.init(identifier: identifier, boardProducer: producer)
    }
}

extension Board {
    public func produceContinuousMotherboard(identifier: BoardID = .random(),
                                             externalProducer: ActivableBoardProducer = NoBoardProducer(),
                                             @BoardRegistrationBuilder registrationsBuilder: (_ producer: ActivableBoardProducer) -> [BoardRegistration]) -> Motherboard {
        let producer = createProducer(from: externalProducer, registrationsBuilder: registrationsBuilder)
        return produceContinuousMotherboard(identifier: identifier, boardProducer: producer, elementBoards: [])
    }
}

extension BoardProducer {
    public convenience init(externalProducer: ActivableBoardProducer = NoBoardProducer(), @BoardRegistrationBuilder registrationsBuilder: (_ producer: ActivableBoardProducer) -> [BoardRegistration]) {
        self.init(externalProducer: externalProducer, registrations: [])
        let registrations = registrationsBuilder(BoardProducerBox(producer: self))
        for registration in registrations {
            add(registration: registration)
        }
    }
}

internal func createProducer(from externalProducer: ActivableBoardProducer, @BoardRegistrationBuilder registrationsBuilder: (_ producer: ActivableBoardProducer) -> [BoardRegistration]) -> ActivableBoardProducer {
    let producer = BoardProducer(externalProducer: externalProducer, registrations: [])
    let registrations = registrationsBuilder(BoardProducerBox(producer: producer))
    for registration in registrations {
        producer.add(registration: registration)
    }
    return producer
}

#endif
