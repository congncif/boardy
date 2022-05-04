//
//  Daddy.swift
//  DadSDK
//
//  Created by FOLY on 5/22/21.
//

import Foundation

public final class LauncherComponent {
    public let options: MainOptions
    public var encodedData: Data?

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

    public func share(encodedData: Data?) -> Self {
        self.encodedData = encodedData
        return self
    }

    public func share<Model>(jsonValue: Model) -> Self where Model: Encodable {
        let data = try? JSONEncoder().encode(jsonValue)
        return share(encodedData: data)
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
        plugins.forEach { $0.apply(for: Component(options: options, producer: container.boxed, encodedData: encodedData)) }
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
    @discardableResult
    public func initialize(_ settings: (_ mainboard: FlowMotherboard) -> Void = { _ in }) -> PluginLauncher {
        let instance = instantiate(settings)
        PluginLauncher.sharedInstance = instance
        return instance
    }
}

struct Component: MainComponent {
    let options: MainOptions
    let producer: BoardDynamicProducer
    let encodedData: Data?
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

    // MARK: URL opener

    private lazy var urlOpenerPlugins: [URLOpenerPlugin] = []
    private var urlNotFoundHandler: ((URL) -> Void)?

    public typealias URLOpenerSelectionHandler = (_ mainboard: FlowMotherboard, _ url: URL, _ candidatePlugins: [URLOpenerPlugin], (_ selectedPlugins: [URLOpenerPlugin]) -> Void) -> Void

    private var urlOpenerSelectionHandler: URLOpenerSelectionHandler = { $3($2) }

    @discardableResult
    public func install(urlOpenerPlugin: URLOpenerPlugin) -> Self {
        urlOpenerPlugins.append(urlOpenerPlugin)
        return self
    }

    @discardableResult
    public func install(urlOpenerPlugins: [URLOpenerPlugin]) -> Self {
        self.urlOpenerPlugins.append(contentsOf: urlOpenerPlugins)
        return self
    }

    @discardableResult
    public func installURLOpenerPlugin<Parameter>(
        name: String? = nil,
        condition: @escaping (URL) -> URLOpeningOption<Parameter>,
        handler: @escaping (FlowMotherboard, Parameter) -> Void) -> Self {
        let plugin = BlockURLOpenerPlugin(name: name, condition: condition, handler: handler)
        return install(urlOpenerPlugin: plugin)
    }

    @discardableResult
    public func installURLOpenerPlugin(
        name: String? = nil,
        condition: @escaping (URL) -> Bool,
        handler: @escaping (FlowMotherboard) -> Void) -> Self {
        let plugin = BlockURLOpenerPlugin<Void>(name: name, condition: { url in
            if condition(url) {
                return .yes(())
            } else {
                return .no
            }
        }, handler: { mainboard, _ in
            handler(mainboard)
        })
        return install(urlOpenerPlugin: plugin)
    }

    @discardableResult
    public func setURLNotFoundHandler(_ handler: ((URL) -> Void)?) -> Self {
        urlNotFoundHandler = handler
        return self
    }

    @discardableResult
    public func setURLOpenerSelectionHandler(_ handler: @escaping URLOpenerSelectionHandler) -> Self {
        urlOpenerSelectionHandler = handler
        return self
    }

    /// Open an URL using URLOpenerPlugin
    /// - Parameter url: The input URL which might be a deep link, universal link or any income URL to the app
    /// - Returns: A array of strings name of matched plugins that handled the URL
    @discardableResult
    public func open(url: URL) -> [String] {
        let handlers = urlOpenerPlugins.filter { plugin in
            plugin.canOpenURL(url)
        }

        let numberOfHandlers = handlers.count

        switch numberOfHandlers {
        case 0:
            urlNotFoundHandler?(url)
            #if DEBUG
            print("⚠️ [\(String(describing: self))] URL has not opened because there are no plugins that handle the URL ➤ \(url)")
            #endif
        case _ where numberOfHandlers > 1:
            urlOpenerSelectionHandler(mainboard, url, handlers) { [mainboard] selectedPlugins in
                for plugin in selectedPlugins {
                    plugin.mainboard(mainboard, open: url)
                }

                #if DEBUG
                switch selectedPlugins.count {
                case 0:
                    print("⚠️ [\(String(describing: self))] URL cancelled ➤ \(url)")
                case let count where count > 1:
                    print("🌕 [\(String(describing: self))] URL opened multiple times with the warning there is more than one plugin: \(handlers.map { $0.name }) that handles the URL ➤ \(url)")
                default:
                    print("🌏 [\(String(describing: self))] URL opened ➤ \(url)")
                }
                #endif
            }
        default:
            handlers[0].mainboard(mainboard, open: url)
            #if DEBUG
            print("🌏 [\(String(describing: self))] URL opened ➤ \(url)")
            #endif
        }

        return handlers.map { $0.name }
    }

    /// Open a link using URLOpenerPlugin
    /// - Parameter link: Might be a deep link, universal link or any income URL to the app
    /// - Returns: A array of strings name of matched plugins that handled the link
    @discardableResult
    public func open(link: String) -> [String] {
        if let url = URL(string: link) {
            return open(url: url)
        } else {
            print("⚠️ Cannot open an invalid URL ➤ \(link)")
            return []
        }
    }
}
