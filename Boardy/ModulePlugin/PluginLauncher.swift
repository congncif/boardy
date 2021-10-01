//
//  Daddy.swift
//  DadSDK
//
//  Created by FOLY on 5/22/21.
//

import Foundation

public final class LauncherComponent {
    public let options: MainOptions

    private var container = BoardProducer()

    private var plugins: [ModulePlugin] = []

    init(options: MainOptions) {
        self.options = options
    }

    func append(plugin: ModulePlugin) -> Bool {
        if !plugins.contains(where: { $0.identifier == plugin.identifier }) {
            plugins.append(plugin)
            return true
        } else {
            #if DEBUG
            print("⚠️ Duplicated plugin \(plugin.identifier)")
            #endif
        }
        return false
    }

    public func install(plugins: [ModulePlugin]) -> Self {
        for plugin in plugins {
            _ = append(plugin: plugin)
        }
        return self
    }

    public func install(plugin: ModulePlugin) -> Self {
        _ = append(plugin: plugin)
        return self
    }

    func loadPluginsIfNeeded() {
        plugins.forEach { $0.apply(for: self) }
        plugins.removeAll()
    }

    func generateMainboard() -> Motherboard {
        loadPluginsIfNeeded()
        return Motherboard(boardProducer: container)
    }

    /// Create & return new instance of Launcher
    public func instantiate() -> PluginLauncher {
        PluginLauncher(mainboard: generateMainboard())
    }

    /// Create shared instance of Launcher
    public func initialize() {
        PluginLauncher.sharedInstance = instantiate()
    }
}

extension LauncherComponent: MainComponent {
    public var producer: BoardDynamicProducer { container.boxed }
}

public final class PluginLauncher {
    static var sharedInstance: PluginLauncher?

    private let mainboard: Motherboard

    fileprivate init(mainboard: Motherboard) {
        self.mainboard = mainboard
    }

    public static var shared: PluginLauncher {
        guard let instance = sharedInstance else {
            preconditionFailure("PluginLauncher must be initialized before using")
        }
        return instance
    }

    public static func with(options: MainOptions) -> LauncherComponent {
        LauncherComponent(options: options)
    }

    public func launch<Input>(on rootObject: AnyObject, input: BoardInput<Input>) {
        launch(on: rootObject) { mainboard in
            mainboard.activateBoard(input)
        }
    }

    public func launch(on rootObject: AnyObject, action: (_ mainboard: FlowMotherboard) -> Void) {
        #if DEBUG
        if mainboard.context != nil, mainboard.context !== rootObject {
            print("⚠️ Motherboard \(mainboard) will change root from \(mainboard.context) to \(rootObject)")
        }
        #endif

        mainboard.putIntoContext(rootObject)
        action(mainboard)
    }

    public func activateNow(_ action: (_ mainboard: FlowMotherboard) -> Void) {
        guard mainboard.context != nil else {
            assertionFailure("🚧 Motherboard \(mainboard) was not installed. PluginLauncher must be launched before activating modules.")
            return
        }
        action(mainboard)
    }
}
