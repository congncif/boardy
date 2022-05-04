//
//  URLOpenerPlugin.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/9/22.
//

import Foundation

public protocol URLOpenerPlugin: URLOpenerPluginConvertible {
    var name: String { get }
    var identifier: String { get }

    func canOpenURL(_ url: URL) -> Bool

    func mainboard(_ mainboard: FlowMotherboard, open url: URL)
}

public extension URLOpenerPlugin {
    var name: String { String(describing: self) }

    var identifier: String { String(describing: type(of: self)) }
}

public protocol URLOpenerPluginConvertible {
    var urlOpenerPlugins: [URLOpenerPlugin] { get }
}

public extension URLOpenerPlugin {
    var urlOpenerPlugins: [URLOpenerPlugin] { [self] }
}

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
