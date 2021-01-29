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

<p align="center">
  <img src="https://i.imgur.com/K3P7G3f.jpg"/>
</p>

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
# Handle deep link using Boardy
pod 'Boardy/DeepLink'
```

```ruby
# Build a complex UI using Boardy
pod 'Boardy/Composable'
```

## Author

congncif, congnc.if@gmail.com

## License

Boardy is available under the MIT license. See the LICENSE file for more info.
