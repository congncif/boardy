//
//  URLOpenerPluginBuilder.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/9/22.
//

import Foundation

#if swift(>=5.4)

    extension Array: URLOpenerPluginConvertible where Element == URLOpenerPlugin {
        public var urlOpenerPlugins: [URLOpenerPlugin] {
            self
        }
    }

    @resultBuilder
    public enum URLOpenerPluginBuilder {
        public static func buildBlock(_ components: URLOpenerPluginConvertible...) -> [URLOpenerPlugin] {
            components.flatMap { $0.urlOpenerPlugins }
        }

        public static func buildArray(_ components: [URLOpenerPluginConvertible]) -> [URLOpenerPlugin] {
            components.flatMap { $0.urlOpenerPlugins }
        }

        public static func buildEither(first component: URLOpenerPluginConvertible) -> URLOpenerPluginConvertible {
            component.urlOpenerPlugins
        }

        public static func buildEither(second component: URLOpenerPluginConvertible) -> URLOpenerPluginConvertible {
            component.urlOpenerPlugins
        }

        public static func buildOptional(_ component: URLOpenerPluginConvertible?) -> URLOpenerPluginConvertible {
            component ?? []
        }

        public static func buildExpression(_ expression: URLOpenerPluginConvertible?) -> URLOpenerPluginConvertible {
            expression ?? []
        }
    }

    public extension PluginLauncher {
        func install(@URLOpenerPluginBuilder urlOpenerPluginsBuilder: () -> [URLOpenerPlugin]) -> Self {
            install(urlOpenerPlugins: urlOpenerPluginsBuilder())
        }
    }

#endif
