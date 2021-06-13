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
                            @BoardRegistrationBuilder registrationsBuilder: (_ externalProducer: ActivableBoardProducer) -> [BoardRegistration]) {
        let registrations = registrationsBuilder(externalProducer)
        self.init(identifier: identifier, boardProducer: BoardProducer(registrations: registrations))
    }
}

extension Board {
    public func produceContinuousMotherboard(identifier: BoardID = .random(),
                                             externalProducer: ActivableBoardProducer = NoBoardProducer(),
                                             @BoardRegistrationBuilder registrationsBuilder: (_ externalProducer: ActivableBoardProducer) -> [BoardRegistration]) -> Motherboard {
        let registrations = registrationsBuilder(externalProducer)
        return produceContinuousMotherboard(identifier: identifier, boardProducer: BoardProducer(registrations: registrations), elementBoards: [])
    }

    
}

#endif
