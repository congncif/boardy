# Open an URL

The **Boardy** `1.42+` enables to activate a `Board` via an URL. This feature is provided by two methods in the `PluginLauncher`:

```swift
// PluginLauncher.swift

/// Open an URL using URLOpenerPlugin
/// - Parameter url: The input URL which might be a deep link, universal link or any income URL to the app
/// - Returns: A array of strings name of matched plugins that handled the URL
public func open(url: URL) -> [String]

/// Open a link using URLOpenerPlugin
/// - Parameter link: Might be a deep link, universal link or any income URL to the app
/// - Returns: A array of strings name of matched plugins that handled the link
public func open(link: String) -> [String]
```

You need to install `URLOpenerPlugin` into `PluginLauncher` for matching an URL with an activation.

```swift
// PluginLauncher.swift

public func install(urlOpenerPlugin: URLOpenerPlugin)
```

You can create an custom plugin yourself which conforms the `URLOpenerPlugin` protocol or use some extension methods of `PluginLauncher` that will help you install a plugin simply.

```swift
PluginLauncher.with(options: .default)
    .install(plugins: YourModulePlugin.bundledPlugins)
    .initialize()
    .installURLOpenerPlugin(name: "custom-name") { url in
        url.path == "/your-module" // Handle for URL: sheme://host.com/your-module
    } handler: { mainboard in
        mainboard.ioYour().activation.activate()
    }
```
> After above installation, when you call `PluginLauncher.shared.open(link: "sheme://host.com/your-module")`, `YourBoard` will be activated. The `PluginLauncher` now works as an URL opening proxy.

If you would like to pass some arguments to `YourBoard`, you can use the generic installation method.

```swift
//E.g: Handle for URL: scheme://host.com/your-module?id=1&code=COD
PluginLauncher.shared
    .installURLOpenerPlugin(name: "custom-name") { url -> URLOpeningOption<YourModel> in
        // Parse the URL to get parameters
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           let queryItems = components?.queryItems,
           let queryParameters = queryItems?.reduce(into: [:], { partialResult, item in
               partialResult[item.name] = item.value
           }), 
           let model = YourModel(from: queryParameters),
           url.path == "/your-module" {
            return .yes(model)
        } else {
            return .no
        }
    } handler: { mainboard, input in
        mainboard.ioYour().activation.activate(with: input)
    }
...
struct YourModel {
    let id: Int
    let code: String

    init?(from parameters: [String: String?]) { ... }
}
```