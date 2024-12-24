//
//  LauncherPlugin.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 23/12/24.
//

import Foundation

public protocol LauncherPlugin {
    func prepareForLaunching(withOptions options: MainOptions) -> ModuleComponent
}

public struct ModuleComponent {
    public init(modulePlugins: [ModulePlugin],
                urlOpenerPlugins: [URLOpenerPlugin] = [],
                launchSettings: @escaping (_ mainboard: FlowMotherboard) -> Void = { _ in }) {
        self.modulePlugins = modulePlugins
        self.urlOpenerPlugins = urlOpenerPlugins
        self.launchSettings = launchSettings
    }

    public let modulePlugins: [ModulePlugin]
    public let urlOpenerPlugins: [URLOpenerPlugin]
    public let launchSettings: (_ mainboard: FlowMotherboard) -> Void
}
