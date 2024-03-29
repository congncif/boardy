//
//  BoardRegistrationBuilder.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 6/13/21.
//

import Foundation

#if swift(>=5.4)

    @resultBuilder
    public enum BoardRegistrationBuilder {
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

    public extension Motherboard {
        convenience init(identifier: BoardID = .random(),
                         externalProducer: ActivatableBoardProducer = NoBoardProducer(),
                         @BoardRegistrationBuilder registrationsBuilder: (_ producer: ActivatableBoardProducer) -> [BoardRegistration]) {
            let producer = createProducer(from: externalProducer, registrationsBuilder: registrationsBuilder)
            self.init(identifier: identifier, boardProducer: producer)
        }
    }

    public extension BoardProducer {
        convenience init(externalProducer: ActivatableBoardProducer = NoBoardProducer(), @BoardRegistrationBuilder registrationsBuilder: (_ producer: ActivatableBoardProducer) -> [BoardRegistration]) {
            self.init(externalProducer: externalProducer, registrations: [])
            let registrations = registrationsBuilder(BoardDynamicProducerBox(producer: self))
            for registration in registrations {
                add(registration: registration)
            }
        }
    }

    internal func createProducer(from externalProducer: ActivatableBoardProducer, @BoardRegistrationBuilder registrationsBuilder: (_ producer: ActivatableBoardProducer) -> [BoardRegistration]) -> ActivatableBoardProducer {
        let producer = BoardProducer(externalProducer: externalProducer, registrations: [])
        let registrations = registrationsBuilder(producer.boxed)
        for registration in registrations {
            producer.add(registration: registration)
        }
        return producer
    }

#endif
