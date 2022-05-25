//
//  URLOpenerPlugin.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/9/22.
//

import Foundation

public protocol URLOpenerPlugin: URLOpenerPluginConvertible {
    var name: String { get }
//    var identifier: String { get }

    func canOpenURL(_ url: URL) -> Bool

    func mainboard(_ mainboard: FlowMotherboard, open url: URL)
}

public extension URLOpenerPlugin {
    var name: String { String(describing: self) }

//    var identifier: String { String(describing: self) }
}

public protocol URLOpenerPluginConvertible {
    var urlOpenerPlugins: [URLOpenerPlugin] { get }
}

public extension URLOpenerPlugin {
    var urlOpenerPlugins: [URLOpenerPlugin] { [self] }
}

// MARK: - Path parameters matching

public protocol URLOpenerPathMatchingPlugin: URLOpenerPlugin {
    var matchingPath: String { get }

    func mainboard(_ mainboard: FlowMotherboard, openURLWithParameters parameters: [String: String])
}

enum URLOpeningRawOption {
    case yes(parameters: [String: String])
    case no
}

public extension URLOpenerPathMatchingPlugin {
    func canOpenURL(_ url: URL) -> Bool {
        switch openingOption(forURL: url) {
        case .yes:
            return true
        case .no:
            return false
        }
    }

    func mainboard(_ mainboard: FlowMotherboard, open url: URL) {
        switch openingOption(forURL: url) {
        case let .yes(parameters: parameters):
            self.mainboard(mainboard, openURLWithParameters: parameters)
        case .no:
            break
        }
    }

    internal func openingOption(forURL url: URL) -> URLOpeningRawOption {
        let matchingComponents = matchingPath.components(separatedBy: "/").filter { !$0.isEmpty }
        let urlPathComponents = url.boardy.pathComponents

        guard matchingComponents.count == urlPathComponents.count else {
            return .no
        }

        var pathParameters: [String: String] = [:]

        for (index, component) in matchingComponents.enumerated() {
            let value = urlPathComponents[index]
            if component.hasPrefix("{"), component.hasSuffix("}") {
                let key = String(component.dropFirst().dropLast())
                pathParameters[key] = value
            } else {
                guard component == value else {
                    return .no
                }
            }
        }

        let parameters = url.boardy.queryParameters
            .merging(pathParameters, uniquingKeysWith: { $1 })

        return .yes(parameters: parameters)
    }
}

public struct BlockURLOpenerPathMatchingPlugin: URLOpenerPathMatchingPlugin {
    public init(name: String? = nil, matchingPath: String, handler: @escaping (FlowMotherboard, [String: String]) -> Void) {
        self.matchingPath = matchingPath
        self.handler = handler
        customName = name
    }

    public let matchingPath: String

    private let customName: String?

    public var name: String {
        customName ?? String(describing: self)
    }

    let handler: (FlowMotherboard, [String: String]) -> Void

    public func mainboard(_ mainboard: FlowMotherboard, openURLWithParameters parameters: [String: String]) {
        handler(mainboard, parameters)
    }
}

// MARK: - Coding Parameters

public enum URLOpeningOption<Parameter> {
    case yes(Parameter)
    case no
}

public protocol GuaranteedURLOpenerPlugin: URLOpenerPlugin {
    associatedtype Parameter

    func willOpen(url: URL) -> URLOpeningOption<Parameter>

    func mainboard(_ mainboard: FlowMotherboard, openWith parameter: Parameter)
}

public extension GuaranteedURLOpenerPlugin {
    func canOpenURL(_ url: URL) -> Bool {
        switch willOpen(url: url) {
        case .no:
            return false
        case .yes:
            return true
        }
    }

    func mainboard(_ mainboard: FlowMotherboard, open url: URL) {
        if case let .yes(parameter) = willOpen(url: url) {
            self.mainboard(mainboard, openWith: parameter)
        }
    }
}

public struct BlockURLOpenerPlugin<Parameter>: GuaranteedURLOpenerPlugin {
    private let condition: (URL) -> URLOpeningOption<Parameter>
    private let handler: (FlowMotherboard, Parameter) -> Void
    private let customName: String?

    public var name: String {
        customName ?? String(describing: self)
    }

    public init(name: String? = nil, condition: @escaping (URL) -> URLOpeningOption<Parameter>, handler: @escaping (FlowMotherboard, Parameter) -> Void) {
        customName = name
        self.condition = condition
        self.handler = handler
    }

    public func willOpen(url: URL) -> URLOpeningOption<Parameter> {
        condition(url)
    }

    public func mainboard(_ mainboard: FlowMotherboard, openWith parameter: Parameter) {
        handler(mainboard, parameter)
    }
}
