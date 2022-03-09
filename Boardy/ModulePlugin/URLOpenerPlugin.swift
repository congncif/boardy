//
//  URLOpenerPlugin.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/9/22.
//

import Foundation

public protocol URLOpenerPlugin {
    var name: String { get }

    func mainboard(_ mainboard: FlowMotherboard, open url: URL) -> Bool
}

public extension URLOpenerPlugin {
    var name: String { String(describing: self) }
}

public protocol URLOpenerPluginConvertible {
    var urlOpenerPlugins: [URLOpenerPlugin] { get }
}

public enum URLOpeningAbility<Parameter> {
    case canOpen(Parameter)
    case cannotOpen
}

public protocol GuaranteedURLOpenerPlugin: URLOpenerPlugin {
    associatedtype Parameter

    func willOpen(url: URL) -> URLOpeningAbility<Parameter>

    func mainboard(_ mainboard: FlowMotherboard, openWith parameter: Parameter)
}

public extension GuaranteedURLOpenerPlugin {
    func mainboard(_ mainboard: FlowMotherboard, open url: URL) -> Bool {
        switch willOpen(url: url) {
        case .cannotOpen:
            return false
        case let .canOpen(parameter):
            self.mainboard(mainboard, openWith: parameter)
            return true
        }
    }
}

public struct BlockURLOpenerPlugin<Parameter>: GuaranteedURLOpenerPlugin {
    let condition: (URL) -> URLOpeningAbility<Parameter>
    let handler: (FlowMotherboard, Parameter) -> Void

    public init(condition: @escaping (URL) -> URLOpeningAbility<Parameter>, handler: @escaping (FlowMotherboard, Parameter) -> Void) {
        self.condition = condition
        self.handler = handler
    }

    public func willOpen(url: URL) -> URLOpeningAbility<Parameter> {
        condition(url)
    }

    public func mainboard(_ mainboard: FlowMotherboard, openWith parameter: Parameter) {
        handler(mainboard, parameter)
    }
}
