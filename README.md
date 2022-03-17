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

* Clone [module template](https://github.com/congncif/module-template.git) repo
* Run `./install-template.sh`
* Restart **Xcode**


## Add a new feature

Right click in **Xcode** to add *New File...* then choose **`Boardy`** template, enter `name` and press *Next*, choose file location and *Create*.

New feature component will be created, contains a **Board**, an **IOInterface**, a **View Controller or Viewless Controller** with **Builder** pattern.

**Boardy 1.19+** introduces [`IOInterface`](Boardy%20Modularization.md) to communicate between microservices  *(you can generate a custom public `IOInterface` by using above templates)*. This helps microservices ensure consistent `Input` `Output` values, ***type-safe interaction***.

> Note: You need to check and update correct Input & Output Type you would like to use for Your Component in `YourInOut.swift` *(by default the Input Ouput is Optional Any)*.

From **Boardy 1.27+**, came with [`ModulePlugin`](Boardy%20Modularization.md#moduleplugin). So you just add below subspec:
```ruby
pod "Boardy/ModulePlugin"
```

*You might need to add a `BoardRegistration` for `Your Board` to right place in `Integration/YourModulePlugin.swift`. The place depends on your flow structure. A `Motherboard` manages a business flow, a `continuousBoard` manages a child flow.*

***☞ Otherwise, you need to add registration to BoardProducer to provide YourBoard constructor***

*`BoardProducer` is factory which helps `Motherboard` lazy initialize a child Board on the first activation. This is useful when the `Motherboard` doesn't need initialize all of its Boards at once that might cause some performance issues in case too many children.*

```swift
BoardRegistration(.yourFeature) { identifier in
    YourBoard(identifier: identifier, builder: YourBuilder())
}
```

### **You use the `Board` to communicate with other feature components:**

* To activate `OtherFeature` as child flow, use `activation` in `IOInterface`:
```swift
func openOtherFeature() {
    motherboard.ioOtherFeature().activation.activate()
}
```
* To handle callback from `Other Feature`, register a flow, use `flow` handler in `IOInterface`:
```swift
func registerFlows() {
    motherboard.ioOtherFeature().flow.addTarget(self) { target, output in
        target.handleOutput(output)
    }
}
```
* To send a output data to `Motherboard`, use `sendOutput` method:
```swift
func yourFeatureDidComplete() {
    self.sendOutput("Output data")
}
```
* To interact with *Internal Controller*, use **Event Bus**:
```swift
...
// Declare bus with data type String for example
private let eventBus = Bus<String>()
...

// Bind the bus to Controller to get data
func activate(withGuaranteedInput input: InputType) {
    let component = builder.build(withDelegate: self)
    let viewController = component.userInterface
    motherboard.putIntoContext(viewController)
    rootViewController.show(viewController)
        
    eventBus.connect(target: component.controller) { controller, data in
        controller.updateSomething(data)
    }
}

// Transport data to bus, for example from OtherFeature callback
func registerFlows() {
    motherboard.ioOtherFeature().flow.bind(to: eventBus)
}

// Or send a custom event
func sendCustomEvent(value: String) {
    eventBus.transport(value)
}
```

## Reference

* [Microsystems for mobile app](https://congnc-if.medium.com/microsystems-for-mobile-app-c51708299439)
* [Boardy Modularization](Boardy%20Modularization.md)
* [Handle URL opening / deep link](Open%20an%20URL.md)
* [Boardy ComponentKit](ComponentKit.md)
* [HelloBoardy - A demo for Boardy: Part I+II - Basic, Part III - Boardy Modularization](https://github.com/congncif/hello-boardy/tree/master/Part-III)

## Author

congncif, congnc.if@gmail.com

## License

Boardy is available under the MIT license. See the LICENSE file for more info.
