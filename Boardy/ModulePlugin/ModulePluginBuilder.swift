//
//  ModulePluginBuilder.swift
//  DadSDK
//
//  Created by NGUYEN CHI CONG on 6/15/21.
//

import Foundation

#if swift(>=5.4)

extension Array: ModulePluginConvertible where Element == ModulePlugin {
    public var plugins: [ModulePlugin] {
        return self
    }
}

@resultBuilder
public struct ModulePluginBuilder {
    public static func buildBlock(_ components: ModulePluginConvertible...) -> [ModulePlugin] {
        components.flatMap { $0.plugins }
    }

    public static func buildArray(_ components: [ModulePluginConvertible]) -> [ModulePlugin] {
        components.flatMap { $0.plugins }
    }

    public static func buildEither(first component: ModulePluginConvertible) -> ModulePluginConvertible {
        component.plugins
    }

    public static func buildEither(second component: ModulePluginConvertible) -> ModulePluginConvertible {
        component.plugins
    }

    public static func buildOptional(_ component: ModulePluginConvertible?) -> ModulePluginConvertible {
        component ?? []
    }

    public static func buildExpression(_ expression: ModulePluginConvertible?) -> ModulePluginConvertible {
        expression ?? []
    }
}

extension LauncherComponent {
    public func install(@ModulePluginBuilder pluginsBuilder: () -> [ModulePlugin]) -> Self {
        self.install(plugins: pluginsBuilder())
    }
}

#endif
