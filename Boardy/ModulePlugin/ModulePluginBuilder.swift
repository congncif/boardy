//
//  ModulePluginBuilder.swift
//  DadSDK
//
//  Created by NGUYEN CHI CONG on 6/15/21.
//

import Foundation

#if swift(>=5.4)

    extension Array: ModulePluginConvertible where Element == ModulePlugin {
        public var modulePlugins: [ModulePlugin] {
            self
        }
    }

    @resultBuilder
    public enum ModulePluginBuilder {
        public static func buildBlock(_ components: ModulePluginConvertible...) -> [ModulePlugin] {
            components.flatMap { $0.modulePlugins }
        }

        public static func buildArray(_ components: [ModulePluginConvertible]) -> [ModulePlugin] {
            components.flatMap { $0.modulePlugins }
        }

        public static func buildEither(first component: ModulePluginConvertible) -> ModulePluginConvertible {
            component.modulePlugins
        }

        public static func buildEither(second component: ModulePluginConvertible) -> ModulePluginConvertible {
            component.modulePlugins
        }

        public static func buildOptional(_ component: ModulePluginConvertible?) -> ModulePluginConvertible {
            component ?? []
        }

        public static func buildExpression(_ expression: ModulePluginConvertible?) -> ModulePluginConvertible {
            expression ?? []
        }
    }

    public extension LauncherComponent {
        func install(@ModulePluginBuilder pluginsBuilder: () -> [ModulePlugin]) -> Self {
            install(plugins: pluginsBuilder())
        }
    }

#endif
