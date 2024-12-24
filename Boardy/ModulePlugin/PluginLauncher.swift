//
//  Daddy.swift
//  DadSDK
//
//  Created by FOLY on 5/22/21.
//

import Foundation

public final class LauncherComponent {
    public let options: MainOptions
    public var sharedEncodedData: Data?

    private var container = BoardProducer()

    private var plugins: [ModulePlugin] = []
    private var urlOpenerPlugins: [URLOpenerPlugin] = []
    private var customLaunchSettings: [(FlowMotherboard) -> Void] = []

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

    func share(encodedData: Data?) -> Self {
        sharedEncodedData = encodedData
        return self
    }

    public func share(value: some Encodable) -> Self {
        let data = try? JSONEncoder().encode(value)
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

    public func install(gatewayBarrier registration: GatewayBarrierRegistration) -> Self {
        let externalContainer = container.boxed
        container.registerGatewayBoard(.wildcard) { [externalContainer] identifier in
            GatewayBarrierProxy(identifier: identifier, boardProducer: externalContainer, registration: registration)
        }
        return self
    }

    public func install(urlOpenerPlugins: [URLOpenerPlugin]) -> Self {
        self.urlOpenerPlugins.append(contentsOf: urlOpenerPlugins)
        return self
    }

    public func install(launchSettings: @escaping (FlowMotherboard) -> Void) -> Self {
        customLaunchSettings.append(launchSettings)
        return self
    }

    @discardableResult
    public func install(launcherPlugin: LauncherPlugin) -> Self {
        let moduleComponent = launcherPlugin.prepareForLaunching(withOptions: options)

        return install(plugins: moduleComponent.modulePlugins)
            .install(urlOpenerPlugins: moduleComponent.urlOpenerPlugins)
            .install(launchSettings: moduleComponent.launchSettings)
    }

    func loadPluginsIfNeeded() {
        plugins.forEach { $0.apply(for: Component(options: options, producer: container.boxed, encodedData: sharedEncodedData)) }
        plugins.removeAll()
    }

    func generateMainboard(with settings: (_ mainboard: FlowMotherboard) -> Void) -> Motherboard {
        loadPluginsIfNeeded()
        let motherboard = Motherboard(boardProducer: container)

        settings(motherboard)

        for customLaunchSetting in customLaunchSettings {
            customLaunchSetting(motherboard)
        }

        return motherboard
    }

    /// Create & return new instance of Launcher
    public func instantiate(_ launchSettings: (_ mainboard: FlowMotherboard) -> Void = { _ in }) -> PluginLauncher {
        PluginLauncher(mainboard: generateMainboard(with: launchSettings))
            .install(urlOpenerPlugins: urlOpenerPlugins)
    }

    /// Create shared instance of Launcher
    @discardableResult
    public func initialize(_ launchSettings: (_ mainboard: FlowMotherboard) -> Void = { _ in }) -> PluginLauncher {
        let instance = instantiate(launchSettings)

        precondition(PluginLauncher.sharedInstance == nil, "🆘 [Boardy] PluginLauncher.shared is already initialized. ‼️ Re-initialize is not allowed. 👉 Please use instantiate(:) instead of.")

        PluginLauncher.sharedInstance = instance
        return instance
    }
}

struct Component: MainComponent {
    let options: MainOptions
    let producer: BoardDynamicProducer
    let encodedData: Data?

    func sharedValue<Value: Decodable>(_: Value.Type) -> Value? {
        guard let data = encodedData else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(Value.self, from: data)
    }
}

public final class PluginLauncher {
    static var sharedInstance: PluginLauncher?

    private let mainboard: Motherboard

    fileprivate init(mainboard: Motherboard) {
        self.mainboard = mainboard
    }

    public static var shared: PluginLauncher {
        guard let instance = sharedInstance else {
            preconditionFailure("🆘 [Boardy] PluginLauncher.shared must be initialized before use ‼️")
        }
        return instance
    }

    public static func with(options: MainOptions) -> LauncherComponent {
        LauncherComponent(options: options)
    }

    public func launch(in context: AnyObject, with input: BoardInput<some Any>) {
        launch(in: context) { mainboard in
            mainboard.activateBoard(input)
        }
    }

    public func launch(in context: AnyObject, action: (_ mainboard: FlowMotherboard) -> Void = { _ in }) {
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

    public typealias URLOpenerSelectionHandler = (_ mainboard: FlowMotherboard, _ url: URL, _ candidatePlugins: [URLOpenerPlugin], (_ selectedPlugins: [URLOpenerPlugin]) -> Void) -> Void
    public typealias URLNotFoundHandler = (_ mainboard: FlowMotherboard, _ url: URL) -> Void
    public typealias URLOpeningValidator = (_ url: URL) -> URLOpeningValidationStatus
    public typealias URLDeniedHandler = (_ mainboard: FlowMotherboard, _ url: URL) -> Void

    private lazy var urlOpenerPlugins: [URLOpenerPlugin] = []

    private var urlOpenerSelectionHandler: URLOpenerSelectionHandler = { $3($2) }
    private var urlNotFoundHandler: URLNotFoundHandler?

    private var urlOpeningValidator: URLOpeningValidator = { _ in .accepted }
    private lazy var urlDeniedHandler: URLDeniedHandler? = { [unowned self] in
        urlNotFoundHandler?($0, $1)
    }

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
        handler: @escaping (FlowMotherboard, Parameter) -> Void
    ) -> Self {
        let plugin = BlockURLOpenerPlugin(name: name, condition: condition, handler: handler)
        return install(urlOpenerPlugin: plugin)
    }

    @discardableResult
    public func installURLOpenerPlugin(
        name: String? = nil,
        condition: @escaping (URL) -> Bool,
        handler: @escaping (FlowMotherboard) -> Void
    ) -> Self {
        let plugin = BlockURLOpenerPlugin<Void>(name: name, condition: { url in
            if condition(url) {
                .yes(())
            } else {
                .no
            }
        }, handler: { mainboard, _ in
            handler(mainboard)
        })
        return install(urlOpenerPlugin: plugin)
    }

    @discardableResult
    public func installURLOpenerPlugin(
        name: String? = nil,
        matchingPath: String,
        handler: @escaping (_ mainboard: FlowMotherboard, _ parameters: [String: String]) -> Void
    ) -> Self {
        let plugin = BlockURLOpenerPathMatchingPlugin(name: name, matchingPath: matchingPath, handler: handler)
        return install(urlOpenerPlugin: plugin)
    }

    @discardableResult
    public func setURLNotFoundHandler(_ handler: URLNotFoundHandler?) -> Self {
        urlNotFoundHandler = handler
        return self
    }

    @discardableResult
    public func setURLOpenerSelectionHandler(_ handler: @escaping URLOpenerSelectionHandler) -> Self {
        urlOpenerSelectionHandler = handler
        return self
    }

    @discardableResult
    public func setURLOpeningValidator(_ validator: @escaping URLOpeningValidator) -> Self {
        urlOpeningValidator = validator
        return self
    }

    @discardableResult
    public func setURLDeniedHandler(_ handler: @escaping URLDeniedHandler) -> Self {
        urlDeniedHandler = handler
        return self
    }

    /// Open an URL using URLOpenerPlugin
    /// - Parameter url: The input URL which might be a deep link, universal link or any income URL to the app
    /// - Returns: A array of strings name of matched plugins that handled the URL
    @discardableResult
    public func open(url: URL) -> [String] {
        switch urlOpeningValidator(url) {
        case .accepted:
            return handleOpen(url: url)
        case .denied:
            urlDeniedHandler?(mainboard, url)
            return []
        }
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

    func handleOpen(url: URL) -> [String] {
        let handlers = urlOpenerPlugins.filter { plugin in
            plugin.canOpenURL(url)
        }

        let numberOfHandlers = handlers.count

        switch numberOfHandlers {
        case 0:
            urlNotFoundHandler?(mainboard, url)
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
}

public enum URLOpeningValidationStatus {
    case accepted
    case denied
}
