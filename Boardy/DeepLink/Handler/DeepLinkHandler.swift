//
//  DeepLinkHandler.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/1/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Foundation
import UIKit

public protocol DeepLinkHandling {
    func start(with hostingObject: AnyObject)
    func handleDeepLink(_ deepLink: String)
}

public protocol DeepLinkParsing {
    func destinationForDeepLink(_ deepLink: String) -> BoardInputModel?
}

public struct DeepLinkParser: DeepLinkParsing {
    private let handler: (String) -> BoardInputModel?

    public init(handler: @escaping (String) -> BoardInputModel?) {
        self.handler = handler
    }

    public func destinationForDeepLink(_ deepLink: String) -> BoardInputModel? {
        handler(deepLink)
    }
}

public protocol DeepLinkHandlerClubbing {
    var identifier: String { get }
    var workflowMainboards: [FlowMotherboard] { get }
    var parser: DeepLinkParsing { get }
}

public protocol DeepLinkHandlerRegistering {
    func registerHandlerClub(_ handlerClub: DeepLinkHandlerClubbing)
    func unregisterHandlerClub(withIdentifier identifier: String)

    func registredHandlerClub(withIdentifier identifier: String) -> DeepLinkHandlerClubbing?
}

extension DeepLinkHandlerRegistering {
    public func registerHandlerClubIfNeeded(_ handlerClub: DeepLinkHandlerClubbing) {
        if registredHandlerClub(withIdentifier: handlerClub.identifier) == nil {
            registerHandlerClub(handlerClub)
        }
    }
}

public typealias DeepLinkHandlingComposable = DeepLinkHandling & DeepLinkHandlerRegistering

public final class DeepLinkHandler: DeepLinkHandlingComposable {
    public init() {}

    public init(handlerClubbing: DeepLinkHandlerClubbing) {
        clubsRoom[handlerClubbing.identifier] = handlerClubbing
    }

    public init<Club: DeepLinkHandlerClubbing>(handlerClub: Club) {
        clubsRoom[handlerClub.identifier] = handlerClub
    }

    public func start(with hostingObject: AnyObject) {
        self.hostingObject = hostingObject
    }

    public func handleDeepLink(_ deepLink: String) {
        let destinations = parsers.compactMap { parser -> BoardInputModel? in
            parser.destinationForDeepLink(deepLink)
        }

        assert(destinations.count < 2, "⛈ [\(String(describing: self))] Multiple destinations \(destinations) for deep link \(deepLink). Please select one.")

        guard let destination = destinations.first else { return }

        let validBoards = mainboards.compactMap { mainboard -> ActivatableBoard? in
            mainboard.getBoard(identifier: destination.identifier)
        }

        assert(!validBoards.isEmpty, "⛈ [\(String(describing: self))] No valid boards for deep link \(deepLink). Please add board with identifier \(destination.identifier) to motherboard of deep link.")

        assert(validBoards.count < 2, "⛈ [\(String(describing: self))] Multiple valid boards \(validBoards) for deep link \(deepLink). Please select one.")

        guard let board = validBoards.first else { return }
        board.activate(withOption: destination.option)
    }

    public func registerHandlerClub(_ handlerClub: DeepLinkHandlerClubbing) {
        if let currentClub = registredHandlerClub(withIdentifier: handlerClub.identifier) {
            assertionFailure("⛈ [\(String(describing: self))] The club \(currentClub) was already registered. Please remove it before.")
        }
        clubsRoom[handlerClub.identifier] = handlerClub
    }

    public func unregisterHandlerClub(withIdentifier identifier: String) {
        if registredHandlerClub(withIdentifier: identifier) != nil {
            clubsRoom.removeValue(forKey: identifier)
        } else {
            assertionFailure("⛈ [\(String(describing: self))] The club with identifier \(identifier) was not registered.")
        }
    }

    public func registredHandlerClub(withIdentifier identifier: String) -> DeepLinkHandlerClubbing? {
        clubsRoom[identifier]
    }

    private weak var hostingObject: AnyObject? {
        didSet { forwardHosting() }
    }

    private var clubsRoom: [String: DeepLinkHandlerClubbing] = [:] {
        didSet { forwardHosting() }
    }

    private func forwardHosting() {
        if let rootObject = hostingObject {
            mainboards.forEach { $0.installIntoRoot(rootObject) }
        }
    }

    private var parsers: [DeepLinkParsing] {
        clubsRoom.reduce([]) { (result, clubInfo) -> [DeepLinkParsing] in
            result + [clubInfo.value.parser]
        }
    }

    private var mainboards: [FlowMotherboard] {
        clubsRoom.reduce([]) { (result, clubInfo) -> [FlowMotherboard] in
            result + clubInfo.value.workflowMainboards
        }
    }

    private var clubs: [DeepLinkHandlerClubbing] {
        clubsRoom.compactMap { $0.value }
    }
}
