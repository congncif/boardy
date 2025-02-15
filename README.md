<p align="center">
  <img src="https://i.imgur.com/d6RaK5a.png"/>
</p>

# Boardy

[![Version](https://img.shields.io/cocoapods/v/Boardy.svg?style=flat)](https://cocoapods.org/pods/Boardy)
[![License](https://img.shields.io/cocoapods/l/Boardy.svg?style=flat)](https://cocoapods.org/pods/Boardy)
[![Platform](https://img.shields.io/cocoapods/p/Boardy.svg?style=flat)](https://cocoapods.org/pods/Boardy)

## Why Boardy?

**Microsystems** or **microservices** is an architecture that is particularly effective at developing large, complex, and constantly changing systems in terms of requirements.

In a mobile application development environment, it is difficult to properly implement microsystems due to technological barriers. While microsystems value independence, the components of a mobile application often operate in close cohesion. Or the fact that microsystems interact with each other dynamically and flexibly, the components of the mobile application appreciate the binding and type-safe data. However, microsystems design theories and principles can be applied in a custom way to be able to make mobile applications like microsystems. Suitable for applications with high complexity and expansion requirements.

**Two principles** when building microsystems architecture:

- **Eliminate and optimize** component **dependencies** so that it becomes **isolated**.  This makes it easy to pack a component as a package and **can be shipped anywhere** in the system.

- Use a **unique set of protocols** to communicate with all components in the system.  So a component can **interact with any other component**.  From the outside they are completely similar and **can be interchangeable** without changing core business.

**Boardy** helps to build mobile app microsystems like in a simple way. Inspired by computer motherboards. Boardy builds a system of microsystems based on Boards. Each Board corresponds to a microsystems contained within it is a component of the mobile application, which will perform a specific task. All boards are then integrated together into one motherboard to form complete systems. The components do not interact directly with each other, but through the standard Boardy protocol suite. The core business logic is protected from change and external impact. Just changing how boards can be integrated can create a new business so changes or scaling are made easy, ensuring both maintenance and development requirements at the same time.

> [!IMPORTANT]
> A board should be a stateless component, it should not hold any variables that represent the state of the context. Its lifecycle is automatically managed by its Motherboard so in most cases you do not need to care when it is created or destroyed. However, although not recommended, in some cases you can still use it as a stateful component. In that case, when you're done you need to call complete() to dispose of it to free up resources.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

+ iOS 10+
+ Xcode 11+
+ Swift 5.1+

## Installation

Boardy is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Boardy'
```

Install subspecs for more features:

```ruby
# Utilities toolkit
pod 'Boardy/ComponentKit'
```

```ruby
# Modularization
pod 'Boardy/ModulePlugin'
```

```ruby
# Build a complex UI using Boardy
pod 'Boardy/Composable'
```

## Install template to develop feature

* Run script built-in **CocoaPods.Boardy**

```shell
sh Pods/Boardy/tools/install-template.sh
```

* Create new module using **Boardy**

```shell
cd submodules/YourEmptyModuleDirectory
sh ../../Pods/Boardy/tools/init-module.sh YourModuleName
```

The script should create 2 modules:

- **YourModuleName**: Interface-only module which will be used for communicate with other microservices via public protocols (such as **ServiceMap** or public IOInterface).
- **YourModuleNamePlugins**: Implementation module which includes internal microservices that implement protocols in the Interface module and and module plugins for integration into the main app.

## Reference

* [Microsystems for mobile app](https://congnc-if.medium.com/microsystems-for-mobile-app-c51708299439)
* [Boardy Modularization](docs/Boardy%20Modularization.md)
* [Handle URL opening / deep link](docs/Open%20an%20URL.md)
* [Configure Activation Barrier for your Board](docs/Activation%20Barrier.md)
* [Boardy ComponentKit](docs/ComponentKit.md)

## Author

congncif, congnc.if@gmail.com

## License

Boardy is available under the MIT license. See the LICENSE file for more info.
