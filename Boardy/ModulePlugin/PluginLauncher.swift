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
        plugins.forEach { $0.apply(for: Component(options: options, producer: container.boxed)) }
        plugins.removeAll()
    }

    func generateMainboard(with settings: (_ mainboard: FlowMotherboard) -> Void) -> Motherboard {
        loadPluginsIfNeeded()
        let motherboard = Motherboard(boardProducer: container)
        settings(motherboard)
        return motherboard
    }

    /// Create & return new instance of Launcher
    public func instantiate(_ settings: (_ mainboard: FlowMotherboard) -> Void = { _ in }) -> PluginLauncher {
        PluginLauncher(mainboard: generateMainboard(with: settings))
    }

    /// Create shared instance of Launcher
    public func initialize(_ settings: (_ mainboard: FlowMotherboard) -> Void = { _ in }) {
        PluginLauncher.sharedInstance = instantiate(settings)
    }
}

struct Component: MainComponent {
    let options: MainOptions
    let producer: BoardDynamicProducer
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

    public func launch<Input>(in context: AnyObject, with input: BoardInput<Input>) {
        launch(in: context) { mainboard in
            mainboard.activateBoard(input)
        }
    }

    public func launch(in context: AnyObject, action: (_ mainboard: FlowMotherboard) -> Void) {
        #if DEBUG
        if mainboard.context != nil, mainboard.context !== context {
            print("⚠️ The Mainboard [\(mainboard.identifier)] will change the context from \(String(describing: mainboard.context)) to \(context).")
        }
        #endif

        mainboard.putIntoContext(context)
        action(mainboard)
    }

    public func activateNow(_ action: (_ mainboard: FlowMotherboard) -> Void) {
        #if DEBUG
        if mainboard.context == nil {
            print("⚠️ The Mainboard [\(mainboard.identifier)] has no contexts. The PluginLauncher should be launched before activating modules.")
        }
        #endif
        action(mainboard)
    }
}

// MARK: - Deprecated

public extension PluginLauncher {
    @available(*, deprecated, message: "This method was renamed. Use launch(in:input:) context instead.")
    func launch<Input>(on rootObject: AnyObject, input: BoardInput<Input>) {
        launch(in: rootObject, with: input)
    }

    @available(*, deprecated, message: "This method was renamed. Use launch(in:action:) context instead.")
    func launch(on rootObject: AnyObject, action: (_ mainboard: FlowMotherboard) -> Void) {
        launch(in: rootObject, action: action)
    }
}
